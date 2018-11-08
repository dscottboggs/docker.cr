module Docker
  class Image
    class ListResponse
      include JSON::Serializable
      @[JSON::Field(key: "Id")]
      property id : String
      @[JSON::Field(key: "ParentId")]
      property parent_id : String
      @[JSON::Field(key: "RepoTags")]
      property repo_tags : Array(String)
      @[JSON::Field(key: "RepoDigests")]
      property repo_digests : Array(String)
      @[JSON::Field(key: "Created")]
      property created_at : Int32
      @[JSON::Field(key: "Size")]
      property size : Int32
      @[JSON::Field(key: "SharedSize")]
      property shared_size : Int32
      @[JSON::Field(key: "VirtualSize")]
      property virtual_size : Int32
      @[JSON::Field(key: "Labels")]
      property labels : Hash(String, String)
      @[JSON::Field(key: "Containers")]
      property containers : Int32

      def created
        created_at
      end

      @[JSON::Field(ignore: true)]
      @image : Docker::Image?
      def image
        @image ||= Docker::Image.new tags: repo_tags, id: id
      end

      delegate tag, to: image
      delegate remove, to: image
      delegate search, to: image
      delegate export, to: image
    end
  end
end
