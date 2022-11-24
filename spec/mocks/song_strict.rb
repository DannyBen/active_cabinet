module Mocks
  class SongStrict < ActiveCabinet
    required_attributes :title, :artist
    optional_attributes false
  end
end
