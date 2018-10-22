require "socket"
require "uri"

require "./client/*"

module Docker
  # The Docker::APIClient contains all of the methods created by the various files.
  class APIClient
    include Docker::APIClient::Info
    include Docker::APIClient::Containers
    include Docker::APIClient::Images

    # Make a {{method.id.upcase}} request to the docker daemon
    # TODO won't work because of patches to the HTTP::Client class
    # delegate self.{{method}}, to: client

    {% for method in %i<get post put patch head> %}
    # Make a {{method.id.upcase}} request to the docker daemon, using the
    # already established Docker::APIClient
    delegate {{method}}, to: client
    {% end %}

    def default_client_url
      ENV["DOCKER_URL"]? || ENV["DOCKER_HOST"]? || "unix:///var/run/docker.sock"
    end

    DEFAULT_CERT_PATH = "#{ENV["HOME"]}/.docker"

    # The URL at which the docker client can be reached. It is advisable to use
    # a unix socket, which may be passed to this using the URL format "unix://*"
    getter url : URI
    # Also accessible via DOCKER_TLS_VERIFY environment variable.
    setter verify_tls : Bool?
    cert_path : String?
    property client : HTTP::Client

    @ssl_context : OpenSSL::SSL::Context | Nil

    def initialize(@raw_url : String = default_client_url)
      @url = URI.parse(@raw_url)
      # client assignment MUST be within initialize, or it will be nillable.
      # you can't just call setup_client from the initialize method. :(
      @client = if url.scheme === "unix"
                  HTTP::Client.unix(url.to_s.sub /unix:\//, "")
                elsif verify_tls?
                  c = HTTP::Client.new url.host.not_nil!, url.port.not_nil!, true
                  c.ssl_context = ssl_context
                  c
                else
                  HTTP::Client.new url.host.not_nil!, url.port.not_nil!, false
                end
    end

    def initialize(url : URI)
      @url = url
      @raw_url = url.to_s
      # client assignment MUST be within initialize, or it will be nillable.
      @client = if url.scheme === "unix"
                  HTTP::Client.unix(url.to_s.sub /unix:\//, "")
                elsif verify_tls?
                  c = HTTP::Client.new url.host.not_nil!, url.port.not_nil!, true
                  c.ssl_context = ssl_context
                  c
                else
                  HTTP::Client.new url.host.not_nil!, url.port.not_nil!, false
                end
    end

    def url=(url : URI)
      @url = url
      setup_client
    end

    def url=(raw_url)
      @url = URI.parse(raw_url)
      setup_client
    end

    private def setup_client
      @client = if url.scheme === "unix"
                  HTTP::Client.unix(url.to_s.sub /unix:\//, "")
                elsif verify_tls?
                  c = HTTP::Client.new url.host.not_nil!, url.port.not_nil!, true
                  c.ssl_context = ssl_context
                  c
                else
                  HTTP::Client.new url.host.not_nil!, url.port.not_nil!, false
                end
    end

    private def ssl_context
      @ssl_context ||= begin
        ctx = OpenSSL::SSL::Context::Client.new(LibSSL.tlsv1_method)
        ctx.private_key = key_file_path
        ctx.ca_file = ca_file_path
        ctx.certificate_file = cert_file_path
        ctx
      end
    end

    private def verify_tls?
      @verify_tls ||= tcp? && ENV.fetch("DOCKER_TLS_VERIFY", "0").to_i == 1
    end

    private def unix?
      @url.scheme == "unix"
    end

    private def tcp?
      @url.scheme == "tcp" || @url.scheme == "http" || @url.scheme == "https"
    end

    # Also accessible via DOCKER_CERT_PATH environment variable.
    # If the envvar is not empty or this varable is not nil, it must be a path
    # to a directory on the filesystem which contains the following files
    # containing a valid SSL certificate:
    #  - ca.pem
    #  - key.pem
    #  - cert.pem
    #
    # Setting cert_path and not having these files present will raise an
    # exception.
    def cert_path=(path : String)
      spawn do
        unless File.directory? path
          raise "\
            required SSL, but no such file found at #{path} or no path specified"
        end
      end
      {% for f in %i<ca key cert> %}
      spawn do
        unless File.exists?("{{f.id}}.pem")
          raise "required SSL and #{path}/{{f.id}}.pem was not found"
        end
      end
      {% end %}
      @cert_path = path
    end

    def cert_path
      if cert_path.nil?
        cert_path = ENV["DOCKER_CERT_PATH"]? || DEFAULT_CERT_PATH
      end
      @cert_path
    end

    private def ca_file_path
      "#{cert_path}/ca.pem"
    end

    private def key_file_path
      "#{cert_path}/key.pem"
    end

    private def cert_file_path
      "#{cert_path}/cert.pem"
    end
  end
end
