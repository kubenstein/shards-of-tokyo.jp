require 'sinatra/base'
require 'slim'
require './app/lib/lib'
require './app/web/lib/asset_pipeline'
require './app/web/lib/i18n_helper'


class WebServer < Sinatra::Base
  register AssetPipeline
  enable :sessions
  set :session_secret, APP_DEPENDENCIES[:session_secret]

  include Import[
    :stripe_api_keys,
    :user_repository,
    :order_repository,
    :register_user_workflow,
    :add_order_message_workflow,
    :submit_new_order_workflow,
    :login_user_step1_workflow,
    :login_user_step2_workflow,
    :login_user_step3_workflow,
    :logout_user_workflow,
    :pay_for_order_workflow,
  ]

  helpers do
    def current_user
      @_current_user ||= user_repository.find_logged_in(session_id: session.id)
    end

    def i18n
      @_i18n ||= I18nHelper.new
    end
  end

  get '/' do
    slim :'home_page/index'
  end

  get '/login/?' do
    return redirect '/orders/' if current_user

    slim :'login/index'
  end

  post '/login/?' do
    return redirect '/orders/' if current_user

    params[:session_id] = session.id
    login_step1 = login_user_step1_workflow.call(params)
    if login_step1.success?
      redirect '/login/token_check_waiting'
    else
      slim :'login/index', locals: { errors: login_step1.errors, fields: params }
    end
  end

  get '/login/accept_link_from_email/?' do
    login_confirmation = login_user_step2_workflow.call(params)
    if login_confirmation.success?
      slim :'login/accept_link_from_email'
    else
      slim :'login/accept_link_from_email', locals: { errors: login_confirmation.errors }
    end
  end

  get '/login/token_check_waiting/?' do
    return redirect '/orders/' if current_user

    params[:session_id] = session.id
    login_token_confirmed = login_user_step3_workflow.call(params)
    if login_token_confirmed.success?
      redirect '/orders/'
    end
    slim :'login/token_check_waiting', locals: { email: login_token_confirmed.user_email }
  end

  get '/logout/?' do
    params[:session_id] = session.id
    logout_user_workflow.call(params)
    session[:current_user_id] = nil
    redirect '/'
  end

  get '/registration' do
    slim :'registration/_form'
  end

  post '/registration' do
    return redirect '/orders/' if current_user

    registration_results = register_user_workflow.call(params)
    if registration_results.success?
      session[:current_user_id] = registration_results.user_id
      redirect '/registration/success'
    else
      slim :'registration/_form', locals: { errors: registration_results.errors, fields: params }
    end
  end

  get '/registration/success' do
    registered_user = user_repository.find_by(id: session[:current_user_id])
    slim :'registration/success', locals: { user: registered_user }
  end

  post '/orders/?' do
    return redirect '/login/' unless current_user

    params[:user] = current_user
    results = submit_new_order_workflow.call(params)
    if results.success?
      redirect "/orders/#{results.order_id}"
    else
      orders = order_repository.for_user_newest_first(current_user.id)
      slim :'orders/new', locals: { orders: orders, errors: results.errors, fields: params }
    end
  end

  get '/orders/new' do
    return redirect '/login/' unless current_user

    orders = order_repository.for_user_newest_first(current_user.id)
    slim :'orders/new', locals: { orders: orders }
  end

  post '/orders/:order_id/pay' do
    return redirect '/login/' unless current_user

    params[:user] = current_user
    params[:stripe_token] = params[:stripeToken]
    results = pay_for_order_workflow.call(params)
    if results.success?
      redirect "/orders/#{results.order_id}/pay/success"
    else
      slim :'orders/payment_failed/index', locals: { order_id: params[:order_id], errors: results.errors }
    end
  end

  get '/orders/:order_id/pay/success' do
    return redirect '/login/' unless current_user
    slim :'orders/payment_success/index', locals: { order_id: params[:order_id] }
  end

  get '/orders/?:order_id?/?' do
    return redirect '/login/' unless current_user

    orders = order_repository.for_user_newest_first(current_user.id)
    selected_order = params[:order_id] ? orders.find { |o| o.id == params[:order_id] } : orders[0]

    slim :'orders/show', locals: {
      user: current_user,
      orders: orders,
      selected_order: selected_order,
      message_form_error: (!!params[:message_form_error]),
      stripe_public_token: stripe_api_keys[:public_key]
    }
  end

  post '/messages' do
    return redirect '/login/' unless current_user

    params[:user] = current_user
    result = add_order_message_workflow.call(params)
    if result.success?
      redirect "/orders/#{result.order_id}"
    else
      redirect "/orders/#{result.order_id}?message_form_error=true"
    end
  end
end
