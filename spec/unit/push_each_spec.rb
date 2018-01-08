require "spec_helper"

if Mongoid::VERSION =~ /\A3\./

describe Mongoid::Atomic do

  describe "#add_atomic_pull" do

    let!(:person) do
      Person.create
    end

    let(:address) do
      person.addresses.create
    end

    let(:location) do
      address.locations.create
    end

    before do
      person.add_atomic_pull(address)
    end

    it "adds the document to the delayed atomic pulls" do
      expect(person.delayed_atomic_pulls["addresses"]).to eq([ address ])
    end

    it "flags the document for destruction" do
      expect(address).to be_flagged_for_destroy
    end
  end

  describe "#add_atomic_unset" do

    let!(:person) do
      Person.new
    end

    let(:name) do
      person.build_name
    end

    before do
      person.add_atomic_unset(name)
    end

    it "adds the document to the delayed atomic unsets" do
      expect(person.delayed_atomic_unsets["name"]).to eq([ name ])
    end

    it "flags the document for destruction" do
      expect(name).to be_flagged_for_destroy
    end
  end

  describe "#atomic_updates" do

    context "when the document is persisted" do

      let(:person) do
        Person.create
      end

      context "when the document is modified" do

        before do
          person.title = "Sir"
        end

        it "returns the atomic updates" do
          expect(person.atomic_updates).to eq({ "$set" => { "title" => "Sir" }})
        end

        context "when an embeds many child is added" do

          let!(:address) do
            person.addresses.build(street: "Oxford St")
          end

          it "returns a $set and $push for modifications" do
            expect(person.atomic_updates).to eq(
                                                 {
                                                     "$set" => { "title" => "Sir" },
                                                     "$push" => { "addresses" => { "$each" => [{ "_id" => address._id, "street" => "Oxford St" }] } }
                                                 }
                                             )
          end
        end

        context "when an embeds one child is added" do

          let!(:name) do
            person.build_name(first_name: "Lionel")
          end

          it "returns a $set for modifications" do
            expect(person.atomic_updates).to eq(
                                                 {
                                                     "$set" => {
                                                         "title" => "Sir",
                                                         "name" => { "_id" => name._id, "first_name" => "Lionel" }
                                                     }
                                                 }
                                             )
          end
        end

        context "when an existing embeds many gets modified" do

          let!(:address) do
            person.addresses.create(street: "Oxford St")
          end

          before do
            address.street = "Bond St"
          end

          context "when asking for the updates from the root" do

            it "returns the $set with correct position and modifications" do
              expect(person.atomic_updates).to eq(
                                                   { "$set" => { "title" => "Sir", "addresses.0.street" => "Bond St" }}
                                               )
            end
          end

          context "when asking for the updates from the child" do

            it "returns the $set with correct position and modifications" do
              expect(address.atomic_updates).to eq(
                                                    { "$set" => { "addresses.0.street" => "Bond St" }}
                                                )
            end
          end

          context "when an existing 2nd level embedded child gets modified" do

            let!(:location) do
              address.locations.create(name: "Home")
            end

            before do
              location.name = "Work"
            end

            context "when asking for the updates from the root" do

              it "returns the $set with correct positions and modifications" do
                expect(person.atomic_updates).to eq(
                                                     { "$set" => {
                                                         "title" => "Sir",
                                                         "addresses.0.street" => "Bond St",
                                                         "addresses.0.locations.0.name" => "Work" }
                                                     }
                                                 )
              end
            end

            context "when asking for the updates from the 1st level child" do

              it "returns the $set with correct positions and modifications" do
                expect(address.atomic_updates).to eq(
                                                      { "$set" => {
                                                          "addresses.0.street" => "Bond St",
                                                          "addresses.0.locations.0.name" => "Work" }
                                                      }
                                                  )
              end
            end

            context "when asking for the updates from the 2nd level child" do

              it "returns the $set with correct positions and modifications" do
                expect(location.atomic_updates).to eq(
                                                       { "$set" => {
                                                           "addresses.0.locations.0.name" => "Work" }
                                                       }
                                                   )
              end
            end
          end

          context "when a 2nd level embedded child gets added" do

            let!(:location) do
              address.locations.build(name: "Home")
            end

            context "when asking for the updates from the root" do

              it "returns the $set with correct positions and modifications" do
                expect(person.atomic_updates).to eq(
                                                     {
                                                         "$set" => {
                                                             "title" => "Sir",
                                                             "addresses.0.street" => "Bond St"
                                                         },
                                                         conflicts: {
                                                             "$push" => {
                                                                 "addresses.0.locations" => { "$each" => [{ "_id" => location.id, "name" => "Home" }] }
                                                             }
                                                         }
                                                     }
                                                 )
              end
            end

            context "when asking for the updates from the 1st level child" do

              it "returns the $set with correct positions and modifications" do
                expect(address.atomic_updates).to eq(
                                                      {
                                                          "$set" => {
                                                              "addresses.0.street" => "Bond St"
                                                          },
                                                          conflicts: {
                                                              "$push" => {
                                                                  "addresses.0.locations" => { "$each" => [{ "_id" => location.id, "name" => "Home" }] }
                                                              }
                                                          }
                                                      }
                                                  )
              end
            end
          end

          context "when an embedded child gets unset" do

            before do
              person.attributes = { addresses: nil }
            end

            let(:updates) do
              person.atomic_updates
            end

            it "returns the $set for the first level and $unset for other." do
              expect(updates).to eq({
                                        "$unset" => { "addresses" => true },
                                        "$set" => { "title" => "Sir" }
                                    })
            end
          end

          context "when adding a new second level child" do

            let!(:new_address) do
              person.addresses.build(street: "Another")
            end

            let!(:location) do
              new_address.locations.build(name: "Home")
            end

            context "when asking for the updates from the root document" do

              it "returns the $set for 1st level and other for the 2nd level" do
                expect(person.atomic_updates).to eq(
                                                     {
                                                         "$set" => {
                                                             "title" => "Sir",
                                                             "addresses.0.street" => "Bond St"
                                                         },
                                                         conflicts: {
                                                             "$push" => {
                                                                 "addresses" => { "$each" => [{
                                                                                                  "_id" => new_address.id,
                                                                                                  "street" => "Another",
                                                                                                  "locations" => [
                                                                                                      "_id" => location.id,
                                                                                                      "name" => "Home"
                                                                                                  ]
                                                                                              }] }
                                                             }
                                                         }
                                                     }
                                                 )
              end
            end

            context "when asking for the updates from the 1st level document" do

              it "returns the $set for 1st level and other for the 2nd level" do
                expect(address.atomic_updates).to eq(
                                                      { "$set" => { "addresses.0.street" => "Bond St" }}
                                                  )
              end
            end
          end

          context "when adding a new child beetween two existing and updating one of them" do

            let!(:new_address) do
              person.addresses.build(street: "Ipanema")
            end

            let!(:location) do
              new_address.locations.build(name: "Home")
            end

            before do
              person.addresses[0] = new_address
              person.addresses[1] = address
            end

            it "returns the $set for 1st and 2nd level and other for the 3nd level" do
              expect(person.atomic_updates).to eq(
                                                   {
                                                       "$set" => {
                                                           "title" => "Sir"
                                                       },
                                                       "$push" => {
                                                           "addresses" => { "$each" => [{
                                                                                            "_id" => new_address.id,
                                                                                            "street" => "Ipanema",
                                                                                            "locations" => [
                                                                                                "_id" => location.id,
                                                                                                "name" => "Home"
                                                                                            ]
                                                                                        }] }
                                                       },
                                                       conflicts: {
                                                           "$set" => { "addresses.0.street"=>"Bond St" }
                                                       }
                                                   }
                                               )
            end
          end
        end

        context "when adding new embedded docs at multiple levels" do

          let!(:address) do
            person.addresses.build(street: "Another")
          end

          let!(:location) do
            address.locations.build(name: "Home")
          end

          it "returns the proper $sets and $pushes for all levels" do
            expect(person.atomic_updates).to eq(
                                                 {
                                                     "$set" => {
                                                         "title" => "Sir",
                                                     },
                                                     "$push" => {
                                                         "addresses" => { "$each" => [{
                                                                                          "_id" => address.id,
                                                                                          "street" => "Another",
                                                                                          "locations" => [
                                                                                              "_id" => location.id,
                                                                                              "name" => "Home"
                                                                                          ]
                                                                                      }] }
                                                     }
                                                 }
                                             )
          end
        end
      end
    end
  end
end

describe Mongoid::Atomic::Modifiers do

  let(:modifiers) do
    described_class.new
  end

  describe "#add_to_set" do

    context "when the unique adds are empty" do

      before do
        modifiers.add_to_set({})
      end

      it "does not contain any operations" do
        expect(modifiers).to eq({})
      end
    end

    context "when the adds are not empty" do

      let(:adds) do
        { "preference_ids" => [ "one", "two" ] }
      end

      context "when adding a single field" do

        before do
          modifiers.add_to_set(adds)
        end

        it "adds the add to set with each modifiers" do
          expect(modifiers).to eq({
                                      "$addToSet" => { "preference_ids" => { "$each" => [ "one", "two" ] }}
                                  })
        end
      end

      context "when adding to an existing field" do

        let(:adds_two) do
          { "preference_ids" => [ "three" ] }
        end

        before do
          modifiers.add_to_set(adds)
          modifiers.add_to_set(adds_two)
        end

        it "adds the add to set with each modifiers" do
          expect(modifiers).to eq({
                                      "$addToSet" =>
                                          { "preference_ids" =>
                                                { "$each" => [ "one", "two", "three" ] }
                                          }
                                  })
        end
      end
    end
  end

  describe "#pull" do

    context "when the pulls are empty" do

      before do
        modifiers.pull({})
      end

      it "does not contain any pull operations" do
        expect(modifiers).to eq({})
      end
    end

    context "when no conflicting modifications are present" do

      context "when adding a single pull" do

        let(:pulls) do
          { "addresses" => { "_id" => { "$in" => [ "one" ]}} }
        end

        before do
          modifiers.pull(pulls)
        end

        it "adds the push all modifiers" do
          expect(modifiers).to eq(
                                   { "$pull" => { "addresses" => { "_id" => { "$in" => [ "one" ]}}}}
                               )
        end
      end

      context "when adding to an existing pull" do

        let(:pull_one) do
          { "addresses" => { "_id" => { "$in" => [ "one" ]}} }
        end

        let(:pull_two) do
          { "addresses" => { "_id" => { "$in" => [ "two" ]}} }
        end

        before do
          modifiers.pull(pull_one)
          modifiers.pull(pull_two)
        end

        it "overwrites the previous pulls" do
          expect(modifiers).to eq(
                                   { "$pull" => { "addresses" => { "_id" => { "$in" => [ "two" ]}}}}
                               )
        end
      end
    end
  end

  describe "#pull_all" do

    context "when the pulls are empty" do

      before do
        modifiers.pull_all({})
      end

      it "does not contain any pull operations" do
        expect(modifiers).to eq({})
      end
    end

    context "when no conflicting modifications are present" do

      context "when adding a single pull" do

        let(:pulls) do
          { "addresses" => [{ "_id" => "one" }] }
        end

        before do
          modifiers.pull_all(pulls)
        end

        it "adds the push all modifiers" do
          expect(modifiers).to eq(
                                   { "$pullAll" =>
                                         { "addresses" => [
                                             { "_id" => "one" }
                                         ]
                                         }
                                   }
                               )
        end
      end

      context "when adding to an existing pull" do

        let(:pull_one) do
          { "addresses" => [{ "street" => "Hobrechtstr." }] }
        end

        let(:pull_two) do
          { "addresses" => [{ "street" => "Pflugerstr." }] }
        end

        before do
          modifiers.pull_all(pull_one)
          modifiers.pull_all(pull_two)
        end

        it "adds the pull all modifiers" do
          expect(modifiers).to eq(
                                   { "$pullAll" =>
                                         { "addresses" => [
                                             { "street" => "Hobrechtstr." },
                                             { "street" => "Pflugerstr." }
                                         ]
                                         }
                                   }
                               )
        end
      end
    end
  end

  describe "#push" do

    context "when the pushes are empty" do

      before do
        modifiers.push({})
      end

      it "does not contain any push operations" do
        expect(modifiers).to eq({})
      end
    end

    context "when no conflicting modification is present" do

      context "when adding a single push" do

        let(:pushes) do
          { "addresses" => { "street" => "Oxford St" } }
        end

        before do
          modifiers.push(pushes)
        end

        it "adds the push all modifiers" do
          expect(modifiers).to eq(
                                   { "$push" =>
                                         { "addresses" => { "$each" => [{ "street" => "Oxford St" }] } }
                                   }
                               )
        end
      end

      context "when adding to an existing push" do

        let(:push_one) do
          { "addresses" => { "street" => "Hobrechtstr." } }
        end

        let(:push_two) do
          { "addresses" => { "street" => "Pflugerstr." } }
        end

        before do
          modifiers.push(push_one)
          modifiers.push(push_two)
        end

        it "adds the push all modifiers" do
          expect(modifiers).to eq(
                                   { "$push" =>
                                         { "addresses" => { "$each" => [
                                             { "street" => "Hobrechtstr." },
                                             { "street" => "Pflugerstr." }
                                         ] }
                                         }
                                   }
                               )
        end
      end
    end

    context "when a conflicting modification exists" do

      context "when the conflicting modification is a set" do

        let(:sets) do
          { "addresses.0.street" => "Bond" }
        end

        let(:pushes) do
          { "addresses" => { "street" => "Oxford St" } }
        end

        before do
          modifiers.set(sets)
          modifiers.push(pushes)
        end

        it "adds the push all modifiers to the conflicts hash" do
          expect(modifiers).to eq(
                                   { "$set" => { "addresses.0.street" => "Bond" },
                                     conflicts: { "$push" =>
                                                      { "addresses" => { "$each" => [{ "street" => "Oxford St" }] } }
                                     }
                                   }
                               )
        end
      end

      context "when the conflicting modification is a pull" do

        let(:pulls) do
          { "addresses" => { "street" => "Bond St" } }
        end

        let(:pushes) do
          { "addresses" => { "street" => "Oxford St" } }
        end

        before do
          modifiers.pull_all(pulls)
          modifiers.push(pushes)
        end

        it "adds the push all modifiers to the conflicts hash" do
          expect(modifiers).to eq(
                                   { "$pullAll" => {
                                       "addresses" => { "street" => "Bond St" }},
                                     conflicts: { "$push" =>
                                                      { "addresses" => { "$each" => [{ "street" => "Oxford St" }] } }
                                     }
                                   }
                               )
        end
      end

      context "when the conflicting modification is a push" do

        let(:nested) do
          { "addresses.0.locations" => { "street" => "Bond St" } }
        end

        let(:pushes) do
          { "addresses" => { "street" => "Oxford St" } }
        end

        before do
          modifiers.push(nested)
          modifiers.push(pushes)
        end

        it "adds the push all modifiers to the conflicts hash" do
          expect(modifiers).to eq(
                                   { "$push" => {
                                       "addresses.0.locations" => { "$each" => [{ "street" => "Bond St" }] } },
                                     conflicts: { "$push" =>
                                                      { "addresses" => { "$each" => [{ "street" => "Oxford St" }] } }
                                     }
                                   }
                               )
        end
      end
    end
  end

  describe "#set" do

    describe "when adding to the root level" do

      context "when no conflicting mods exist" do

        context "when the sets have values" do

          let(:sets) do
            { "title" => "Sir" }
          end

          before do
            modifiers.set(sets)
          end

          it "adds the sets to the modifiers" do
            expect(modifiers).to eq({ "$set" => { "title" => "Sir" } })
          end
        end

        context "when the sets contain an id" do

          let(:sets) do
            { "_id" => Moped::BSON::ObjectId.new }
          end

          before do
            modifiers.set(sets)
          end

          it "does not include the id sets" do
            expect(modifiers).to eq({})
          end
        end

        context "when the sets are empty" do

          before do
            modifiers.set({})
          end

          it "does not contain set operations" do
            expect(modifiers).to eq({})
          end
        end
      end

      context "when a conflicting modification exists" do

        let(:pulls) do
          { "addresses" => [{ "_id" => "one" }] }
        end

        let(:sets) do
          { "addresses.0.title" => "Sir" }
        end

        before do
          modifiers.pull_all(pulls)
          modifiers.set(sets)
        end

        it "adds the set modifiers to the conflicts hash" do
          expect(modifiers).to eq(
                                   { "$pullAll" =>
                                         { "addresses" => [
                                             { "_id" => "one" }
                                         ]
                                         },
                                     conflicts:
                                         { "$set" => { "addresses.0.title" => "Sir" }}
                                   }
                               )
        end
      end
    end
  end

  describe "#unset" do

    describe "when adding to the root level" do

      context "when the unsets have values" do

        let(:unsets) do
          [ "addresses" ]
        end

        before do
          modifiers.unset(unsets)
        end

        it "adds the unsets to the modifiers" do
          expect(modifiers).to eq({ "$unset" => { "addresses" => true } })
        end
      end

      context "when the unsets are empty" do

        before do
          modifiers.unset([])
        end

        it "does not contain unset operations" do
          expect(modifiers).to eq({})
        end
      end
    end
  end
end

end
