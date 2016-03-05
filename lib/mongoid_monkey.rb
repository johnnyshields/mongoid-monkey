require 'version'

if Mongoid::VERSION =~ /\A3\./
  require 'patches/atomic'
  require 'patches/reorder'
end

if Mongoid::VERSION =~ /\A[345]\./
  require 'patches/big_decimal'
end

if defined?(Moped)
  require 'patches/instrument' if Moped::VERSION =~ /\A1\./
  require 'patches/list_collections'
end
