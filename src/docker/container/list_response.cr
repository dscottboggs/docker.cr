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
      # The ID of this container
      @[JSON::Field(key: "Id")]
      property id : String
      # The name of the image used when creating this container
      @[JSON::Field(key: "Image")]
      property image : String
      # The names that this container has been given
      @[JSON::Field(key: "Names")]
      property names = [] of String
      # The ID of the image that this container was created from
      @[JSON::Field(key: "ImageID")]
      property image_id : String?
      # Command to run when starting the container
      @[JSON::Field(key: "Command")]
      property command : String?
      # When the container was created
      @[JSON::Field(key: "Created")]
      property created : Int64?
      # The ports exposed by this container
      @[JSON::Field(key: "Ports")]
      property ports : Array(PortConfig)?
      # User-defined key/value metadata.
      @[JSON::Field(key: "Labels")]
      property labels : Hash(String, String)?
      # The size of files that have been created or changed by this container
      @[JSON::Field(key: "SizeRw")]
      property size_rw : Int64?
      # The total size of all the files in this container
      @[JSON::Field(key: "SizeRootFs")]
      property size_root_fs : Int64?
      # The state of this container (e.g. Exited)
      @[JSON::Field(key: "State")]
      property state : String?
      # Additional human-readable status of this container (e.g. Exit 0)
      @[JSON::Field(key: "Status")]
      property status : String?
      # A summary of the container's network settings
      @[JSON::Field(key: "NetworkSettings")]
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
