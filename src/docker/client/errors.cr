module Docker
  class APIClient
    class Exception < ::Exception
    end

    class InternalServerError < Exception
      def initialize(endpoint : String, response : HTTP::Client::Response)
        super "\
          Got 'internal server error' from the docker daemon at \
          endpoint #{endpoint}.\nResponse body: #{response.body?}."
      end
    end

    class BadParameter < Exception
      def initialize(endpoint : String, parameter : String, parameter_value)
        super "\
          got invalid parameter #{parameter} with value #{parameter_value} for \
          endpoint #{endpoint}."
      end

      def initialize(endpoint : String, response : HTTP::Client::Response)
        super "\
          Got 'bad parameter' from the docker daemon at endpoint #{endpoint}.\
          \nResponse body: #{response.body?}."
      end
    end

    class NotFound < Exception
      def initialize(resource_type : String, identifier : String)
        super "\
          the requested #{resource_type} resource (identifier #{identifier}) \
          couldn't be found."
      end

      def initialize(
        resource_type : String,
        endpoint : String,
        response : HTTP::Client::Response? = nil
      )
        super "\
          The docker daemon couldn't find the #{resource_type} \
          at #{endpoint}." + (
          response.nil? ? "" : "\nResponse body: #{response.body?}"
        )
      end
    end

    class NotYetImplemented < Exception
      def initialize(feature : Symbol)
        super "the feature #{feature.to_s} is not yet implemented."
      end
    end
  end
end
