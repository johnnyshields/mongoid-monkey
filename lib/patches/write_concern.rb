# Safe mode should set WriteConcern: Acknowledged in order to support MongoDB 3.4+

if Mongoid::VERSION =~ /\A3\./

  module TrueClass
    def __safe_options__
      { w: 1 }
    end
  end
end
