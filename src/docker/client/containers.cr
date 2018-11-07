require "../container/list_response"

module Docker
  class APIClient
    module Containers
      extend self

      def containers(all : Bool = false,
                     limit : Int32? = nil,
                     since : String? = nil,
                     before : String? = nil,
                     size : Bool = false,
                     filters = {} of String => Array(String))
        Docker::Container::ListResponse.request(
          all: all,
          limit: limit,
          since: since,
          before: before,
          size: size,
          filters: filters).map do |container|
          if (names = container.names).empty?
            Docker::Container.new container.image, container.id
          else
            Docker::Container.new container.image, container.id, names
          end
        end
      end

      def [](id_or_name : String, *, since : String? = nil, before : String? = nil)
        containers(all: true, since: since, before: before).select do |container|
          container.id == id_or_name || container.names.includes? id_or_name
        end.map do |container|
          if (names = container.names).empty?
            Docker::Container.new container.image, container.id
          else
            Docker::Container.new container.image, container.id, names
          end
        end
      end

      def [](id_or_name : Regex, *, since : String? = nil, before : String? = nil)
        containers(all: true, since: since, before: before).select do |container|
          container.id.match(id_or_name) || !container.names.select { |n| n.match id_or_name }.empty?
        end.map do |container|
          if (names = container.names).empty?
            Docker::Container.new container.image, container.id
          else
            Docker::Container.new container.image, container.id, names
          end
        end
      end
    end
  end
end
