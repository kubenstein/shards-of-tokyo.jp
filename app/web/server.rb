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
    validation_results = SoT::Registration::Validator.new.validate(params)
    if validation_results.valid?
      registered_user = SoT::Registration::NewUserWorkflow.new.register(params)
      session[:current_user_id] = registered_user.id
      redirect '/registration/success'
    else
      slim :'registration/_form', locals: { errors: validation_results.errors, fields: params }
    end
  end

  get '/registration/success' do
    registered_user = SoT::UserRepository.new.find(session[:current_user_id])
    slim :'registration/success', locals: { user: registered_user }
  end
end
