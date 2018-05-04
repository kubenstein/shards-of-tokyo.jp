require 'sinatra/base'
require 'slim'
require 'require_all'
require_all './app/lib'
require_all './app/web/lib'

class WebServer < Sinatra::Base
  register AssetPipeline

  get '/' do
    slim :'home_page/index', layout: :home_page_layout
  end

  post '/registration' do
    validation_results = SoT::Registration::Validator.new.validate(params)
    if validation_results.valid?
      SoT::Registration::NewUserWorkflow.new.register(params)
      redirect '/registration/success'
    else
      slim :'registration/_form', locals: { errors: validation_results.errors, fields: params }
    end
  end

  get '/registration/success' do
    slim :'registration/success', locals: { email: 'abc@abc.com' }
  end
end
