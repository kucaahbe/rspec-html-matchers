require 'sinatra/base'
require 'capybara/cucumber'
require 'rspec-html-matchers'

$ASSETS_DIR = File.expand_path('../../../spec/assets',__FILE__)
$INDEX_HTML = File.join($ASSETS_DIR,'index.html')

class SimpleApp < Sinatra::Base
  set :public_folder, $ASSETS_DIR
end

unless ENV.has_key? 'TRAVIS'
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => (ENV['BROWSER'] || :chrome))
  end
end
Capybara.default_driver = :selenium
Capybara.app = SimpleApp

After do
  FileUtils.rm $INDEX_HTML
end
