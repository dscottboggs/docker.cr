module Docker
  class Container
    class HealthCheck
      include JSON::Serializable
      # The test command to run. Possible values are:
      #
      # - `[]`: inherit healthcheck from image or parent image
      # - `["NONE"]`: disable healthcheck
      # - `["CMD", *args]`: exec arguments directly
      # - `["CMD-SHELL", command]`: run command with system's default shell
      @[JSON::Field(key: "Test")]
      property command = [] of String
      # The time to wait between checks in nanoseconds. It should be 0 or at
      # least 1000000 (1 ms). 0 means inherit.
      @[JSON::Field(key: "Interval")]
      property interval : UInt64
      # The time to wait before considering the check to have hung. It should be
      # 0 or at least 1000000 (1 ms). 0 means inherit.
      @[JSON::Field(key: "Timeout")]
      property timeout : UInt64
      # The number of consecutive failures needed to consider a container as
      # unhealthy. 0 means inherit.
      @[JSON::Field(key: "Retries")]
      property retries : UInt64
      # Start period for the container to initialize before starting health-
      # retries countdown in nanoseconds. It should be 0 or at least 1000000
      # (1 ms). 0 means inherit.
      @[JSON::Field(key: "StartPeriod")]
      property start_period : UInt64

      # if interval, timeout, or start_period are less than one million and more
      # than zero, this will raise an exception. To prevent this behavior, you
      # can call this `#.new` with an explicit `(..., force: true)`, or set the
      # property after initializing.
      def initialize(@command = [] of String,
                     @interval = 0,
                     @timeout = 0,
                     @retries = 0,
                     @start_period = 0,
                     *,
                     force = false)
        unless force
          if (@interval > 0 && @interval < 1000000)
            raise "\
              Interval was too short: #{@interval}. Must be at least 1,000,000 \
              (1 ms). Use 0 to inherit from the image."
          end
          if (@timeout > 0 && @timeout < 1000000)
            raise "\
              Timeout was too short: #{@timeout}. Must be at least 1,000,000 \
              (1 ms). Use 0 to inherit from the image."
          end
          if (@start_period > 0 && @start_period < 1000000)
            raise "\
              Start period was too short: #{@start_period}. Must be at least 1,000,000 \
              (1 ms). Use 0 to inherit from the image."
          end
        end
      end
    end
  end
end
