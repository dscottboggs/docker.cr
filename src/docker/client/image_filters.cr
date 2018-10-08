require "json"

module Docker
  # Filter out the results of the Images by passing an instantiated ImageFilters
  # object. See https://docs.docker.com/engine/api/v1.30/#operation/ImageList
  class ImageFilters
    JSON.mapping({
      before:    Tag?,
      dangling:  {type: Bool, default: true},
      label:     String?,
      reference: Tag?,
      since:     Tag?,
    })
    # Return only images with earlier versions than the given tag
    property before
    # Return dangling images?
    property dangling
    # Return images matching a particular tag
    property reference
    # Return only immages since the given tagged version
    property since
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
