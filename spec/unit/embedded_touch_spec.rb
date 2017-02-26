require "spec_helper"

if Mongoid::VERSION =~ /\A[345]\./

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

    context "when the parent of embedded doc has cascade callbacks" do

      let!(:book) do
        Book.new
      end

      before do
        book.pages.new
        book.save
        book.unset(:updated_at)
        book.pages.first.touch
      end

      it "touches the parent document" do
        expect(book.updated_at).to be_within(5).of(Time.now)
      end
    end

    context "when multiple embedded docs with cascade callbacks" do

      let!(:book) do
        Book.new
      end

      before do
        2.times { book.pages.new }
        book.save
        book.unset(:updated_at)
        book.pages.first.content  = "foo"
        book.pages.second.content = "bar"
        book.pages.first.touch
      end

      it "touches the parent document" do
        expect(book.updated_at).to be_within(5).of(Time.now)
      end
    end
  end
end
