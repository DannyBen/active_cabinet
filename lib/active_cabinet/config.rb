class ActiveCabinet
  class Config
    class << self
      attr_writer :dir

      def dir
        @dir ||= 'db'
      end
    end
  end
end