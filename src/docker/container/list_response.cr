require "../client/networking_config"

module Docker
  class Container
    # an array of ListResponse is received from the docker client when requesting a list
    # of containers. See https://docs.docker.com/engine/api/v1.30/#operation/ContainerList
    class ListResponse
      # In a Docker::Container::ListResponse, a set of ports are received in this format.
      struct PortConfig
        include JSON::Serializable
        @[JSON::Field(key: "IP")]
        property ip : String?
        @[JSON::Field(key: "PrivatePort")]
        property private_port : String?
        @[JSON::Field(key: "PublicPort")]
        property public_port : String?
        @[JSON::Field(key: "Type")]
        property type : String?
      end

      include JSON::Serializable
      @[JSON::Field(key: "Id")]
      # The ID of this container
      property id : String
      @[JSON::Field(key: "Image")]
      # The name of the image used when creating this container
      property image : String
      @[JSON::Field(key: "Names")]
      # The names that this container has been given
      property names = [] of String
      @[JSON::Field(key: "ImageID")]
      # The ID of the image that this container was created from
      property image_id : String?
      @[JSON::Field(key: "Command")]
      # Command to run when starting the container
      property command : String?
      @[JSON::Field(key: "Created")]
      # When the container was created
      property created : Int64?
      @[JSON::Field(key: "Ports")]
      # The ports exposed by this container
      property ports : Array(PortConfig)?
      @[JSON::Field(key: "Labels")]
      # User-defined key/value metadata.
      property labels : Hash(String, String)?
      @[JSON::Field(key: "SizeRw")]
      # The size of files that have been created or changed by this container
      property size_rw : Int64?
      @[JSON::Field(key: "SizeRootFs")]
      # The total size of all the files in this container
      property size_root_fs : Int64?
      @[JSON::Field(key: "State")]
      # The state of this container (e.g. Exited)
      property state : String?
      @[JSON::Field(key: "Status")]
      # Additional human-readable status of this container (e.g. Exit 0)
      property status : String?
      @[JSON::Field(key: "NetworkSettings")]
      # A summary of the container's network settings
      property network_settings : APIClient::NetworkingConfig?

      def self.request(all : Bool = false,
                       limit : Int32? = nil,
                       since : String? = nil,
                       before : String? = nil,
                       size : Bool = false,
                       filters = {} of String => Array(String))
        params = HTTP::Params.build do |qs|
          qs.add "all", all.to_s
          qs.add "limit", limit.to_s
          qs.add "since", since
          qs.add "before", before
          qs.add "size", size.to_s
          qs.add "filters", filters.to_json
        end

        Array(self).from_json(
          Docker.client.get("/containers/json?#{params}").body
        )
      end
    end
  end
end
