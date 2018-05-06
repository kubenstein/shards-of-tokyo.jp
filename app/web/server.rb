require 'sinatra/base'
require 'slim'
require 'require_all'
require_all './app/lib'
require_all './app/web/lib'

class WebServer < Sinatra::Base
  register AssetPipeline
  enable :sessions

  get '/' do
    slim :'home_page/index', layout: :home_page_layout
  end

  post '/registration' do
    registration_results = SoT::Registration::NewUserWorkflow.new.register(params)
    if registration_results.success?
      session[:current_user_id] = registration_results.user_id
      redirect '/registration/success'
    else
      slim :'registration/_form', locals: { errors: registration_results.errors, fields: params }
    end
  end

  get '/registration/success' do
    registered_user = SoT::UserRepository.new.find(session[:current_user_id])
    slim :'registration/success', locals: { user: registered_user }
  end
end
