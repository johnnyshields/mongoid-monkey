# Backport Mongoid 6 index options to Mongoid 3 and 4.

if Mongoid::VERSION =~ /\A3\./

  ::Mongoid::Indexes::Validators::Options.send(:remove_const, :VALID_OPTIONS)
  module Mongoid::Indexes::Validators::Options
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

elsif Mongoid::VERSION =~ /\A4\./

  ::Mongoid::Indexable::Validators::Options.send(:remove_const, :VALID_OPTIONS)
  module Mongoid::Indexable::Validators::Options
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
