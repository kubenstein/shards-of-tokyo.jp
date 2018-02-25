require 'sinatra/base'
require 'slim'
require 'require_all'
require_all './app/lib'

class App < Sinatra::Base
  register AssetPipeline

  get '/' do
    plans = PlansRepository.new.all
    slim :index, locals: { plans: plans }
  end

  get '/subscription/plan-:id' do
    plan = PlansRepository.new.find(params['id'])
    slim :'subscription/details', locals: { plan: plan }
  end
end
