require "json"

module Docker
  # Filter out the results of the Images by passing an instantiated ImageFilters
  # object. See https://docs.docker.com/engine/api/v1.30/#operation/ImageList
  class ImageFilters
    include JSON::Serializable
    # Return only images with earlier versions than the given tag
    property before : Tag?
    # Return dangling images?
    @[JSON::Field(ignore: true)]
    setter dangling : Bool = true

    @[JSON::Field(key: "dangling")]
    def dangling
      if @dangling
        nil
      else
        false
      end
    end
    # Return images matching a particular tag
    property reference : Tag?
    # Return only immages since the given tagged version
    property since : Tag?
    # Filter images which have the given label.
    setter label : Tuple(String, String) | String | Nil

    def initialize(
      @before : Tag? = nil,
      @dangling = true,
      @label : String | Tuple(String, String) | Nil = nil,
      @reference : Tag? = nil,
      @since : Tag? = nil
    )
    end

    # Do not filter anything
    def self.none
      self.new
    end

    # True if this filter won't filter out any images.
    def none?
      before.nil? && dangling && label.nil? && reference.nil? && since.nil?
    end

    def label : String?
      return nil if @label.nil?
      case typeof(@label)
      when String
        @label.as(String)
      when Tuple
        ltpl = @label.as(Tuple(String, String))
        ltpl[0] + '=' + ltpl[1]
      else
        raise "got unrecognized type for label \"#{@label.inspect}\""
      end
    end

    def to_params
      return "" if none?
      HTTP::Params.build do |q|
        l = label
        q.add "all",       "true"      if all
        q.add "before",    before.to_s unless before.nil?
        q.add "dangling",  "false"     unless dangling
        q.add "label",     l           unless l.nil?
        q.add "reference", reference   unless reference.nil?
        q.add "since",     since       unless since.nil?
      end
    end
  end
end
