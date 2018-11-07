module Docker
  class APIClient
    # IPAM configurations for an endpoint
    class IPAMConfig
      include JSON::Serializable
      @[JSON::Field(key: "IPv4Address")]
      property ipv4_address : String
      @[JSON::Field(key: "IPv6Address")]
      property ipv6_address : String
      @[JSON::Field(key: "LinkLocalIPs")]
      property link_local_ips : Array(String)
    end
  end
end
