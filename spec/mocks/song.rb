module Mocks
  class Song < ActiveCabinet
    required_attributes :title
    optional_attributes :artist, :album

    class << self
      def seed
        (1..10).each do |i|
          create id: i, title: "Master of Puppets"
        end
      end
    end
  end
end