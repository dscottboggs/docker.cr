require "../../spec_helper"

test_data = Docker::Container::HostConfig.from_json HostConfigSampleData
describe Docker::Container::HostConfig do
  it "handles the sample JSON text" do
    test_data.binds.should_not be_nil
    test_data.binds.not_nil!["/tmp"].should eq "/tmp"
    test_data.links.should eq ["redis3:redis"]
    test_data.memory.should eq 0
    test_data.memory_and_swap.should eq 0
    test_data.memory_reservation.should eq 0
    test_data.kernel_memory.should eq 0
    test_data.nano_cpus.should eq 500_000
    test_data.cpu_percent.should eq 80
    test_data.cpu_period.should eq 100_000
    test_data.cpu_realtime_period.should eq 1_000_000
    test_data.cpu_realtime_runtime.should eq 10_000
    test_data.cpu_quota.should eq 50_000
    test_data.allowed_CPUs.should eq "0,1"
    test_data.cpu_set_mems.should eq "0,1"
    test_data.maximum_iops.should eq 0
    test_data.maximum_bandwidth.should eq 0
    test_data.blkio_weight.should eq 300
    # BlkioDevice
    test_data.memory_swappiness.should eq 60
    test_data.oom_kill_disable.should be_false
    test_data.oom_score_adjustment.should eq 500
    test_data.pid_mode.should eq ""
    test_data.pids_limit.should eq -1
    # test_data.port_bindings test separately
    test_data.publish_all_ports?.should be_false
    test_data.privileged?.should be_false
    test_data.read_only_rootfs?.should be_false
    test_data.dns.should eq ["8.8.8.8"]
    test_data.dns_options.should eq [""]
    test_data.dns_search.should eq [""]
    test_data.volumes_from.should contain "parent"
    test_data.volumes_from.should contain "other:ro"
    test_data.cap_add.should eq ["NET_ADMIN"]
    test_data.cap_drop.should eq ["MKNOD"]
    test_data.group_add.should eq ["newgroup"]
    # test_data.restart_policy test separately
    test_data.auto_remove?.should be_true
    test_data.network_mode.should eq "bridge"
    test_data.devices.should eq [] of DeviceMapping
    test_data.log_config.should_not be_nil
    test_data.log_config.not_nil!["Type"].should eq "json-file"
    test_data.log_config.not_nil!["Config"].should eq ({} of JSON::Any => JSON::Any)
    test_data.secure_opt.not_nil!.empty?.should be_true
    test_data.storage_opt.not_nil!.empty?.should be_true
    test_data.cgroup_parent.should eq ""
    test_data.volume_driver.should eq ""
    test_data.shm_size.should eq 67108864
  end
  describe Docker::Container::HostConfig::ULimit do
    it "handles the sample JSON text" do
      test_data.u_limits.should_not be_nil
      test_data.u_limits.not_nil![0].not_nil!.name.should eq "nofile"
      test_data.u_limits.not_nil![0].not_nil!.soft.should eq 1024
      test_data.u_limits.not_nil![0].not_nil!.hard.should eq 2048
    end
  end
end

describe Docker::APIClient::ThrottleDevice do
  it "handles the host configuration sample JSON text" do
    test_data.blkio_device_read_bps.not_nil![0].not_nil!.path.should eq "device_path"
    test_data.blkio_device_read_bps.not_nil![0].not_nil!.rate.should eq 9001
  end
end
