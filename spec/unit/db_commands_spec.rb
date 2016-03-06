require "spec_helper"

if defined?(Moped)

  describe Moped::Database do

    describe "#collection_names" do

      let(:session) do
        Moped::Session.new([ "127.0.0.1:27017" ], database: $database_name)
      end

      let(:database) do
        described_class.new(session, $database_name)
      end

      let(:collection_names) do
        database.collection_names
      end

      before do
        session.drop
        names.map do |name|
          session.command(create: name)
        end
      end

      context "when name doesn't include system" do

        let(:names) do
          %w[ users comments ]
        end

        it "returns the name of all non system collections" do
          expect(collection_names.sort).to eq([ "comments", "users" ])
        end
      end

      context "when name includes system not at the beginning" do

        let(:names) do
          %w[ users comments_system_fu ]
        end

        it "returns the name of all non system collections" do
          expect(collection_names.sort).to eq([ "comments_system_fu", "users" ])
        end
      end

      context "when name includes system at the beginning" do

        let(:names) do
          %w[ users system_comments_fu ]
        end

        it "returns the name of all non system collections" do
          expect(collection_names.sort).to eq([ "system_comments_fu", "users" ])
        end
      end
    end
  end

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

        it "drops the index" do
          indexes.create name: 1
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
