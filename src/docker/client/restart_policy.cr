module Docker
  class APIClient
    struct RestartPolicy
      include JSON::Serializable

      def initialize(@name, @maximum_retry_count); end

      # Valid values: `""`, `"always"`, `"unless-stopped"`, `"on-failure"`
      #
      # - *Empty string* means not to restart
      # - `always` Always restart
      # - `unless-stopped` Restart always except when the user has manually stopped the container
      # - `on-failure` Restart only when the container exit code is non-zero
      @[JSON::Field(key: "Name")]
      property name : String
      # If on-failure is used, the number of times to retry before giving up
      @[JSON::Field(key: "MaximumRetryCount")]
      property maximum_retry_count : UInt64
    end
  end
end
