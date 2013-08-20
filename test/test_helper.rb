# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'capybara/rails'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

class CapybaraTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  setup do
    Capybara.current_driver = :webkit
    Capybara.javascript_driver = :webkit
  end

  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def screenshot(name = 'test_screenshot')
    page.driver.render "tmp/#{name}.png"
    `open tmp/#{name}.png`
  end
end

# Force shared connections for capybara-webkit
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(:size => 1, :timeout => 15) { retrieve_connection }
  end

  def self.clear_all_connections!
    @@shared_connection = nil
  end

  # Hack to get DatabaseCleaner working
  def self.increment_open_transactions
    connection.increment_open_transactions
  end

  def self.decrement_open_transactions
    connection.decrement_open_transactions
  end
end

ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
