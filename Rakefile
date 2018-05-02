require 'rake/tasklib'
require 'rake/sprocketstask'
require './app/web/server'

namespace :assets do
  desc 'Precompile assets'
  task :precompile do
    environment = WebServer.assets
    manifest = Sprockets::Manifest.new(environment.index, File.join(WebServer.assets_path, "manifesto.json"))
    manifest.compile(WebServer.assets_precompile)
  end

  desc "Clean assets"
  task :clean do
    FileUtils.rm_rf(WebServer.assets_path)
  end
end
