require "./container/create_body"

module Docker
  class Container
    NAME_REGEX = /\/?[a-zA-Z0-9_-]+/
    property id : String
    property image : Docker::Tag
    property names = [] of String
    @warnings : IO

    def initialize(image : String | Docker::Tag, @id, @names = [] of String, @warnings = STDERR)
      if (img = image).is_a? String
        @image = Docker::Tag.from_s img
      else
        @image = img
      end
    end

    # returns the first container matching the given ID or name, or raise a
    # Docker::APIClient::NotFound it's not found. In the case that multiple are
    # found, a Docker::APIClient::Exception will be raised. To get multiple
    # matching containers, use Docker::Containers[] or
    # Docker::Containers.containers, which return instead a (possibly empty)
    # list of all matching containers.
    def self.get(id_or_name) : self
      if (containers = Docker::Containers[id_or_name]).size == 1
        container = containers[0]
        new container.image, container.id, container.names
      elsif containers.size == 0
        raise Docker::APIClient::NotFound.new("container", id_or_name)
      else
        raise Docker::APIClient::Exception.new "\
          multiple containers found with the name #{id_or_name}. Use Docker::\
          Containers.[]() instead."
      end
    end

    # returns the first container matching the given ID or name, or nil if
    # it's not found. In the case that multiple are found, only the first will
    # be returned. To get multiple matching containers, use
    # Docker::Containers[] or Docker::Containers.containers, which return
    # instead a (possibly empty) list of all matching containers.
    def get?(id_or_name) : self
      if container = Docker::Containers[id_or_name][0]?
        new container.image, container.id, container.names
      end
    end

    def self.create(image, name = nil, warnings = STDERR, **kwargs)
      names = [] of String
      names << name if name && name.match NAME_REGEX
      new(image: image, id: "not yet created", names: names, warnings: warnings).create(**kwargs)
    end

    def create(**kwargs)
      path = if (name = names[0]?).nil?
               "/containers/create"
             else
               "/containers/create?name=#{name}"
             end
      response = Docker.client.post(path, body: CreateBody.new(image, **kwargs).to_json)

      if response.status_code == 200
        body = Hash(String, String | Array(String)).from_json response.body
        if (warn_text = body["Warnings"]).is_a? Array(String)
          warn_text.each { |warning| @warnings.puts warning }
        elsif warn_text.is_a? String
          @warnings.puts warn_text
        end
        @id = body["Id"].as(String)
        self
      else
        handle_response(path, response, :create)
      end
    end

    def logs(follow = true, stdout = true, stderr = true, since = 0, timestamps = false)
      params = HTTP::Params.build do |qs|
        qs.add "follow", follow.to_s
        qs.add "stdout", stdout.to_s
        qs.add "stderr", stderr.to_s
        qs.add "since", since.to_s
        qs.add "timestamps", timestamps.to_s
      end
      Docker.client.client.get("/containers/#{id}/logs?#{params}") do |response|
        raise "unexpected status code #{response.status_code}" unless response.status_code == 200
        begin
          response.body_io.each_line do |line|
            print line # unless line.strip.empty?
          end
        rescue e
          puts e
          response.body_io.close
        end
      end
    end

    def start
      post "/containers/#{id}/start"
    end

    def stop(wait = 5)
      post "/containers/#{id}/stop?t=#{wait}"
    end

    def restart(wait = 5)
      post "/containers/#{id}/restart?t=#{wait}"
    end

    def kill
      post "/containers/#{id}/kill"
    end

    private def post(path : String)
      handle_response path, Docker.client.post(path)
    end

    private def handle_response(path : String, res : HTTP::Client::Response, action)
      case res.status_code # make chainable
      when 200, 204
        return self
      when 304
        @warnings.puts "container #{id} already #{action.to_s}"
        return self
      when 400
        raise Docker::APIClient::BadParameter.new path, res
      when 404
        raise Docker::APIClient::NotFound.new("Container", path, res)
      when 406
        raise Docker::APIClient::InternalServerError.new(path, res)
      when 500
        raise Docker::APIClient::InternalServerError.new(path, res)
      when 409
        raise Docker::APIClient::Exception.new "could not create #{id} due to conflict: #{res.body?}"
      else
        raise Docker::APIClient::Exception.new "unrecognized error code #{res.status_code}"
      end
    end
  end
end
