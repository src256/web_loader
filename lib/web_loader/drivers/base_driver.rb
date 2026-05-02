module WebLoader
  module Drivers
    class BaseDriver
      def initialize
        @user_agent = nil
        @binary = false
      end

      attr_accessor :user_agent, :binary

      def fetch(url)
        raise NotImplementedError, 'Subclasses must implement the fetch method'
      end

      def driver_name
        raise NotImplementedError, 'Subclasses must implement the driver_name method'
      end

    end
  end
end
