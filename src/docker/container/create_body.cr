require "./host_config"
require "./health_check"
StrAttrs = {
  hostname:    "Hostname",
  domain_name: "DomainName",
  user:        "User",
  command:     "Command",
  working_dir: "WorkingDir",
  mac_address: "MacAddress",
}
DefaultTrueAttrs = {
  attach_stdin:  "AttachStdin",
  attach_stdout: "AttachStdout",
  attach_stderr: "AttachStderr",
}
DefaultFalseAttrs = { # these all default to false
  stdin_once:           "StdinOnce",
  tty:                  "Tty",
  open_stdin:           "OpenStdin",
  args_escaped_already: "ArgsEscaped",
  network_disabled:     "NetworkDisabled",
}

module Docker
  class Container
    class CreateBody
      def initialize(@image,
                     *,
                     @hostname = nil,
                     @domain_name = nil,
                     @user = nil,
                     @command = nil,
                     @working_dir = nil,
                     @mac_address = nil,
                     @attach_stdin = true,
                     @attach_stderr = true,
                     @attach_stdout = true,
                     @stdin_once = false,
                     @tty = false,
                     @open_stdin = false,
                     @args_escaped_already = false,
                     @network_disabled = false,
                     @health_check = nil,
                     @env = nil,
                     @exposed_ports = nil,
                     @volumes = nil,
                     @entrypoint = nil,
                     @on_build = nil,
                     @labels = nil,
                     @stop_signal = "SIGTERM",
                     @stop_timeout = 10,
                     @shell = nil)
      end

      {% for attr in StrAttrs %}
      # the {{ attr.id }} of the new container
      property {{ attr.id }} : String?{% end %}
      {% for attr, name in DefaultTrueAttrs %}
      # whether to attach {{ name[6..-1].upcase }}. Defaults to "true".
      property {{ attr.id }} = true {% end %}
      {% for attr, name in DefaultFalseAttrs %}
      property {{ attr.id }} = false{% end %}

      # A test to perform to check that the container is healthy.
      property? health_check : HealthCheck? # ?
      # environment variables to set inside the container
      property? env : Hash(String, String)?
      property? exposed_ports : Array(String)?
      # paths which will become volumes in the created container
      # the volume name or host binding is not specified.
      property? volumes : Array(String)?
      # The entry point for the container as a string or an array of strings.
      #
      # If the array consists of exactly one empty string ([""]) then the entry
      # point is reset to system default (i.e., the entry point used by docker
      # when there is no `ENTRYPOINT` instruction in the `Dockerfile`).
      property? entrypoint : String | Array(String)?
      # `ONBUILD` metadata that were defined in the image's `Dockerfile`.
      property? on_build : Array(String)?
      # User-defined key/value metadata.
      property? labels : Hash(String, String)?
      # Signal to stop a container as a string or unsigned integer.
      property stop_signal : String | UInt8 = "SIGTERM"
      # Timeout to stop a container in seconds.
      property stop_timeout = 10
      # Shell for when `RUN`, `CMD`, and `ENTRYPOINT` uses a shell.
      property? shell : Array(String)?
      # The Tag of the image to use when creating the container
      setter image : Tag | String

      def image?
        @image.to_s unless @image.nil?
      end

      # the unique elements from the Indexable "values" is converted to an
      # object in the given builder, where the values from the indexable are the
      # keys, mapped to empty values, like
      # `{"value one" => {}, "value two" => {}}`
      def as_keys(values : Indexable(String), builder : JSON::Builder)
        builder.object do
          if values.responds_to? :uniq
            values.uniq.each do |v|
              builder.object { builder.field v, builder.object { } }
            end
          else
            values.each do |v|
              builder.object { builder.field v, builder.object { } }
            end
          end
        end
      end

      def to_json
        strbuf = String::Builder.new
        builder = JSON::Builder.new strbuf
        builder.start_document
        to_json builder
        builder.end_document
        strbuf.to_s
      end

      def to_json(builder : JSON::Builder)
        builder.object do
          {% for attr, str in StrAttrs %}
            builder.field {{ str }}, {{ attr.id }} unless {{ attr.id }}.nil?
          {% end %}
          {% for attr, str in DefaultFalseAttrs %}
            builder.field {{ str }}, {{ attr.id }}.to_s unless {{ attr.id }}.nil?
          {% end %}
          {% for attr, str in DefaultTrueAttrs %}
            builder.field {{ str }}, "true" if {{ attr.id }}
          {% end %}
          unless env?.nil? || env?.not_nil!.empty?
            builder.field "Environment" do
              builder.array do
                env?.not_nil!.to_a.each { |e| builder.string e }
              end
            end
          end
          unless (ports = exposed_ports?).nil?
            builder.field "ExposedPorts" do
              as_keys(ports, builder)
            end
          end
          unless (img = image?).nil?
            builder.field "Image", img
          end
          unless (vols = volumes?).nil?
            builder.field "Volumes" do
              as_keys(vols, builder)
            end unless vols.empty?
          end
          unless (ept = entrypoint?).nil?
            if ept.is_a? String
              builder.field "Entrypint", ept.as(String)
            else
              builder.field "Entrypoint" do
                builder.array do
                  ept.as(Array(String)).each { |e| builder.string e }
                end
              end
            end
          end
          unless (lbls = labels?).nil?
            builder.object do
              lbls.each { |k, v| builder.field(k, v) }
            end unless lbls.empty?
          end
          builder.field "StopSignal", stop_signal
          builder.field "StopTimeout", stop_timeout
          unless (sh = shell?).nil?
            builder.field "Shell" do
              builder.array do
                sh.each { |arg| builder.string arg }
              end
            end unless sh.empty?
          end
        end
      end
    end
  end
end
