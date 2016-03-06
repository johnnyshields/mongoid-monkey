$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$database_name = 'mongoid_monkey_test'

require 'mongoid'
require 'mongoid_monkey'
require 'rspec'

Mongoid.configure do |config|
  config.connect_to $database_name
end

Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO unless Mongoid::VERSION =~ /\A[34]\./

RSpec.configure do |config|
  config.after(:all) do
    if Mongoid::VERSION =~ /\A[34]\./
      Mongoid.default_session.drop
    else
      Mongoid::Clients.default.database.drop
    end
  end
end
