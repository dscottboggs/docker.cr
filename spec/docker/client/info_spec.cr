require "../../spec_helper"

describe Docker::APIClient::Info do
  describe ".info" do
    WebMock.reset
    ENV["DOCKER_HOST"] = "tcp://localhost:1337"
    WebMock.stub(
      :get,
      "http://localhost:1337/info"
    ).to_return({"Containers" => 30}.to_json)

    it "is a Docker::Info" do
      Docker.client.info.should be_a Docker::Info
    end

    ENV.delete "DOCKER_HOST"
  end

end
