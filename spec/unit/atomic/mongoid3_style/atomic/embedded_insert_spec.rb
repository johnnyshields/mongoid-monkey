require "spec_helper"

if Mongoid::VERSION =~ /\A3\./

describe Mongoid::Relations::Embedded::Many do

  [ :<<, :push ].each do |method|

    describe "##{method}" do

      context "when the parent is a new record" do

        let(:person) do
          Person.new
        end

        let(:address) do
          Address.new
        end

        let!(:added) do
          person.addresses.send(method, address)
        end

        it "appends to the target" do
          person.addresses.should eq([ address ])
        end

        it "sets the base on the inverse relation" do
          address.addressable.should eq(person)
        end

        it "sets the same instance on the inverse relation" do
          address.addressable.should eql(person)
        end

        it "does not save the new document" do
          address.should_not be_persisted
        end

        it "sets the parent on the child" do
          address._parent.should eq(person)
        end

        it "sets the metadata on the child" do
          address.metadata.should_not be_nil
        end

        it "sets the index on the child" do
          address._index.should eq(0)
        end

        it "returns the relation" do
          added.should eq(person.addresses)
        end

        context "with a limiting default scope" do

          context "when the document matches the scope" do

            let(:active) do
              Appointment.new
            end

            before do
              person.appointments.send(method, active)
            end

            it "appends to the target" do
              person.appointments.target.should eq([ active ])
            end

            it "appends to the _unscoped" do
              person.appointments.send(:_unscoped).should eq([ active ])
            end
          end

          context "when the document does not match the scope" do

            let(:inactive) do
              Appointment.new(active: false)
            end

            before do
              person.appointments.send(method, inactive)
            end

            it "doesn't append to the target" do
              person.appointments.target.should_not eq([ inactive ])
            end

            it "appends to the _unscoped" do
              person.appointments.send(:_unscoped).should eq([ inactive ])
            end
          end
        end
      end

      context "when the parent is not a new record" do

        let(:person) do
          Person.create
        end

        let(:address) do
          Address.new
        end

        before do
          person.addresses.send(method, address)
        end

        it "saves the new document" do
          address.should be_persisted
        end
      end

      context "when appending more than one document at once" do

        let(:person) do
          Person.create
        end

        let(:address_one) do
          Address.new
        end

        let(:address_two) do
          Address.new
        end

        let!(:added) do
          person.addresses.send(method, [ address_one, address_two ])
        end

        it "saves the first document" do
          address_one.should be_persisted
        end

        it "saves the second document" do
          address_two.should be_persisted
        end

        it "returns the relation" do
          added.should eq(person.addresses)
        end
      end

      context "when the parent and child have a cyclic relation" do

        context "when the parent is a new record" do

          let(:parent_role) do
            Role.new
          end

          let(:child_role) do
            Role.new
          end

          before do
            parent_role.child_roles.send(method, child_role)
          end

          it "appends to the target" do
            parent_role.child_roles.should eq([ child_role ])
          end

          it "sets the base on the inverse relation" do
            child_role.parent_role.should eq(parent_role)
          end

          it "sets the same instance on the inverse relation" do
            child_role.parent_role.should eql(parent_role)
          end

          it "does not save the new document" do
            child_role.should_not be_persisted
          end

          it "sets the parent on the child" do
            child_role._parent.should eq(parent_role)
          end

          it "sets the metadata on the child" do
            child_role.metadata.should_not be_nil
          end

          it "sets the index on the child" do
            child_role._index.should eq(0)
          end
        end

        context "when the parent is not a new record" do

          let(:parent_role) do
            Role.create(name: "CEO")
          end

          let(:child_role) do
            Role.new(name: "COO")
          end

          before do
            parent_role.child_roles.send(method, child_role)
          end

          it "saves the new document" do
            child_role.should be_persisted
          end
        end
      end
    end
  end

  describe "#concat" do

    context "when the parent is a new record" do

      let(:person) do
        Person.new
      end

      let(:address) do
        Address.new
      end

      before do
        person.addresses.concat([ address ])
      end

      it "appends to the target" do
        person.addresses.should eq([ address ])
      end

      it "appends to the unscoped" do
        person.addresses.send(:_unscoped).should eq([ address ])
      end

      it "sets the base on the inverse relation" do
        address.addressable.should eq(person)
      end

      it "sets the same instance on the inverse relation" do
        address.addressable.should eql(person)
      end

      it "does not save the new document" do
        address.should_not be_persisted
      end

      it "sets the parent on the child" do
        address._parent.should eq(person)
      end

      it "sets the metadata on the child" do
        address.metadata.should_not be_nil
      end

      it "sets the index on the child" do
        address._index.should eq(0)
      end
    end

    context "when the parent is not a new record" do

      let(:person) do
        Person.create
      end

      let(:address) do
        Address.new
      end

      before do
        person.addresses.concat([ address ])
      end

      it "saves the new document" do
        address.should be_persisted
      end
    end

    context "when concatenating an empty array" do

      let(:person) do
        Person.create
      end

      before do
        person.addresses.should_not_receive(:batch_insert)
        person.addresses.concat([])
      end

      it "doesn't update the target" do
        person.addresses.should be_empty
      end
    end

    context "when appending more than one document at once" do

      let(:person) do
        Person.create
      end

      let(:address_one) do
        Address.new
      end

      let(:address_two) do
        Address.new
      end

      before do
        person.addresses.concat([ address_one, address_two ])
      end

      it "saves the first document" do
        address_one.should be_persisted
      end

      it "saves the second document" do
        address_two.should be_persisted
      end
    end

    context "when the parent and child have a cyclic relation" do

      context "when the parent is a new record" do

        let(:parent_role) do
          Role.new
        end

        let(:child_role) do
          Role.new
        end

        before do
          parent_role.child_roles.concat([ child_role ])
        end

        it "appends to the target" do
          parent_role.child_roles.should eq([ child_role ])
        end

        it "sets the base on the inverse relation" do
          child_role.parent_role.should eq(parent_role)
        end

        it "sets the same instance on the inverse relation" do
          child_role.parent_role.should eql(parent_role)
        end

        it "does not save the new document" do
          child_role.should_not be_persisted
        end

        it "sets the parent on the child" do
          child_role._parent.should eq(parent_role)
        end

        it "sets the metadata on the child" do
          child_role.metadata.should_not be_nil
        end

        it "sets the index on the child" do
          child_role._index.should eq(0)
        end
      end

      context "when the parent is not a new record" do

        let(:parent_role) do
          Role.create(name: "CEO")
        end

        let(:child_role) do
          Role.new(name: "COO")
        end

        before do
          parent_role.child_roles.concat([ child_role ])
        end

        it "saves the new document" do
          child_role.should be_persisted
        end
      end
    end
  end

  describe "#count" do

    let(:person) do
      Person.create
    end

    before do
      person.addresses.create(street: "Upper")
      person.addresses.build(street: "Bond")
    end

    it "returns the number of persisted documents" do
      person.addresses.count.should eq(1)
    end
  end

  describe "#max" do

    let(:person) do
      Person.new
    end

    let(:address_one) do
      Address.new(number: 5)
    end

    let(:address_two) do
      Address.new(number: 10)
    end

    before do
      person.addresses.push(address_one, address_two)
    end

    let(:max) do
      person.addresses.max do |a,b|
        a.number <=> b.number
      end
    end

    it "returns the document with the max value of the supplied field" do
      max.should eq(address_two)
    end
  end

  describe "#max_by" do

    let(:person) do
      Person.new
    end

    let(:address_one) do
      Address.new(number: 5)
    end

    let(:address_two) do
      Address.new(number: 10)
    end

    before do
      person.addresses.push(address_one, address_two)
    end

    let(:max) do
      person.addresses.max_by(&:number)
    end

    it "returns the document with the max value of the supplied field" do
      max.should eq(address_two)
    end
  end

  describe "#min" do

    let(:person) do
      Person.new
    end

    let(:address_one) do
      Address.new(number: 5)
    end

    let(:address_two) do
      Address.new(number: 10)
    end

    before do
      person.addresses.push(address_one, address_two)
    end

    let(:min) do
      person.addresses.min do |a,b|
        a.number <=> b.number
      end
    end

    it "returns the min value of the supplied field" do
      min.should eq(address_one)
    end
  end

  describe "#min_by" do

    let(:person) do
      Person.new
    end

    let(:address_one) do
      Address.new(number: 5)
    end

    let(:address_two) do
      Address.new(number: 10)
    end

    before do
      person.addresses.push(address_one, address_two)
    end

    let(:min) do
      person.addresses.min_by(&:number)
    end

    it "returns the min value of the supplied field" do
      min.should eq(address_one)
    end
  end

  context "when deeply embedding documents" do

    context "when updating the bottom level" do

      let!(:person) do
        Person.create
      end

      let!(:address) do
        person.addresses.create(street: "Joachimstr")
      end

      let!(:location) do
        address.locations.create(name: "work")
      end

      context "when updating with a hash" do

        before do
          address.update_attributes(locations: [{ name: "home" }])
        end

        it "updates the attributes" do
          address.locations.first.name.should eq("home")
        end

        it "overwrites the existing documents" do
          address.locations.count.should eq(1)
        end

        it "persists the changes" do
          address.reload.locations.count.should eq(1)
        end
      end
    end

    context "when building the tree through hashes" do

      let(:circus) do
        Circus.new(hash)
      end

      let(:animal) do
        circus.animals.first
      end

      let(:animal_name) do
        "Lion"
      end

      let(:tag_list) do
        "tigers, bears, oh my"
      end

      context "when the hash uses stringified keys" do

        let(:hash) do
          { 'animals' => [{ 'name' => animal_name, 'tag_list' => tag_list }] }
        end

        it "sets up the hierarchy" do
          animal.circus.should eq(circus)
        end

        it "assigns the attributes" do
          animal.name.should eq(animal_name)
        end

        it "uses custom writer methods" do
          animal.tag_list.should eq(tag_list)
        end
      end

      context "when the hash uses symbolized keys" do

        let(:hash) do
          { animals: [{ name: animal_name, tag_list: tag_list }] }
        end

        it "sets up the hierarchy" do
          animal.circus.should eq(circus)
        end

        it "assigns the attributes" do
          animal.name.should eq(animal_name)
        end

        it "uses custom writer methods" do
          animal.tag_list.should eq(tag_list)
        end
      end
    end

    context "when building the tree through pushes" do

      let(:quiz) do
        Quiz.new
      end

      let(:page) do
        Page.new
      end

      let(:page_question) do
        PageQuestion.new
      end

      before do
        quiz.pages << page
        page.page_questions << page_question
      end

      let(:question) do
        quiz.pages.first.page_questions.first
      end

      it "sets up the hierarchy" do
        question.should eq(page_question)
      end
    end

    context "when building the tree through builds" do

      let!(:quiz) do
        Quiz.new
      end

      let!(:page) do
        quiz.pages.build
      end

      let!(:page_question) do
        page.page_questions.build
      end

      let(:question) do
        quiz.pages.first.page_questions.first
      end

      it "sets up the hierarchy" do
        question.should eq(page_question)
      end
    end

    context "when creating a persisted tree" do

      let(:quiz) do
        Quiz.create
      end

      let(:page) do
        Page.new
      end

      let(:page_question) do
        PageQuestion.new
      end

      let(:question) do
        quiz.pages.first.page_questions.first
      end

      before do
        quiz.pages << page
        page.page_questions << page_question
      end

      it "sets up the hierarchy" do
        question.should eq(page_question)
      end

      context "when reloading" do

        let(:from_db) do
          quiz.reload
        end

        let(:reloaded_question) do
          from_db.pages.first.page_questions.first
        end

        it "reloads the entire tree" do
          reloaded_question.should eq(question)
        end
      end
    end
  end

  context "when deeply nesting documents" do

    context "when all documents are new" do

      let(:person) do
        Person.new
      end

      let(:address) do
        Address.new
      end

      let(:location) do
        Location.new
      end

      before do
        address.locations << location
        person.addresses << address
      end

      context "when saving the root" do

        before do
          person.save
        end

        it "persists the first level document" do
          person.reload.addresses.first.should eq(address)
        end

        it "persists the second level document" do
          person.reload.addresses[0].locations.should eq([ location ])
        end
      end
    end
  end

  context "when attempting nil pushes and substitutes" do

    let(:home_phone) do
      Phone.new(number: "555-555-5555")
    end

    let(:office_phone) do
      Phone.new(number: "666-666-6666")
    end

    describe "replacing the entire embedded list" do

      context "when an embeds many relationship contains a nil as the first item" do

        let(:person) do
          Person.create!
        end

        let(:phone_list) do
          [nil, home_phone, office_phone]
        end

        before do
          person.phone_numbers = phone_list
          person.save!
        end

        it "ignores the nil and persist the remaining items" do
          reloaded = Person.find(person.id)
          reloaded.phone_numbers.should eq([ home_phone, office_phone ])
        end
      end

      context "when an embeds many relationship contains a nil in the middle of the list" do

        let(:person) do
          Person.create!
        end

        let(:phone_list) do
          [home_phone, nil, office_phone]
        end

        before do
          person.phone_numbers = phone_list
          person.save!
        end

        it "ignores the nil and persist the remaining items" do
          reloaded = Person.find(person.id)
          reloaded.phone_numbers.should eq([ home_phone, office_phone ])
        end
      end

      context "when an embeds many relationship contains a nil at the end of the list" do

        let(:person) do
          Person.create!
        end

        let(:phone_list) do
          [home_phone, office_phone, nil]
        end

        before do
          person.phone_numbers = phone_list
          person.save!
        end

        it "ignores the nil and persist the remaining items" do
          reloaded = Person.find(person.id)
          reloaded.phone_numbers.should eq([ home_phone, office_phone ])
        end
      end
    end

    describe "appending to the embedded list" do

      context "when appending a nil to the first position in an embedded list" do

        let(:person) do
          Person.create! phone_numbers: []
        end

        before do
          person.phone_numbers << nil
          person.phone_numbers << home_phone
          person.phone_numbers << office_phone
          person.save!
        end

        it "ignores the nil and persist the remaining items" do
          reloaded = Person.find(person.id)
          reloaded.phone_numbers.should eq(person.phone_numbers)
        end
      end

      context "when appending a nil into the middle of an embedded list" do

        let(:person) do
          Person.create! phone_numbers: []
        end

        before do
          person.phone_numbers << home_phone
          person.phone_numbers << nil
          person.phone_numbers << office_phone
          person.save!
        end

        it "ignores the nil and persist the remaining items" do
          reloaded = Person.find(person.id)
          reloaded.phone_numbers.should eq(person.phone_numbers)
        end
      end

      context "when appending a nil to the end of an embedded list" do

        let(:person) do
          Person.create! phone_numbers: []
        end

        before do
          person.phone_numbers << home_phone
          person.phone_numbers << office_phone
          person.phone_numbers << nil
          person.save!
        end

        it "ignores the nil and persist the remaining items" do
          reloaded = Person.find(person.id)
          reloaded.phone_numbers.should eq(person.phone_numbers)
        end
      end
    end
  end

  context "when moving an embedded document from one parent to another" do

    let!(:person_one) do
      Person.create
    end

    let!(:person_two) do
      Person.create
    end

    let!(:address) do
      person_one.addresses.create(street: "Kudamm")
    end

    before do
      person_two.addresses << address
    end

    it "adds the document to the new paarent" do
      person_two.addresses.should eq([ address ])
    end

    it "sets the new parent on the document" do
      address._parent.should eq(person_two)
    end

    context "when reloading the documents" do

      before do
        person_one.reload
        person_two.reload
      end

      it "persists the change to the new parent" do
        person_two.addresses.should eq([ address ])
      end

      it "keeps the address on the previous document" do
        person_one.addresses.should eq([ address ])
      end
    end
  end

  context "when the relation has a default scope" do

    let!(:person) do
      Person.create
    end

    context "when the default scope is a sort" do

      let(:cough) do
        Symptom.new(name: "cough")
      end

      let(:headache) do
        Symptom.new(name: "headache")
      end

      let(:nausea) do
        Symptom.new(name: "nausea")
      end

      before do
        person.symptoms.concat([ nausea, cough, headache ])
      end

      context "when accessing the relation" do

        let(:symptoms) do
          person.reload.symptoms
        end

        it "applies the default scope" do
          symptoms.should eq([ cough, headache, nausea ])
        end
      end

      context "when modifying the relation" do

        let(:constipation) do
          Symptom.new(name: "constipation")
        end

        before do
          person.symptoms.push(constipation)
        end

        context "when reloading" do

          let(:symptoms) do
            person.reload.symptoms
          end

          it "applies the default scope" do
            symptoms.should eq([ constipation, cough, headache, nausea ])
          end
        end
      end

      context "when unscoping the relation" do

        let(:unscoped) do
          person.reload.symptoms.unscoped
        end

        it "removes the default scope" do
          unscoped.should eq([ nausea, cough, headache ])
        end
      end
    end
  end

  context "when the embedded document has an array field" do

    let!(:person) do
      Person.create
    end

    let!(:video) do
      person.videos.create
    end

    context "when saving the array on a persisted document" do

      before do
        video.genres = [ "horror", "scifi" ]
        video.save
      end

      it "sets the value" do
        video.genres.should eq([ "horror", "scifi" ])
      end

      it "persists the value" do
        video.reload.genres.should eq([ "horror", "scifi" ])
      end

      context "when reloading the parent" do

        let!(:loaded_person) do
          Person.find(person.id)
        end

        let!(:loaded_video) do
          loaded_person.videos.find(video.id)
        end

        context "when writing a new array value" do

          before do
            loaded_video.genres = [ "comedy" ]
            loaded_video.save
          end

          it "sets the new value" do
            loaded_video.genres.should eq([ "comedy" ])
          end

          it "persists the new value" do
            loaded_video.reload.genres.should eq([ "comedy" ])
          end
        end
      end
    end
  end

  context "when adding a document" do

    let(:person) do
      Person.new
    end

    let(:address_one) do
      Address.new(street: "hobrecht")
    end

    let(:first_add) do
      person.addresses.push(address_one)
    end

    context "when chaining a second add" do

      let(:address_two) do
        Address.new(street: "friedel")
      end

      let(:result) do
        first_add.push(address_two)
      end

      it "adds both documents" do
        result.should eq([ address_one, address_two ])
      end
    end
  end

  context "when using dot notation in a criteria" do

    let(:person) do
      Person.new
    end

    let!(:address) do
      person.addresses.build(street: "hobrecht")
    end

    let!(:location) do
      address.locations.build(number: 5)
    end

    let(:criteria) do
      person.addresses.where("locations.number" => { "$gt" => 3 })
    end

    it "allows the dot notation criteria" do
      criteria.should eq([ address ])
    end
  end

  context "when updating multiple levels in one update" do

    let!(:person) do
      Person.create(
          addresses: [
              { locations: [{ name: "home" }]}
          ]
      )
    end

    context "when updating with hashes" do

      let(:from_db) do
        Person.find(person.id)
      end

      before do
        from_db.update_attributes(
            addresses: [
                { locations: [{ name: "work" }]}
            ]
        )
      end

      let(:updated) do
        person.reload.addresses.first.locations.first
      end

      it "updates the nested document" do
        updated.name.should eq("work")
      end
    end
  end

  context "when pushing with a before_add callback" do

    let(:artist) do
      Artist.new
    end

    let(:song) do
      Song.new
    end

    context "when no errors are raised" do

      before do
        artist.songs << song
      end

      it "executes the callback" do
        artist.before_add_called.should eq true
      end

      it "executes the callback as proc" do
        song.before_add_called.should eq true
      end

      it "adds the document to the relation" do
        artist.songs.should eq([song])
      end
    end

    context "with errors" do

      before do
        artist.should_receive(:before_add_song).and_raise
      end

      it "does not add the document to the relation" do
        expect {
          artist.songs << song
        }.to raise_error
        artist.songs.should be_empty
      end
    end
  end

  context "when pushing with an after_add callback" do

    let(:artist) do
      Artist.new
    end

    let(:label) do
      Label.new
    end

    it "executes the callback" do
      artist.labels << label
      artist.after_add_called.should eq true
    end

    context "when errors are raised" do

      before do
        artist.should_receive(:after_add_label).and_raise
      end

      it "adds the document to the relation" do
        expect {
          artist.labels << label
        }.to raise_error
        artist.labels.should eq([ label ])
      end
    end
  end
end

end
