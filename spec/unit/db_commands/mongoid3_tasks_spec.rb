require "spec_helper"

if Mongoid::VERSION =~ /\A3\./

  describe Rails::Mongoid do

    let(:logger) do
      double("logger").tap do |log|
        allow(log).to receive(:info)
      end
    end

    before do
      allow(Rails::Mongoid).to receive(:logger).and_return(logger)
    end

    let(:pattern) do
      "spec/app/models/**/*.rb"
    end

    describe ".create_indexes" do

      let!(:klass) do
        User
      end

      let(:indexes) do
        Rails::Mongoid.create_indexes(pattern)
      end

      context "with ordinary Rails models" do

        it "creates the indexes for the models" do
          expect(klass).to receive(:create_indexes).once
          indexes
        end
      end

      context "with a model without indexes" do

        let(:klass) do
          Account
        end

        it "does nothing" do
          expect(klass).to receive(:create_indexes).never
          indexes
        end
      end

      context "when an exception is raised" do

        it "is not swallowed" do
          expect(klass).to receive(:create_indexes).and_raise(ArgumentError)
          expect { indexes }.to raise_error(ArgumentError)
        end
      end

      context "when index is defined on embedded model" do

        let!(:klass) do
          Address
        end

        before do
          klass.index(street: 1)
        end

        it "does nothing, but logging" do
          expect(klass).to receive(:create_indexes).never
          indexes
        end
      end

      context "when index is defined on self-embedded (cyclic) model" do

        let(:klass) do
          Draft
        end

        it "creates the indexes for the models" do
          expect(klass).to receive(:create_indexes).once
          indexes
        end
      end
    end

    describe ".remove_indexes" do

      let!(:klass) do
        User
      end

      let(:indexes) do
        klass.collection.indexes
      end

      before :each do
        Rails::Mongoid.create_indexes(pattern)
        Rails::Mongoid.remove_indexes(pattern)
      end

      it "removes indexes from klass" do
        expect(indexes.reject{ |doc| doc["name"] == "_id_" }).to be_empty
      end

      it "leaves _id index untouched" do
        expect(indexes.select{ |doc| doc["name"] == "_id_" }).to_not be_empty
      end
    end
  end
end
