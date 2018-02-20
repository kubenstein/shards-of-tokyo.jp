require 'sinatra/base'
require 'slim'
require_relative './lib/asset_pipeline'

class App < Sinatra::Base
  register AssetPipeline

  get '/' do
    slim :index
  end
end
