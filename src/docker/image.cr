require "json"

module Docker
  class Image
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

    # Tag an image.
    # See https://docs.docker.com/engine/api/v1.30/#operation/ImageTag
    def tag(tag_val : Tag)
      reponse = Docker.client.post("/images/#{id}/tag" + tag_val.to_params)
      case response.status_code
      when 201
        return self
      when 400
        raise BadParameter.new url, response
      when 404
        raise NotFound.new url, response
      when 409
        raise "Tag #{tag_val} for image #{id} already exists!"
      when 500
        raise InternalServerError.new url, response
      else
        raise Docker::APIClient::Exception.new(
          "got unexpected status #{response.status} for endpoint #{url}."
        )
      end
    end

    # The string is converted to a Docker::Tag.
    def tag(tag_val : String)
      tag Tag.from_s(tag_val)
    end

    # Remove this image, pruning untagged parent images by default.
    # See https://docs.docker.com/engine/api/v1.30/#operation/ImageDelete
    def remove(force? = false, prune? = true)
      query = HTTP::Params.build do |q|
        q.add "force", "true" if force?
        q.add "noprune", "true" unless prune?
      end
      query = '?' + query unless query.empty?
      url = "/images/" + id + query
      response = Docker.client.delete url
      case response.status_code
      when 200
        o = JSON.parse response.body?
        untagged = Slice(String).new
        deleted = Slice(String).new
        o.each do |img|
          if id = img["Untagged"]?
            untagged << id
          elsif id = img["Deleted"]?
            deleted << id
          end
        end
        return {untagged: untagged, deleted: deleted}
      when 404
        raise NotFound.new url, response
      when 500
        raise InternalServerError.new url, response
      else
        raise Docker::APIClient::Exception.new(
          "got unexpected status #{response.status} for endpoint #{url}."
        )
      end
    end

    def search(term : String, limit : Int64, filters : Hash(String, String))
      raise NotYetImplemented.new :search
    end

    # Yield each byte of a tar archive of the export of this image.
    # See https://docs.docker.com/engine/api/v1.30/#operation/ImageCommit
    def export
      url = "/images/#{id}/get"
      Docker.client.get url do |response|
        raise InternalServerError.new url, response if response.status_code === 500
        response.body_io.each_byte { |byte| yield byte }
      end
    end

    # Exports the image into the given IO
    def export(into : IO)
      export do |byte|
        into << byte
      end
      self
    end

    # Exports the image into the given file on the filesystem
    def export(into : String)
      File.open into, perm: 0o644 do |f|
        export to: f
      end
    end

    # Like Image#export, but retreives multiple images into a single tar file.
    def self.export(*ids_or_names : String)
      url = "/images/get?names=#{ids_or_names.join ','}"
      Docker.client.get url do |response|
        raise InternalServerError.new url, response if response.status_code === 500
        response.body_io.each_byte { |byte| yield byte }
      end
    end

    def self.export(*ids_or_names : String, into : IO)
      self.export *ids_or_names do |byte|
        into << byte
      end
    end

    def self.export(*ids_or_names : String, into : String)
      File.open into, perm: 0o644 do |file|
        self.export ids_or_names, into: file
      end
    end

    # Build an image with the given parameters. Context must be one of:
    #   - a path to a directory to be used as context
    #   - a path to a .tar file to be used as context
    #   - an IO which when read will yield a tarfile to be used as context
    # Note that the dockerfile parameter is a path relative to the context, not
    # an absolute path.
    # See https://docs.docker.com/engine/api/v1.30/#operation/ImageBuild
    def self.build(
      context : String | IO = Dir.current,
      dockerfile : String? = nil,
      tag : Array(String)? = nil,
      extra_hosts : String = nil,
      remote : String? = nil,
      no_cache? = false,
      cache_from : Array(String)? = nil,
      pull? = false,
      rm? = true,
      force_rm? = false,
      limits = ContainerLimits.new
    )
      lim = limits.to_q
      q = HTTP::Params.build do |query|
        query.add "dockerfile", dockerfile unless dockerfile == "Dockerfile" ||
                                                  dockerfile.nil?
        tag.nil? || tag.each { |t| query.add "t", t }
        query.add "extrahosts", extra_hosts unless extra_hosts.nil?
        query.add "remote", remote unless remote.nil?
        query.add "nocache", "true" if no_cache?
        query.add "cachefrom", cache_from unless cache_from.nil?
        query.add "pull", "true" if pull?
        query.add "rm", "false" unless rm?
        query.add "forcerm", "true" if force_rm?
      end
      query_string = lim.nil? ? q : lim + '&' + q
      query_string = "?" + query_string unless query_string.empty?
      endpoint = "/build#{query_string}"
      if File.directory? context
        tf_reader, tf_writer = IO.pipe
        tar_proc = Process.run "tar -c #{context}", output: tf_writer
        spawn do
          handle_request endpoint, Docker.client.post(endpoint, body: tf_reader)
        end
        tar_proc.wait
        tf_writer.close
        Fiber.yield
        self
      else
        if File.exists? context && tarfile_at? context
          File.open context do |tarfile|
            handle_request endpoint, Docker.client.post endpoint, body: tarfile
          end
        else
          raise Docker::APIClient::Exception.new "invalid image file #{context}"
        end
      end
      if tarfile_location.nil?
        raise "got nil tarfile location, that shouldn't happen"
      end
    end

    # Pull an image by its tag. The block receives the stream of the status,
    # line-by-line, as JSON objects. See
    # https://docs.docker.com/engine/api/v1.30/#operation/ImageCreate
    def self.pull(image_tag : Tag, &block : JSON::Any -> Nil)
      query = HTTP::Params.build do |q|
        q.add "fromImage", image_tag.image_name
        q.add "repo", image_tag.repo unless image_tag.repo.nil?
        q.add "tag", image_tag.tag
      end
      url = "/images/create"
      url += '?' + query unless query.empty?
      stream_pull_status url, &block
      Docker::Images.find image_tag
    end

    # Import an image from a tar archive. The block receives the stream of the
    # status, line-by-line, as JSON objects. See
    # https://docs.docker.com/engine/api/v1.30/#operation/ImageCreate
    def self.import(path_or_url : String | URI, &block)
      stream_pull_status "/images/create?fromSrc=#{path_or_url.to_s}", &block
    end

    def self.import(tarfile : File, &block)
      File.open tarfile do |file|
        stream_pull_status "/images/create?fromSrc=-", body: file, &block
      end
    end

    private def stream_pull_status(url : String, body : IO? = nil, &block)
      Docker.client.post url, body do |result|
        loop do
          raise Docker::APIClient::NotFound.new(url, result) if result.status_code === 404
          raise Docker::APIClient::InternalServerError.new(url, result) if result.status_code === 500
          yield JSON.parse(result.body_io.gets "\n", chomp: true)
        end
      end
    end

    private def handle_request(endpoint : String, result : HTTP::Client::Response)
      case result.status_code
      when 200
        return
      when 400
        raise Docker::APIClient::BadParameter.new(endpoint, result)
      when 404
        raise Docker::APIClient::NotFound.new endpoint, result
      when 500
        raise Docker::APIClient::InternalServerError.new(endpoint, result)
      else
        raise "Unexpected HTTP status #{result.status} for #{endpoint}."
      end
      self.from_json response.body?
    end
  end

  ValidTarfileMimeTypes = ["x-tar", "gzip", "x-bzip2"].map { |m| "application/#{m}" }

  def tarfile_at?(context : String)
    ValidTarfileMimeTypes.includes? `file --brief --mime-type #{context}`
  end
end
