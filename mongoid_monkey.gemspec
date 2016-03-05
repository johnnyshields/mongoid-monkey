$:.push File.expand_path('../lib', __FILE__)
require 'version'

Gem::Specification.new do |s|
  s.name        = 'mongoid_monkey'
  s.version     = MongoidMonkey::VERSION
  s.authors     = ['johnnyshields']
  s.email       = ['johnny.shields@gmail.com']
  s.homepage    = 'https://github.com/johnnyshields/mongoid_monkey'
  s.summary     = 'Monkey patches for Mongoid'
  s.description = 'A collection of monkey patches for Mongoid containing feature backports, fixes, and forward compatibility.'
  s.license     = 'MIT'

  s.files         = Dir.glob('lib/**/*') + %w(LICENSE README.md)
  s.test_files    = Dir.glob('{perf,spec}/**/*')
  s.require_paths = ['lib']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_runtime_dependency 'mongoid', '>= 3'
end
