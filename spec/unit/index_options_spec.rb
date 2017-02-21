require "spec_helper"

if Mongoid::VERSION =~ /\A[34]\./

  describe 'Index Valid Options' do
    let(:mod){ Mongoid::VERSION =~ /\A3\./ ? Mongoid::Indexes::Validators : Mongoid::Indexable::Validators }
    let(:exp) do
      [ :background,
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
        :collation ]
    end
    it { expect(mod::Options::VALID_OPTIONS).to eq(exp) }
  end
end
