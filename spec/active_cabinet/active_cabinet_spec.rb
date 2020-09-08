require 'spec_helper'

describe ActiveCabinet do
  let(:attributes) {{ id: 99, title: 'Red Balloons' }}
  let(:missing_attributes) {{ id: 99 }}
  let(:disallowed_attributes) {{ id: 99, title: 'Red Balloons', release_year: 'not allowed' }}

  subject { Song.new attributes }
  before { Song.seed }
  after { Song.drop }

  describe '#initialize' do
    it "sets record attributes" do
      expect(subject.title).to eq "Red Balloons"
    end
  end

  describe '#method_missing' do
    context "with attribute_name" do
      it "returns the attribute value" do
        expect(subject.title).to eq "Red Balloons"
      end
    end

    context "with attribute_name?" do
      it "returns true if the attribute is truthy" do
        expect(subject.title?).to be true
      end

      it "returns false if the attribute is falsy" do
        subject.title = false
        expect(subject.title?).to be false
      end
    end

    context "with attribute_name=" do
      it "sets the attribute" do
        subject.title = "Moonchild"
        expect(subject.attributes[:title]).to eq "Moonchild"
      end
    end

    context "with anything else" do
      it "raises NoMethodError" do
        expect { subject.something_else }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#allowed_attributes' do
    it "returns an array of required and optional attributes" do
      expect(subject.allowed_attributes).to match_array [:album, :artist, :id, :title]
    end
  end

  describe '#optional_attributes' do
    it "returns an array of optional attributes" do
      expect(subject.optional_attributes).to match_array [:album, :artist]
    end
  end

  describe '#reload' do
    context "when the object is not stored in the cabinet" do
      it "returns nil" do
        expect(subject.reload).to be_nil
      end
    end

    context "when the object is stored in the cabinet" do
      subject { Song[1] }

      it "reloads the attributes from the cabinet" do
        subject.title = "Moonchild"
        expect(subject.title).to eq "Moonchild"
        subject.reload
        expect(subject.title).to eq "Master of Puppets"
      end

      it "returns the record itself" do
        original = subject
        expect(subject.reload).to eq original
      end
    end
  end

  describe '#required_attributes' do
    it "returns an array of required attributes" do
      expect(subject.required_attributes).to match_array [:id, :title]
    end
  end

  describe '#respond_to_missing?' do
    context "with an argument name that matches an attrribute" do
      it "returns true" do
        expect(subject).to respond_to(:title)
      end

      it "returns true when the argument ends with =" do
        expect(subject).to respond_to(:title=)
      end

      it "returns true when the argument ends with ?" do
        expect(subject).to respond_to(:title?)
      end
    end
    
    context "with an argument name that does not matches an attrribute" do
      it "returns false" do
        expect(subject).not_to respond_to :some_other_thing
      end
    end
  end

  describe '#save' do
    it "saves the record" do
      expect { subject.save }.to change { Song.count }.by 1
    end

    context "when the record is invalid" do
      let(:attributes) { missing_attributes }

      it "does not save the record" do
        expect { subject.save }.not_to change { Song.count }        
      end

      it "returns false" do
        expect(subject.save).to eq false
      end
    end
  end

  describe '#saved?' do
    context "when the record is saved in the cabinet" do
      subject { Song[1] }

      it "returns true" do
        expect(subject).to be_saved
      end
    end

    context "when the record is not saved in the cabinet" do
      it "returns false" do
        expect(subject).not_to be_saved
      end
    end
  end

  describe '#to_h' do
    it "returns the attributes" do
      expect(subject.to_h).to eq subject.attributes
    end
  end

  describe '#update' do
    it "sets new attributes" do
      subject.update anything: 'goes'
      expect(subject.anything).to eq 'goes'
    end
  end

  describe '#update!' do
    it "sets new attributes and saves" do
      subject.update! title: '22 Acacia Avenue', artist: 'Iron Maiden'
      expect(subject.reload.title).to eq '22 Acacia Avenue'
    end
  end

  describe '#valid?' do
    context "when the record is valid" do
      it "returns true" do
        expect(subject).to be_valid
      end
    end

    context "when the record has some missing required attributes" do
      let(:attributes) { missing_attributes }

      it "returns false" do
        expect(subject).not_to be_valid
      end

      it "sets the #error property accordingly" do
        subject.valid?
        expect(subject.error).to eq "missing required attributes: [:title]"
      end
    end

    context "when the record has disallowed attributes" do
      let(:attributes) { disallowed_attributes }

      it "returns false" do
        expect(subject).not_to be_valid
      end

      it "sets the #error property accordingly" do
        subject.valid?
        expect(subject.error).to eq "invalid attributes: [:release_year]"
      end
    end
  end

end
