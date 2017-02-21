# Backport Mongoid 4 :touch option for #embedded_in to Mongoid 3.

if Mongoid::VERSION =~ /\A3\./

module Mongoid
module Indexes
module Validators

  module Options
    VALID_OPTIONS = [
        :background,
        :database,
        :default_language,
        :language_override,
        :drop_dups,
        :name,
        :sparse,
        :unique,
        :max,
        :min,
        :bits,
        :bucket_size,
        :expire_after_seconds,
        :weights,
        :storage_engine,
        :sphere_version,
        :text_version,
        :version,
        :partial_filter_expression,
        :collation
    ]
  end
end
end
end

elsif Mongoid::VERSION =~ /\A4\./

module Mongoid
module Indexable
module Validators

  module Options
    VALID_OPTIONS = [
        :background,
        :database,
        :default_language,
        :language_override,
        :drop_dups,
        :name,
        :sparse,
        :unique,
        :max,
        :min,
        :bits,
        :bucket_size,
        :expire_after_seconds,
        :weights,
        :storage_engine,
        :sphere_version,
        :text_version,
        :version,
        :partial_filter_expression,
        :collation
    ]
  end
end
end
end

end
