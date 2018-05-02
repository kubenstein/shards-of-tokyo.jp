require 'sinatra/base'
require 'slim'
require 'require_all'
require_all './app/web/lib'

class WebServer < Sinatra::Base
  register AssetPipeline

  get '/' do
    slim :'home_page/index', layout: :home_page_layout
  end

  post '/registration' do
    if (params['email'] == '')
      slim :'registration/_form', locals: { errors: [:email_empty], fields: params }
    else
      puts "register #{params}"
      redirect '/registration/success'
    end
  end

  get '/registration/success' do
    slim :'registration/success', locals: { email: 'abc@abc.com' }
  end
end
