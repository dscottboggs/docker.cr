struct DeviceMapping
  include JSON::Serializable

  def initialize(@path_on_host, @path_in_container, @cgroup_permissions)
  end

  @[JSON::Field(key: "PathOnHost")]
  property path_on_host : String
  @[JSON::Field(key: "PathInContainer")]
  property path_in_container : String
  @[JSON::Field(key: "CgroupPermissions")]
  property cgroup_permissions : String
end
