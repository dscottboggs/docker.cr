require "../client/restart_policy"
require "../client/throttle_device"
require "../client/port_bindings"
require "../client/device_mapping"

module Docker
  class Container
    struct HostConfig
      struct ULimit
        include JSON::Serializable

        def initialize(@name, @soft, @hard); end

        # Name of ulimit
        @[JSON::Field(key: "Name")]
        property name : String
        # Soft limit
        @[JSON::Field(key: "Soft")]
        property soft : Int64
        # Hard limit
        @[JSON::Field(key: "Hard")]
        property hard : Int64
      end

      struct Mount
        include JSON::Serializable

        def initialize(@target,
                       @source,
                       @type,
                       @read_only = false,
                       @consistency = "default",
                       @bind_propagation = nil,
                       @volume_options = nil,
                       @tmpfs_options = nil)
        end

        # Container path.
        @[JSON::Field(key: "Target")]
        property target : String
        # Mount source (e.g. a volume name, a host path).
        @[JSON::Field(key: "Source")]
        property source : String
        # The mount type. Available types:
        #
        # - `bind` -- Mounts a file or directory from the host into the
        #   container. Must exist prior to creating the container.
        # - `volume` -- Creates a volume with the given name and options (or
        #   uses a pre-existing volume with the same name and options). These
        #   are not removed when the container is removed.
        # - `tmpfs` -- Create a tmpfs with the given options. The mount source
        #   cannot be specified for tmpfs.
        @[JSON::Field(key: "Type")]
        property type : String
        # Whether the mount should be read-only.
        @[JSON::Field(key: "ReadOnly")]
        getter? read_only = false

        def read_only
          @read_only = true
        end

        # The consistency requirement for the mount:
        # `"default"`, `"consistent"`, `"cached"`, or `"delegated"`.
        @[JSON::Field(key: "Consistency")]
        property consistency : String
        ValidBindPropagations = {
          "private", "rprivate", "shared", "rshared", "slave", "rslave",
        }
        @bind_propagation : String?

        # Optional configuration for the bind type.
        # Valid values: `"private"`, `"rprivate"`, `"shared"`, `"rshared"`,
        # `"slave"`, `"rslave"`
        def bind_propagation=(propagation)
          unless ValidBindPropagations.includes? propagation
            raise ArgumentError.new(
              "#{propagation} must be one of #{ValidBindPropagations.inspect}"
            )
          end
          @bind_propagation = propagation
        end

        @[JSON::Field(key: "BindOptions")]
        def bind_options
          unless (bprop = @bind_propagation).nil?
            {"Propagation" => bprop}
          end
        end

        # Optional configuration for the volume type.
        @[JSON::Field(key: "VolumeOptions")]
        property volume_options : VolumeOptions?
        # Optional configuration for the `tmpfs` type.
        @[JSON::Field(key: "TmpfsOptions")]
        property tmpfs_options : TmpfsOptions?

        struct VolumeOptions
          include JSON::Serializable

          def initialize(@no_copy = false, @labels = nil, @driver_config = nil); end

          @[JSON::Field(key: "NoCopy")]
          @no_copy = false

          def copy?
            !@no_copy
          end

          # Don't populate volume with data from the target.
          def no_copy
            @no_copy = true
          end

          # Populate volume with data from the target.
          def copy
            @no_copy = false
          end

          # User-defined key/value metadata.
          @[JSON::Field(key: "Labels")]
          property labels : Hash(String, String)?
          # Map of driver specific options
          @[JSON::Field(key: "DriverConfig")]
          property driver_config : DriverConfig?

          class DriverConfig
            include JSON::Serializable

            def initialize(@name, @options); end

            # Name of the driver to use to create the volume.
            @[JSON::Field(key: "Name")]
            property name : String
            # key/value map of driver specific options.
            @[JSON::Field(key: "Options")]
            property options = {} of String => String
          end
        end

        # Optional configuration for the `tmpfs` type.
        struct TmpfsOptions
          include JSON::Serializable

          def initialize(@size, @mode); end

          # The size for the tmpfs mount in bytes.
          @[JSON::Field(key: "Size")]
          property size : Int64
          # The permission mode for the tmpfs mount in an integer.
          @[JSON::Field(key: "Mode")]
          property mode : Int64
        end
      end

      include JSON::Serializable
      # An integer value representing this container's relative CPU weight
      # versus other containers.
      @[JSON::Field(key: "CpuShares")]
      property cpu_shares : Int64?
      # Memory limit in bytes.
      @[JSON::Field(key: "Memory")]
      property memory : Int64?
      # Path to cgroups under which the container's cgroup is created. If the
      # path is not absolute, the path is considered to be relative to the
      # cgroups path of the init process. Cgroups are created if they do not
      # already exist.
      @[JSON::Field(key: "CgroupParent")]
      property cgroup_parent : String?
      # Block IO weight (relative weight).
      @[JSON::Field(key: "BlkioWeight")]
      property blkio_weight : Int64?
      # Block IO weight (relative device weight) in the form
      # `[{"Path": "device_path", "Weight": weight}]`.
      @[JSON::Field(key: "BlkioWeightDevice")]
      property blkio_weight_device : Array(Hash(String, String | Int64))?
      # Limit read rate (bytes per second) from a device
      @[JSON::Field(key: "BlkioDeviceReadBps")]
      property blkio_device_read_bps : Array(Docker::APIClient::ThrottleDevice?)?
      # imit write rate (bytes per second) to a device,
      @[JSON::Field(key: "BlkioDeviceWriteBps")]
      property blkio_device_write_bps : Array(Docker::APIClient::ThrottleDevice?)?
      # Limit read rate (IO per second) from a device
      @[JSON::Field(key: "BlkioDeviceReadIOps")]
      property blkio_device_read_iops : Array(Docker::APIClient::ThrottleDevice?)?
      # Limit write rate (IO per second) to a device
      @[JSON::Field(key: "BlkioDeviceWriteIOps")]
      property blkio_device_write_iops : Array(Docker::APIClient::ThrottleDevice?)?
      # The length of a CPU period in microseconds.
      @[JSON::Field(key: "CpuPeriod")]
      property cpu_period : Int64?
      # Microseconds of CPU time that the container can get in a CPU period.
      @[JSON::Field(key: "CpuQuota")]
      property cpu_quota : Int64?
      # The length of a CPU real-time runtime in microseconds. Set to 0 to
      # allocate no time allocated to real-time tasks.
      @[JSON::Field(key: "CpuRealtimePeriod")]
      property cpu_realtime_period : Int64?
      # The length of a CPU real-time runtime in microseconds. Set to 0 to
      # allocate no time allocated to real-time tasks.
      @[JSON::Field(key: "CpuRealtimeRuntime")]
      property cpu_realtime_runtime : Int64?
      # CPUs in which to allow execution (e.g., 0-3, 0,1)
      @[JSON::Field(key: "CpusetCpus")]
      property allowed_CPUs : String?
      # Memory nodes (MEMs) in which to allow execution (0-3, 0,1). Only
      # effective on NUMA systems.
      @[JSON::Field(key: "CpusetMems")]
      property cpu_set_mems : String?
      # A list of devices to add to the container.
      @[JSON::Field(key: "Devices")]
      property devices : Array(DeviceMapping)?
      # a list of cgroup rules to apply to the container
      @[JSON::Field(key: "DeviceCgroupRules")]
      property device_cgroup_rules : Array(String)?
      # Disk limit (in bytes).
      @[JSON::Field(key: "DiskQuota")]
      property disk_quota : Int64?
      # Kernel memory limit in bytes.
      @[JSON::Field(key: "KernelMemory")]
      property kernel_memory : Int64?
      # Memory soft limit in bytes.
      @[JSON::Field(key: "MemoryReservation")]
      property memory_reservation : Int64?
      # Total memory limit (memory + swap). Set as -1 to enable unlimited swap.
      @[JSON::Field(key: "MemorySwap")]
      property memory_and_swap : Int64?
      # Tune a container's memory swappiness behavior. Accepts an integer
      # between 0 and 100.
      @[JSON::Field(key: "MemorySwappiness")]
      property memory_swappiness : Int64?
      # CPU quota in units of 10**-9 CPUs.
      @[JSON::Field(key: "NanoCPUs")]
      property nano_cpus : Int64?
      # Disable OOM Killer for the container.
      @[JSON::Field(key: "OomKillDisable")]
      property oom_kill_disable : Bool?
      # Tune a container's pids limit. Set -1 for unlimited.
      @[JSON::Field(key: "PidsLimit")]
      property pids_limit : Int64?
      # A list of resource limits to set in the container
      @[JSON::Field(key: "Ulimits")]
      property u_limits : Array(ULimit?)?
      # The number of usable CPUs (Windows only).
      #
      # On Windows Server containers, the processor resource controls are
      # mutually exclusive. The order of precedence is CPUCount first, then
      # CPUShares, and CPUPercent last.
      @[JSON::Field(key: "CpuCount")]
      property cpu_count : Int64?
      # The usable percentage of the available CPUs (Windows only).
      #
      # On Windows Server containers, the processor resource controls are
      # mutually exclusive. The order of precedence is CPUCount first, then
      # CPUShares, and CPUPercent last.
      @[JSON::Field(key: "CpuPercent")]
      property cpu_percent : Int64?
      # Maximum IOps for the container system drive (Windows only)
      @[JSON::Field(key: "MaximumIOps")]
      property maximum_iops : Int64?
      # Maximum IO in bytes per second for the container system drive (Windows
      # only)
      @[JSON::Field(key: "MaximumIOBps")]
      property maximum_bandwidth : Int64?
      # A list of volume bindings for this container. Each volume binding is a
      # string in one of these forms:
      #
      # - `host-src:container-dest` to bind-mount a host path into the
      # container. Both host-src, and container-dest must be an absolute path.
      # - `host-src:container-dest:ro` to make the bind-mount read-only inside
      # the container. Both host-src, and container-dest must be an absolute
      # path.
      # - `volume-name:container-dest` to bind-mount a volume managed by a volume
      # driver into the container. container-dest must be an absolute path.
      # - `volume-name:container-dest:ro` to mount the volume read-only inside
      # the container. container-dest must be an absolute path.
      #
      private property _binds : Hash(String, String)?

      @[JSON::Field(key: "Binds")]
      @binds : Array(String)?

      def binds : Hash(String, String)?
        return {} of String => String if @binds.nil? || @binds.not_nil!.empty?
        if (nn_binds = _binds).nil? || _binds.not_nil!.size != @binds.not_nil!.size
          _binds = {} of String => String
          @binds.not_nil!.each do |binding|
            split = binding.split ":"
            unless split.size == 2
              raise "invalid binding #{binding} must have only one ':' in it."
            end
            _binds[split[0]] = split[1]
          end
        end
        _binds
      end

      def binds=(b : Hash(String, String))
        @binds = b.keys
        _binds = b
        self
      end

      # Path to a file where the container ID is written
      @[JSON::Field(key: "ContainerIDFile")]
      property container_id_file : String?
      # The logging configuration for this container
      # must have the keys "Type" (whose values must be one of "json-file",
      # "syslog", "journald", "gelf", "fluentd", "awslogs", "splunk", "etwlogs",
      # or "none") and "Config", which must be a mapping options.
      @[JSON::Field(key: "LogConfig")]
      property log_config : Hash(String, String | Hash(String, String))?
      # Network mode to use for this container. Supported standard values are:
      # `bridge`, `host`, `none`, and `container:<name|id>`. Any other value is
      # taken as a custom network's name to which this container should connect
      # to.
      @[JSON::Field(key: "NetworkMode")]
      property network_mode : String?
      # A map of exposed container ports and the host port they should map to.
      @[JSON::Field(key: "Docker::APIClient::PortBindings")]
      property port_bindings : Hash(String | Int64, Docker::APIClient::PortBindings)?
      # The behavior to apply when the container exits. The default is not to
      # restart.
      #
      # An ever increasing delay (double the previous delay, starting at 100ms)
      # is added before each restart to prevent flooding the server.
      @[JSON::Field(key: "Docker::APIClient::RestartPolicy")]
      property restart_policy : Docker::APIClient::RestartPolicy?
      @[JSON::Field(key: "AutoRemove")]
      @auto_remove = false

      def auto_remove?
        @auto_remove
      end

      # Automatically remove the container when the container's process exits.
      # This has no effect if `#restart_policy` is set.
      def auto_remove
        @auto_remove = true
      end

      # Driver that this container uses to mount volumes.
      @[JSON::Field(key: "VolumeDriver")]
      property volume_driver : String
      # A list of volumes to inherit from another container, specified in the
      # form `<container name>[:<ro|rw>]`.
      @[JSON::Field(key: "VolumesFrom")]
      property volumes_from : Array(String)
      @[JSON::Field(key: "Mounts")]
      property mounts : Array(Mount?)?
      # A list of kernel capabilities to add to the container.
      @[JSON::Field(key: "CapAdd")]
      property cap_add : Array(String)?
      # A list of kernel capabilities to drop from the container.
      @[JSON::Field(key: "CapDrop")]
      property cap_drop : Array(String)?
      # A list of DNS servers for the container to use.
      @[JSON::Field(key: "Dns")]
      property dns : Array(String)?
      # A list of DNS options.
      @[JSON::Field(key: "DnsOptions")]
      property dns_options : Array(String)?
      # A list of DNS search domains.
      @[JSON::Field(key: "DnsSearch")]
      property dns_search : Array(String)?
      # A list of hostnames/IP mappings to add to the container's `/etc/hosts`
      # file. Specified in the form `["hostname:IP"]`.
      @[JSON::Field(key: "ExtraHosts")]
      property extra_hosts : Array(String)?
      # A list of additional groups that the container process will run as.
      @[JSON::Field(key: "GroupAdd")]
      property group_add : Array(String)?
      # IPC namespace to use for the container.
      @[JSON::Field(key: "IpcMode")]
      property ipc_mode : String?
      # Cgroup to use for the container.
      @[JSON::Field(key: "Cgroup")]
      property cgroup : String?
      # A list of links for the container in the form `container_name:alias`.
      @[JSON::Field(key: "Links")]
      property links : Array(String)?
      # An integer value containing the score given to the container in order to
      # tune OOM killer preferences.
      @[JSON::Field(key: "OomScoreAdj")]
      property oom_score_adjustment : Int64?
      # Set the PID (Process) Namespace mode for the container. It can be
      # either:
      #
      # "container:<name|id>": joins another container's PID namespace
      # "host": use the host's PID namespace inside the container
      @[JSON::Field(key: "PidMode")]
      property pid_mode : String?
      @[JSON::Field(key: "Privileged")]
      getter? privileged = false

      # Gives the container full access to the host.
      def make_privileged
        @privileged = true
      end

      @[JSON::Field(key: "PublishAllPorts")]
      getter? publish_all_ports = false

      # Allocate a random host port for all of a container's exposed ports.
      def publish_all_ports
        @publish_all_ports = true
      end

      @[JSON::Field(key: "ReadonlyRootfs")]
      getter? read_only_rootfs = false

      # Mount the container's root filesystem as read only.
      def read_only_rootfs
        @read_only_rootfs = true
      end

      # A list of string values to customize labels for MLS systems, such as
      # SELinux.
      @[JSON::Field(key: "SecurityOpt")]
      property secure_opt : Array(String)?
      # Storage driver options for this container, in the form
      # `{"size": "120G"}`.
      @[JSON::Field(key: "StorageOpt")]
      property storage_opt : Hash(String, String)?
      # A map of container directories which should be replaced by tmpfs mounts,
      # and their corresponding mount options. For example:
      # `{ "/run": "rw,noexec,nosuid,size=65536k" }`.
      @[JSON::Field(key: "Tmpfs")]
      property tmpfs : Hash(String, String)?
      # UTS namespace to use for the container.
      @[JSON::Field(key: "UtsMode")]
      property uts_mode : String?
      # Sets the usernamespace mode for the container when usernamespace
      # remapping option is enabled.
      @[JSON::Field(key: "UsernsMode")]
      property user_namespace_mode : String?
      # Size of /dev/shm in bytes. If omitted, the system uses 64MB.
      @[JSON::Field(key: "ShmSize")]
      property shm_size : UInt64?
      # A list of kernel parameters (sysctls) to set in the container. For
      # example: `{"net.ipv4.ip_forward": "1"}`
      @[JSON::Field(key: "Sysctls")]
      property systctls : Hash(String, String)?
      # Runtime to use with this container.
      @[JSON::Field(key: "Runtime")]
      property runtime : String?
      # Initial console size, as an [height, width] array. (Windows only)
      @[JSON::Field(key: "ConsoleSize")]
      property console_size : Tuple(UInt64, UInt64)?
      # Isolation technology of the container. (Windows only
      @[JSON::Field(key: "Isolation")]
      property isolation = "default"
    end
  end
end
