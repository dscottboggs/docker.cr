module Docker
  class APIClient
    # Limit rate (bytes or iops per second) from a device
    struct ThrottleDevice
      include JSON::Serializable

      def initialize(@path, @rate); end

      @[JSON::Field(key: "Path")]
      property path : String
      @[JSON::Field(key: "Rate")]
      property rate : UInt64
    end
  end
end
