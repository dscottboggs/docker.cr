require "./image"
require "./images/list_response"

module Docker
  class APIClient
    module Images
      # retreive the collection of all images, optionally filtered with filters.
      def images(all : Bool = false, filters : ImageFilters = ImageFilters.none)
        ImageCollection.request all, filters
      end

      def images(
        *,
        all : Bool = false,
        before : Tag? = nil,
        dangling = true,
        label : String | Tuple(String, String) | Nil = nil,
        reference : Tag? = nil,
        since : Tag? = nil
      )
        images(
          all: all,
          filters: ImageFilters.new(
            before: before,
            dangling: dangling,
            label: label,
            reference: reference,
            since: since
          )
        )
      end

      def [](image)
        ImageCollection[image]
      end

      def []?(image)
        ImageCollection[image]?
      end
    end
  end

  # a collection of Images, and a few convenience methods for dealing with
  # said collection
  class ImageCollection < Array(Image)
    def self.request(
      all : Bool = false,
      filters : ImageFilters = ImageFilters.none
    )
      params = HTTP::Params.build do |q|
        q.add "all", "true" if all
        q.add "filters", filters.to_json unless filters.none?
        q.add "digests", "true"
      end
      response = Docker.client.get "/images/json?#{params}"
      Array(Docker::Image::ListResponse).from_json response.body
    rescue e : JSON::ParseException
      begin
        if (r = response).nil?
          raise e
        else
          [Docker::Image::ListResponse.from_json r.body]
        end
      rescue JSON::ParseException
        raise e
      end
    end

    def self.all
      self.request all: true
    end

    def self.filter_by(filters : ImageFilters)
      self.request all: true, filters: filters
    end

    # Find images tagged with the given tag.
    def self.find(tag : Tag)
      self.request all: true, filters: ImageFilters.new(reference: tag)
    end

    # Retreive an image by its ID.
    def self.[]?(img_id : String) : Docker::Image::ListResponse?
      self.request.find { |img| img.id === img_id }
    end

    def self.[](img_id : String) : Docker::Image::ListResponse
      self[img_id]? || raise Docker::APIClient::NotFound.new(
        "image", "image ID: #{img_id}"
      )
    end

    def []?(img_id : String) : Image?
      self.find { |img| img.id === img_id }
    end

    def [](img_id : String) : Image
      self.[img_id]? || raise Docker::APIClient::NotFound.new(
        "Image", "image ID: #{img_id}"
      )
    end
  end
end
