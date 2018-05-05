require 'sinatra/base'
require 'slim'
require './app/lib/lib'
require './app/web/lib/asset_pipeline'

class WebServer < Sinatra::Base
  register AssetPipeline
  enable :sessions
  include Import[
    :user_repository,
    :registration_workflow
  ]

  get '/' do
    slim :'home_page/index', layout: :home_page_layout
  end

  post '/registration' do
    registration_results = registration_workflow.register(params)
    if registration_results.success?
      session[:current_user_id] = registration_results.user_id
      redirect '/registration/success'
    else
      slim :'registration/_form', locals: { errors: registration_results.errors, fields: params }
    end
  end

  get '/registration/success' do
    registered_user = user_repository.find(session[:current_user_id])
    slim :'registration/success', locals: { user: registered_user }
  end
end
