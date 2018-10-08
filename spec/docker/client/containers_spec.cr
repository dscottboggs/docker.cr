require "../../spec_helper"

describe Docker::Client::Containers do

  describe ".containers" do
    WebMock.reset
    ENV["DOCKER_HOST"] = "tcp://localhost:1337"
    WebMock
      .stub(:get, "http://localhost:1337/containers/json")
      .with(query: {
        "all" => "false", "limit" => "", "since" => "", "before" => "", "size" => "false", "filters" => "{}"
      })
      .to_return([
        { "Id" => "test1" },
        { "Id" => "test2" }
      ].to_json)

    subject {  }
    it "is a Array(Docker::Container)" do
      Docker.client.containers.should be_an Array(Docker::Container)
    end

    ENV.delete "DOCKER_HOST"
  end
end
