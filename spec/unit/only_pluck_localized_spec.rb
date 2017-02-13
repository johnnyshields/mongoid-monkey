require "spec_helper"

if defined?(Moped) && Moped::VERSION =~ /\A3\./

  describe Mongoid::Criteria do

    describe "#only" do

      let!(:band) do
        Band.create(name: "Depeche Mode", likes: 3, views: 10)
      end

      context "when not using inheritance" do

        context "when passing splat args" do

          let(:criteria) do
            Band.only(:_id)
          end

          it "limits the returned fields" do
            criteria.first.name.should be_nil
          end

          it "does not add _type to the fields" do
            criteria.options[:fields]["_type"].should be_nil
          end
        end

        context "when not including id" do

          let(:criteria) do
            Band.only(:name)
          end

          it "responds to id anyway" do
            expect {
              criteria.first.id
            }.to_not raise_error
          end
        end

        context "when passing an array" do

          let(:criteria) do
            Band.only([ :name, :likes ])
          end

          it "includes the limited fields" do
            criteria.first.name.should_not be_nil
          end

          it "excludes the non included fields" do
            criteria.first.active.should be_nil
          end

          it "does not add _type to the fields" do
            criteria.options[:fields]["_type"].should be_nil
          end
        end

        context "when instantiating a class of another type inside the iteration" do

          let(:criteria) do
            Band.only(:name)
          end

          it "only limits the fields on the correct model" do
            criteria.each do |band|
              Person.new.age.should eq(100)
            end
          end
        end

        context "when instantiating a document not in the result set" do

          let(:criteria) do
            Band.only(:name)
          end

          it "only limits the fields on the correct criteria" do
            criteria.each do |band|
              Band.new.active.should be_true
            end
          end
        end

        context "when nesting a criteria within a criteria" do

          let(:criteria) do
            Band.only(:name)
          end

          it "only limits the fields on the correct criteria" do
            criteria.each do |band|
              Band.all.each do |b|
                b.active.should be_true
              end
            end
          end
        end
      end

      context "when using inheritance" do

        let(:criteria) do
          Doctor.only(:_id)
        end

        it "adds _type to the fields" do
          criteria.options[:fields]["_type"].should eq(1)
        end
      end

      context "when limiting to embedded documents" do

        context "when the embedded documents are aliased" do

          let(:criteria) do
            Person.only(:phones)
          end

          it "properly uses the database field name" do
            criteria.options.should eq(fields: { "mobile_phones" => 1 })
          end
        end
      end

      context 'when the field is localized' do

        before do
          I18n.locale = :en
          d = Dictionary.create(description: 'english-text')
          I18n.locale = :de
          d.description = 'deutsch-text'
          d.save
        end

        after do
          I18n.locale = :en
        end

        context 'when entire field is included' do

          let(:dictionary) do
            Dictionary.only(:description).first
          end

          it 'loads all translations' do
            expect(dictionary.description_translations.keys).to include('de', 'en')
          end

          it 'returns the field value for the current locale' do
            I18n.locale = :en
            expect(dictionary.description).to eq('english-text')
            I18n.locale = :de
            expect(dictionary.description).to eq('deutsch-text')
          end
        end

        context 'when a specific locale is included' do

          let(:dictionary) do
            Dictionary.only(:'description.de').first
          end

          it 'loads translations only for the included locale' do
            expect(dictionary.description_translations.keys).to include('de')
            expect(dictionary.description_translations.keys).to_not include('en')
          end

          it 'returns the field value for the included locale' do
            I18n.locale = :en
            expect(dictionary.description).to be_nil
            I18n.locale = :de
            expect(dictionary.description).to eq('deutsch-text')
          end
        end

        context 'when entire field is excluded' do

          let(:dictionary) do
            Dictionary.without(:description).first
          end

          it 'does not load all translations' do
            expect(dictionary.description_translations.keys).to_not include('de', 'en')
          end

          it 'raises an ActiveModel::MissingAttributeError when attempting to access the field' do
            expect{dictionary.description}.to raise_error ActiveModel::MissingAttributeError
          end
        end

        context 'when a specific locale is excluded' do

          let(:dictionary) do
            Dictionary.without(:'description.de').first
          end

          it 'does not load excluded translations' do
            expect(dictionary.description_translations.keys).to_not include('de')
            expect(dictionary.description_translations.keys).to include('en')
          end

          it 'returns nil for excluded translations' do
            I18n.locale = :en
            expect(dictionary.description).to eq('english-text')
            I18n.locale = :de
            expect(dictionary.description).to be_nil
          end
        end
      end
    end

    describe "#pluck" do

      let!(:depeche) do
        Band.create(name: "Depeche Mode", likes: 3)
      end

      let!(:tool) do
        Band.create(name: "Tool", likes: 3)
      end

      let!(:photek) do
        Band.create(name: "Photek", likes: 1)
      end

      context "when the criteria matches" do

        context "when there are no duplicate values" do

          let(:criteria) do
            Band.where(:name.exists => true)
          end

          let!(:plucked) do
            criteria.pluck(:name)
          end

          it "returns the values" do
            plucked.should eq([ "Depeche Mode", "Tool", "Photek" ])
          end

          context "when subsequently executing the criteria without a pluck" do

            it "does not limit the fields" do
              expect(criteria.first.likes).to eq(3)
            end
          end
        end

        context "when there are duplicate values" do

          let(:plucked) do
            Band.where(:name.exists => true).pluck(:likes)
          end

          it "returns the duplicates" do
            plucked.should eq([ 3, 3, 1 ])
          end
        end
      end

      context "when the criteria does not match" do

        let(:plucked) do
          Band.where(name: "New Order").pluck(:_id)
        end

        it "returns an empty array" do
          plucked.should be_empty
        end
      end

      context "when plucking an aliased field" do

        let(:plucked) do
          Band.all.pluck(:id)
        end

        it "returns the field values" do
          plucked.should eq([ depeche.id, tool.id, photek.id ])
        end
      end

      context 'when plucking a localized field' do

        before do
          I18n.locale = :en
          d = Dictionary.create(description: 'english-text')
          I18n.locale = :de
          d.description = 'deutsch-text'
          d.save
        end

        after do
          I18n.locale = :en
        end

        context 'when plucking the entire field' do

          let(:plucked) do
            Dictionary.all.pluck(:description)
          end

          it 'returns all translations' do
            expect(plucked.first).to eq({'en' => 'english-text', 'de' => 'deutsch-text'})
          end
        end

        context 'when plucking a specific locale' do

          let(:plucked) do
            Dictionary.all.pluck(:'description.de')
          end

          it 'returns the specific translations' do
            expect(plucked.first).to eq({'de' => 'deutsch-text'})
          end
        end
      end
    end
  end
end
