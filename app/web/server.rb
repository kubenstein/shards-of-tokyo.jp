require 'sinatra/base'
require 'slim'
require './app/lib/lib'
require './app/web/lib/asset_pipeline'


class WebServer < Sinatra::Base
  register AssetPipeline
  enable :sessions
  set :session_secret, APP_DEPENDENCIES[:session_secret]

  include Import[
    :user_repository,
    :order_repository,
    :register_user_workflow,
    :add_order_message_workflow,
    :submit_new_order_workflow,
    :login_user_step1_workflow,
  ]

  get '/' do
    slim :'home_page/index', layout: :home_page_layout
  end

  get '/login/?' do

    slim :'login/email_form'
  end

  post '/login/?' do
    params[:session_id] = session.id
    login_step1 = login_user_step1_workflow.call(params)
    if login_step1.success?
      redirect "/login/token_check_waiting?token_id=#{login_step1.token.id}"
    else
      slim :'login/email_form', locals: { errors: login_step1.errors, fields: params }
    end
  end

  post '/registration' do
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
    # waiting for login functionality...
    # current_user = user_repository.find_by(id: session[:current_user_id])
    current_user = user_repository.find_by(email: 'snow.jon@gmail.com')
    params[:user] = current_user
    results = submit_new_order_workflow.call(params)
    if results.success?
      redirect "/orders/#{results.order_id}"
    else
      slim :'orders/_new_form', locals: { errors: results.errors, fields: params }
    end
  end

  get '/orders/new' do
    slim :'orders/_new_form'
  end

  get '/orders/?:order_id?' do
    # waiting for login functionality...
    # current_user = user_repository.find_by(id: session[:current_user_id])
    current_user = user_repository.find_by(email: 'snow.jon@gmail.com')
    orders = order_repository.for_user_newest_first(current_user.id)
    selected_order = params[:order_id] ? orders.find { |o| o.id == params[:order_id] } : orders[0]

    slim :'orders/index', locals: {
      user: current_user,
      orders: orders,
      selected_order: selected_order,
      message_form_error: (!!params[:message_form_error])
    }
  end

  post '/messages' do
    # waiting for login functionality...
    # current_user = user_repository.find_by(id: session[:current_user_id])
    current_user = user_repository.find_by(email: 'snow.jon@gmail.com')
    params[:user] = current_user
    result = add_order_message_workflow.call(params)
    if result.success?
      redirect "/orders/#{result.order_id}"
    else
      redirect "/orders/#{result.order_id}?message_form_error=true"
    end
  end
end
