class ActiveCabinet
  # Configure the global behavior of {ActiveCabinet}.
  #
  # @example
  #   # Change the directory where cabinets are stored
  #   ActiveCabinet::Config.dir = "cabinets"
  #
  # @attr_writer [String] dir Sets the base directory for all cabinet files (default +'db'+).
  class Config
    class << self
      attr_writer :dir

      # Returns the base directory for all cabinet files.
      #
      # @return [String] the base directory for all cabinet files.
      def dir
        @dir ||= 'db'
      end
    end
  end
end
