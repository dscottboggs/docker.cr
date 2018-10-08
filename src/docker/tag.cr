module Docker
  # A tag for a particular image
  class Tag
    property repo : String?
    property image_name : String
    property tag : String

    def initialize(@image_name : String, @tag : String); end

    def initialize(@repo : String?, @image_name : String, @tag : String); end

    def self.from_json(json : JSON::Any)
      self.from_s(json.as(String))
    end

    def self.from_s(string : String) : self
      repo, image_name, tag = nil, nil, nil
      if string.includes?("/") && string.includes?(":")
        repo, not_repo = string.split "/"
        image_name, tag = not_repo.split(":")
      elsif string.includes? ":"
        image_name, tag = string.split(":")
      elsif string.includes? "/"
        repo, image_name = string.split("/")
        tag = "latest"
      else
        image_name = string
        tag = "latest"
      end
      self.new repo, image_name, tag
    end

    def to_s
      if repo.nil?
        image_name + ":" + tag
      else
        repo.not_nil! + "/" + image_name + ":" + tag
      end
    end
    def to_json
      to_s
    end
    def to_json(builder : JSON::Builder)
      builder.string(to_s)
    end

    def to_params
      String.builder do |path|
        path << "repo="
        path << repo << "/" unless repo.nil?
        path << image_name << "&tag=" << tag
      end
    end
  end
end
