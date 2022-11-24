require 'spec_helper'

describe ActiveCabinet do
  subject { Song }

  let(:attributes) { { id: 99, title: 'Red Balloons' } }
  let(:missing_attributes) { { id: 99 } }
  let(:disallowed_attributes) { { id: 99, title: 'Red Balloons', release_year: 'not allowed' } }

  before { Song.seed }
  after { Song.drop }

  describe '::[]' do
    it 'is an alias to ::find' do
      expect(subject.method(:[])).to eq subject.method(:find)
    end
  end

  describe '::[]=' do
    it 'creates a new record' do
      subject[99] = { title: 'Red Balloons' }
      expect(subject[99].title).to eq 'Red Balloons'
    end
  end

  describe '::all' do
    it 'returns an array of records' do
      expect(subject.all).to be_an Array
      expect(subject.all.first).to be_a Song
    end
  end

  describe '::all_attributes' do
    it 'returns an array of record attributes' do
      expect(subject.all_attributes).to be_an Array
      expect(subject.all_attributes.first).to be_a Hash
      expect(subject.all_attributes.first[:title]).to eq 'Master of Puppets'
    end
  end

  describe '::allowed_attributes' do
    it 'returns an array of required and optional attributes' do
      expect(subject.allowed_attributes).to match_array(%i[id title artist album format])
    end
  end

  describe '::cabinet_name' do
    it 'returns the name of the class, lowercased' do
      expect(subject.cabinet_name).to eq 'mocks_song'
    end

    context 'when the model specifies a different cabinet name' do
      subject { SongCustomCabinet }

      it 'returns this name' do
        expect(subject.cabinet_name).to eq 'my_songs'
      end
    end
  end

  describe '::count' do
    it 'returns the number of records' do
      expect(subject.count).to eq 10
    end
  end

  describe '::cabinet' do
    it 'returns a HashCabinet' do
      expect(subject.cabinet).to be_a HashCabinet
    end
  end

  describe '::create' do
    it 'creates a new record' do
      expect { subject.create attributes }.to change(subject, :count).by 1
      expect(subject[99]).to be_an Song
      expect(subject[99].title).to eq 'Red Balloons'
    end

    it 'returns the reated record' do
      expect(subject.create attributes).to be_a Song
    end

    context 'with missing required attributes' do
      it 'does not save and returns the unsaved record' do
        expect(subject.create missing_attributes).to be_a Song
        expect(subject[99]).to be_nil
      end
    end

    context 'with disallowed attributes' do
      it 'does not save and returns the unsaved record' do
        expect(subject.create disallowed_attributes).to be_a Song
        expect(subject[99]).to be_nil
      end
    end
  end

  describe '::default_attributes' do
    context 'without arguments' do
      it 'returns the default arguments hash' do
        expect(subject.default_attributes).to eq(format: :mp3)
      end
    end

    context 'with arguments' do
      before { @original = subject.default_attributes }
      after  { subject.default_attributes @original }

      it 'sets the default attributes' do
        subject.default_attributes media: :cd
        expect(subject.default_attributes).to eq({ media: :cd })
      end
    end
  end

  describe '::delete' do
    it 'removes a record' do
      expect { subject.delete 2 }.to change(subject, :count).by(-1)
    end
  end

  describe '::delete_if' do
    it 'removes records for which the block returns true' do
      expect { subject.delete_if { |song| song.id > 7 } }
        .to change(subject, :count).by(-3)
    end
  end

  describe '::drop' do
    it 'deletes all records' do
      expect { subject.drop }.to change(subject, :count).by(-10)
    end
  end

  describe '::each' do
    it 'yields all records' do
      subject.each do |record|
        expect(record).to be_a Song
      end
    end
  end

  describe '::empty?' do
    context 'when the collection is not empty' do
      it 'returns false' do
        expect(subject.empty?).to be false
      end
    end

    context 'when the collection is empty' do
      before { subject.drop }

      it 'returns true' do
        expect(subject.empty?).to be true
      end
    end
  end

  describe '::find' do
    it 'returns a record by id' do
      expect(subject.find(2)).to be_a Song
      expect(subject.find(2).id).to eq 2
    end

    context 'when the record is not found' do
      it 'returns nil' do
        expect(subject.find 11).to be_nil
      end
    end

    context 'when a hash is given' do
      it 'returns the first matching object via #where' do
        result = subject.find title: 'Master of Puppets'
        expect(result).to be_a Song
      end
    end
  end

  describe '::first' do
    it 'returns the first object' do
      expect(subject.first).to be_a Song
      expect(subject.first.id).to eq 1
    end
  end

  describe '::keys' do
    it 'returns an array of keys' do
      expect(subject.keys.map(&:to_i).sort).to eq (1..10).to_a
    end
  end

  describe '::last' do
    it 'returns the last object' do
      expect(subject.last).to be_a Song
      expect(subject.last.id).to eq 10
    end
  end

  describe '::optional_attributes' do
    context 'without arguments' do
      it 'returns an array of symbols' do
        expect(subject.optional_attributes).to match_array %i[artist album]
      end
    end

    context 'with arguments' do
      before { @original = subject.optional_attributes }
      after  { subject.optional_attributes @original }

      it 'sets the optional attributes' do
        subject.optional_attributes :cake, :pizza
        expect(subject.optional_attributes).to match_array %i[cake pizza]
      end
    end

    context 'with false as argument' do
      before { @original = subject.optional_attributes }
      after  { subject.optional_attributes @original }

      it 'sets optional_attributes to false' do
        subject.optional_attributes false
        expect(subject.optional_attributes).to be false
      end
    end
  end

  describe '::random' do
    it 'returns a random object' do
      expect(subject.random).to be_a Song
    end
  end

  describe '::required_attributes' do
    context 'without arguments' do
      it 'returns an array of symbols' do
        expect(subject.required_attributes).to match_array %i[id title]
      end
    end

    context 'with arguments' do
      before { @original = subject.required_attributes }
      after  { subject.required_attributes @original }

      it 'sets the required attributes and always adds :id' do
        subject.required_attributes :cake, :pizza
        expect(subject.required_attributes).to match_array %i[id cake pizza]
      end
    end
  end

  describe '::size' do
    it 'returns the number of records' do
      expect(subject.size).to eq 10
    end
  end

  describe '::to_h' do
    it 'returns a hash of all records' do
      expect(subject.to_h).to be_a Hash
      expect(subject.to_h.size).to eq 10
      expect(subject.to_h['2']).to be_a Song
    end
  end

  describe '::where' do
    context 'when no query is provided' do
      it 'returns records matching the block' do
        result = subject.where { |asset| asset.id > 7 }
        expect(result.count).to eq 3
        expect(result.map(&:id)).to match_array [8, 9, 10]
      end
    end

    context 'when a query is provided' do
      it 'returns records matching the key => value pair' do
        result = subject.where title: 'Master of Puppets'
        expect(result.count).to eq 10
        expect(result.first).to be_a Song
      end
    end
  end
end
