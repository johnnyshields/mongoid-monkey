require "spec_helper"

if Mongoid::VERSION =~ /\A3\./

  describe Origin::Optional do

    let(:query) do
      Origin::Query.new
    end

    describe "#reoder" do

      let(:selection) do
        query.order_by(field_one: 1, field_two: -1)
      end

      let(:reordered) do
        selection.reorder(field_three: 1)
      end

      it "replaces all order options with the new options" do
        expect(reordered.options).to eq(sort: { "field_three" => 1 })
      end
    end
  end
end
