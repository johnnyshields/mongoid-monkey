$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

MODELS = File.join(File.dirname(__FILE__), "app/models")
$LOAD_PATH.unshift(MODELS)

$database_name = 'mongoid_monkey_test'

require 'mongoid'
require 'rails/mongoid' if Mongoid::VERSION =~ /\A3\./
require 'mongoid_monkey'
require 'rspec'

Mongoid.configure do |config|
  config.connect_to $database_name
end

Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO unless Mongoid::VERSION =~ /\A[34]\./

# Autoload every model for the test suite that sits in spec/app/models.
Dir[ File.join(MODELS, "*.rb") ].sort.each do |file|
  name = File.basename(file, ".rb")
  autoload name.camelize.to_sym, name
end

RSpec.configure do |config|
  config.after(:all) do
    if Mongoid::VERSION =~ /\A[34]\./
      Mongoid.default_session.drop
    else
      Mongoid::Clients.default.database.drop
    end
  end
end
