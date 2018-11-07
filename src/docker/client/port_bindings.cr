module Docker
  class APIClient
    struct PortBindings
      include JSON::Serializable

      def initialize(@host_ip, @host_port); end

      def initialize(@host_ip, host_port : String)
        @host_port = host_port.to_u16
      end

      # The host IP address
      @[JSON::Field(key: "HostIp")]
      property host_ip : String
      # The host port number
      @[JSON::Field(key: "HostPort")]
      @host_port : UInt16

      def host_port
        @host_port.to_s
      end

      def host_port=(port_number : UInt16 | String)
        @host_port = port_number.to_u16
      end
    end
  end
end
