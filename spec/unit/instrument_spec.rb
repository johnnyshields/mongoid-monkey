require "spec_helper"

if defined?(Moped) && Moped::VERSION =~ /\A1\./

  describe Moped::Node do
    let(:node){ Moped::Node.new("127.0.0.1:27017") }

    it { expect(described_class.included_modules).to include(Moped::Instrumentable) }
    it { expect(node.instrumenter).to eq Moped::Instrumentable::Noop }
    it { expect(node).to respond_to(:instrument) }
  end
end
