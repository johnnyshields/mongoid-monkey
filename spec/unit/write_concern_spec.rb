require "spec_helper"

if Mongoid::VERSION =~ /\A3\./

  describe Moped::Query do

    let(:session) do
      Moped::Session.new([ "127.0.0.1:27017" ], database: "moped_test")
    end

    it "safe mode should set w: 1" do
      session.with(safe: true) do |session|
        expect(session.safety).to eq(w: 1)
      end
    end

    it "allow w: majority" do
      session.with(safe: {w: 'majority'}) do |session|
        expect(session.safety).to eq(w: 'majority')
      end
    end

    it "supports non safe mode" do
      session.with(safe: false) do |session|
        expect(session.safety).to eq false
      end
    end
  end
end
