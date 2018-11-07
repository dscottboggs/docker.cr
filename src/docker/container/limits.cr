ContainerLimitParams = {
  memory: "memory",
  memory_and_swap: "memswap",
  cpu_shares: "cpushares",
  allowed_CPUs: "cpusetcpus",
  cpu_period: "cpuperiod",
  cpu_quota: "cpuquota"
}
module Docker
  class ContainerLimits
    property memory : Int32?
    property memory_and_swap : Int32?
    property cpu_shares : Int32?
    property allowed_CPUs : String?
    property cpu_period : Int32?
    property cpu_quota : Int32?

    def initialize(@memory : Int32? = nil,
                   @memory_and_swap : Int32? = nil,
                   @cpu_shares : Int32? = nil,
                   @allowed_CPUs : String? = nil,
                   @cpu_period : Int32? = nil,
                   @cpu_quota : Int32? = nil)
    end

    def to_q
      to_q(HTTP::Params.new)
    end
    def to_q(&block : HTTP::Params -> HTTP::Params)
      to_q(yield HTTP::Params.new)
    end
    def to_q(query : HTTP::Params)
      {% for limit, str in ContainerLimitParams %}
      unless (param = {{limit.id}}).nil?
        query.add {{str}}, param.to_s
      end
      {% end %}
      query unless query.empty?
    end
  end
end
