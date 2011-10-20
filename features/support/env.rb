require 'sinatra/base'
require 'capybara/cucumber'
require 'rspec2-rails-views-matchers'

$ASSETS_DIR = File.join(Dir.pwd,'assets')
$INDEX_HTML = File.join($ASSETS_DIR,'index.html')

class SimpleApp < Sinatra::Base
  set :public_folder, $ASSETS_DIR
end

Capybara.default_driver = :selenium
Capybara.app = SimpleApp

After do
  FileUtils.rm $INDEX_HTML
end
