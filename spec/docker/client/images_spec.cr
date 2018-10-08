require "../../spec_helper"

mock_results = [
  {
    "Id"          => "the id of a test image",
    "ParentId"    => "",
    "RepoTags"    => ["first/test-image:1.0.0"],
    "RepoDigests" => Array(String).new(0),
    "Created"     => 1474937122, # arbitrary
    "Size"        => 13 << 19,   # big
    "VirtualSize" => 13 << 19,   # numbers
    "SharedSize"  => 0,
    "Labels"      => Hash(String, String).new,
    "Containers"  => 1,
  }, {
  "Id"          => "sha256 hash value",
  "ParentId"    => "",
  "RepoTags"    => ["testimage:latest"],
  "RepoDigests" => ["sha256", "hash", "values"],
  "Created"     => 1474925151,
  "Size"        => 5 << 20,
  "VirtualSize" => 5 << 20,
  "SharedSize"  => 0,
  "Labels":        {
    "test-label" => "test label value",
  },
  "Containers" => 2,
}, {
  "Id"          => "another sha256 hash value",
  "ParentId"    => "a fourth fake sha256 hash value",
  "RepoTags"    => ["second/test-image:version"],
  "RepoDigests" => Array(String).new(0),
  "Created"     => 1474937151,
  "Size"        => 4 << 22,
  "VirtualSize" => 4 << 22,
  "SharedSize"  => 0,
  "Labels"      => Hash(String, String).new,
  "Containers"  => 3,
},
]

test_find_tag = Docker::Tag.new image_name: "testimage", tag: "latest"

describe Docker::ImageCollection do
  # setup mock and environment
  WebMock.reset
  ENV["DOCKER_HOST"] = "tcp://localhost:1337"
  WebMock
    .stub(:get, "http://localhost:1337/images/json")
    .with(query: {"all" => "true", "digests" => "true"})
    .to_return(mock_results.to_json)
  WebMock
    .stub(:get, "http://localhost:1337/images/json")
    .with(query: {"digests" => "true"})
    .to_return(mock_results.to_json)
  WebMock
    .stub(:get, "http://localhost:1337/images/json")
    .with(query: {
    "filters" => Docker::ImageFilters.new(reference: test_find_tag).to_json,
    "digests" => "true",
  })
    .to_return(mock_results[1].to_json)
  describe ".get" do
    gotten = Docker::ImageCollection["sha256 hash value"]
    # perform the tests
    it "is of the right type" do
      gotten.should be_a Docker::Image
    end
    it "has all the right attributes" do
      gotten.id.should eq "sha256 hash value"
      gotten.parent_id.should be_a(String)
      gotten.parent_id.size.should eq 0
      gotten.repo_tags[0].should eq "testimage:latest"
      gotten.repo_digests[1].should eq "hash"
      gotten.created_at.should eq 1474925151
      gotten.size.should eq 5 << 20
      gotten.virtual_size.should eq 5 << 20
      gotten.shared_size.should eq 0
      gotten.labels["test-label"]?.should eq "test label value"
      gotten.containers.should eq 2
    end
    it "throws an error when requesting an invalid ID" do
      expect_raises Docker::APIClient::NotFound do
        Docker::ImageCollection["invalid image ID"]
      end
    end
  end
  describe "#[]?" do
    it "returns nil when requesting an invalid ID" do
      Docker::ImageCollection["invalid image ID"]?.should be_nil
    end
  end
  describe ".all" do
    all = Docker::ImageCollection.all
    it "is of the right type" do
      all.should be_a(Array(Docker::Image))
    end
    it "gathered the right number of results" do
      all.size.should eq 3
    end
  end
  describe ".find" do
    found = Docker::ImageCollection.find(test_find_tag)
    it "finds the image" do
      found.should be_a Array(Docker::Image)
      found.size.should eq 1
      found[0].id.should eq "sha256 hash value"
    end
  end
  # cleanup
  ENV.delete "DOCKER_HOST"
end

describe Docker::APIClient::Images do
  describe ".images" do
    # setup mock and environment
    WebMock.reset
    ENV["DOCKER_HOST"] = "tcp://localhost:1337"
    WebMock
      .stub(:get, "http://localhost:1337/images/json")
      .with(query: {"all" => "true", "digests" => "true"})
      .to_return(mock_results.to_json)
    WebMock
      .stub(:get, "http://localhost:1337/images/json")
      .with(query: {"all"     => "true",
                    "digests" => "true",
                    "filters" => Docker::ImageFilters.new(
                      label: "test-label",
                    ).to_json})
      .to_return(mock_results[1].to_json)
    context "with ImageFilters object" do
      Docker.client.images(all: true).should eq mock_results
      Docker.client.images(
        all: false,
        filters: Docker::ImageFilters.new(label: "test-label")
      ).should eq mock_results[1]
    end
    context "with filters applied directly" do
      Docker.client.images(all: true).should eq mock_results
      Docker.client.images(
        all: false,
        label: "test-label"
      ).should eq mock_results[1]
    end
    WebMock.reset
    ENV.delete "DOCKER_HOST"
  end
end
