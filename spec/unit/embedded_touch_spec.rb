require "spec_helper"

if Mongoid::VERSION =~ /\A3\./

  class Edit
    include Mongoid::Document
    include Mongoid::Timestamps::Updated
    embedded_in :wiki_page, touch: true
  end

  class WikiPage
    include Mongoid::Document
    include Mongoid::Timestamps

    field :title, type: String

    embeds_many :edits, validate: false
  end

  describe Mongoid::Relations::Embedded::In do

    describe ".valid_options" do

      it "returns the valid options" do
        expect(described_class.valid_options).to eq([ :autobuild, :cyclic, :polymorphic, :touch ])
      end
    end
  end

  describe Mongoid::Relations::Touchable do

    context "when the relation is a parent of an embedded doc" do

      let(:page) do
        WikiPage.create(title: "test")
      end

      let!(:edit) do
        page.edits.create
      end

      before do
        page.unset(:updated_at)
        edit.touch
      end

      it "touches the parent document" do
        expect(page.updated_at).to be_within(5).of(Time.now)
      end
    end
  end
end
