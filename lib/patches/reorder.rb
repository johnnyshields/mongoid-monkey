# Backport of Criteria#reorder method from Mongoid 4 to Mongoid 3.

module Origin
  module Optional

    def reorder(*spec)
      options.delete(:sort)
      order_by(*spec)
    end
  end
end
