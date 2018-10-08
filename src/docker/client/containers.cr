module Docker
  class APIClient
    module Containers

      def containers(
        all    : Bool    = false,
        limit  : Int32?  = nil,
        since  : String? = nil,
        before : String? = nil,
        size   : Bool    = false,
        filters          = {} of String => Array(String)
      )
        params = HTTP::Params.build do |qs|
          qs.add "all", all.to_s
          qs.add "limit", limit.to_s
          qs.add "since", since
          qs.add "before", before
          qs.add "size", size.to_s
          qs.add "filters", filters.to_json
        end
        Array(Docker::Container).from_json(
          Docker.client.get(
            "/containers/json?#{params}"
          ).body
        )
      end

    end
  end
end
