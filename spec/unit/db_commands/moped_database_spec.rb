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
end
