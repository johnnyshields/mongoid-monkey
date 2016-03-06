require "spec_helper"

if defined?(Moped)

  describe Moped::Indexes do

    let(:session) do
      Moped::Session.new %w[127.0.0.1:27017], database: $database_name
    end

    let(:indexes) do
      session[:users].indexes
    end

    before do
      begin
        indexes.drop
      rescue Exception
      end
    end

    describe "#create" do

      context "when called without extra options" do

        it "creates an index with no options" do
          indexes.create name: 1
          indexes[name: 1].should_not eq nil
          keys = []
          indexes.each do |idx|
            keys << idx['key']
          end
          keys.should eq([{"_id" => 1}, {"name" => 1}])
        end
      end

      context "when called with extra options" do

        it "creates an index with the extra options" do
          indexes.create({name: 1}, {unique: true})
          index = indexes[name: 1]
          index["unique"].should eq true
        end
      end

      context "when there is existent data" do

        before do
          3.times { session[:users].insert(name: 'John') }
        end

        it "raises an error" do
          expect {
            indexes.create({name: 1}, {unique: true})
          }.to raise_error(Moped::Errors::OperationFailure)
        end
      end
    end

    describe "#drop" do

      context "when provided a key" do
        before { session.drop }

        it "drops the index" do
          indexes.create(name: 1)["numIndexesAfter"].should eq 2
          indexes.drop(name: 1).should eq true
          indexes.create({name: 1}, {unique: true})["numIndexesAfter"].should eq 2
          indexes.drop(name: 1).should eq true
        end
      end

      context "when not provided a key" do

        it "drops all indexes" do
          indexes.create name: 1
          indexes.create age: 1
          indexes.drop
          indexes[name: 1].should eq nil
          indexes[age: 1].should eq nil
        end
      end
    end
  end
end
