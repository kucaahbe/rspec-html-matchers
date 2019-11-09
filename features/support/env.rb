# setup rspec matchers
require 'rspec/expectations'
World(RSpec::Matchers)
require 'sinatra/base'
require 'capybara/cucumber'
require 'rspec-html-matchers'
begin
  require 'webdrivers'
rescue LoadError
  # noop
end
require 'selenium-webdriver'

World RSpecHtmlMatchers

$ASSETS_DIR = File.expand_path('../tmp',__FILE__)
$INDEX_HTML = File.join($ASSETS_DIR,'index.html')

class SimpleApp < Sinatra::Base
  set :public_folder, $ASSETS_DIR
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=800,600')

  Capybara::Selenium::Driver.new(app, :browser => :chrome, :options => options)
end

Capybara.configure do |config|
  config.default_max_wait_time = 15 if config.respond_to? :default_max_wait_time=
  config.default_driver = :selenium
  config.default_driver = :headless_chrome if Gem.loaded_specs['selenium-webdriver'].version >= Gem::Version.new('3')
end
Capybara.app = SimpleApp

Before do
  FileUtils.mkdir $ASSETS_DIR
end

After do
  FileUtils.rm_rf $ASSETS_DIR
end
