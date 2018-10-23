module Docker
  class ContainerLimits
    property memory : Int32?
    property memory_and_swap : Int32?
    property cpu_shares : Int32?
    property allowed_CPUs : String?
    property cpu_period : Int32?
    property cpu_quota : Int32?

    def initialize(@memory : Int32?,
                   @memory_and_swap : Int32?,
                   @cpu_shares : Int32?,
                   @allowed_CPUs : String?,
                   @cpu_period : Int32?,
                   @cpu_quota : Int32?)
    end

    def to_params
      query = HTTP::Params.build do |q|
        q.add "memory", memory unless memory.nil?
        q.add "memswap", memory_and_swap unless memory_and_swap.nil?
        q.add "cpushares", cpu_shares unless cpu_shares.nil?
        q.add "cpusetcpus", allowed_CPUs unless allowed_CPUs.nil?
        q.add "cpuperiod", cpu_period unless cpu_period.nil?
        q.add "cpuquota", cpu_quota unless cpu_quota.nil?
      end
      query unless query.empty?
    end
  end
end
