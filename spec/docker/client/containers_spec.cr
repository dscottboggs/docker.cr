require "../../spec_helper"

describe Docker::APIClient::Containers do
  WebMock.reset
  ENV["DOCKER_HOST"] = "tcp://localhost:1337"
  WebMock
    .stub(:get, "http://localhost:1337/containers/json")
    .with(query: {
    "all" => "false", "limit" => "", "since" => "", "before" => "", "size" => "false", "filters" => "{}",
  })
    .to_return([
    {"Id" => "test1", "Image" => "some:image"},
    {"Id" => "test2", "Image" => "some:image"},
  ].to_json)
  WebMock
    .stub(:get, "http://localhost:1337/containers/json")
    .with(query: {
    "all" => "true", "limit" => "", "since" => "", "before" => "", "size" => "false", "filters" => "{}",
  })
    .to_return([
    {"Id" => "test1", "Image" => "some:image"},
    {"Id" => "test2", "Image" => "some:image"},
  ].to_json)

  describe ".containers" do
    it "is a Array(Docker::Container)" do
      Docker.client.containers.should be_a Array(Docker::Container)
    end
  end

  describe ".[]" do
    it "accesses a particular ID." do
      result = Docker::APIClient::Containers["test1"].first
      result.id.should eq "test1"
      result.image.image_name.should eq "some"
      result.image.tag.should eq "image"
    end
    it "returns an empty list when it can't find anything" do
      result = Docker::APIClient::Containers["nonexistent and invalid image name"]
      result.empty?.should be_true
      result.should be_a Array(Docker::Container)
    end
    it "returns all containers that match a given regex" do
      result = Docker::APIClient::Containers[/test./]
      result.each do |r|
        r.id.match(/test./).should_not be_nil
        r.image.image_name.should eq "some"
        r.image.tag.should eq "image"
      end
    end
  end
  ENV.delete "DOCKER_HOST"
  WebMock.reset
end
