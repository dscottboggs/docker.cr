require "../spec_helper"

describe Docker::Container do
  # TODO integration tests

  {% for method in {:start, :stop, :restart, :kill} %}

  describe "#" + "{{method.id}}" do
    context "success" do
      WebMock.reset
      WebMock.stub(:post, "localhost/containers/test/{{method.id}}").to_return(status: 204)
      WebMock.stub(:post, "localhost/containers/test/{{method.id}}").with(query:{"t" => "5"}).to_return(status: 204)
      it "returns itself" do
        subject = Docker::Container.new(id: "test", image: "some:image")
        subject.{{method.id}}.should be subject
      end
    end

    context "already {{method.id}}ed" do
      WebMock.reset
      WebMock.stub(:post, "localhost/containers/test/{{method.id}}").to_return(status: 304)
      WebMock.stub(:post, "localhost/containers/test/{{method.id}}").with(query:{"t" => "5"}).to_return(status: 304)
      it "returns itself" do
        buffer = IO::Memory.new
        subject = Docker::Container.new(id: "test", image: "some:image", warnings: buffer)
        subject.{{method.id}}.should be subject
        buffer.rewind
        warning_text = buffer.gets
        warning_text.should_not be_nil
        warning_text.try &.starts_with?("container test already {{method.id}}").should be_true
      end
    end

    context "not found" do
      WebMock.reset
      ENV["DOCKER_HOST"] = "tcp://localhost:80"
      WebMock.stub(:post, "localhost/containers/test/{{method.id}}").to_return(status: 404)
      WebMock.stub(:post, "localhost/containers/test/{{method.id}}").with(query:{"t" => "5"}).to_return(status: 404)
      it "raises error" do
        expect_raises(Docker::APIClient::NotFound) do
          Docker::Container.new(id: "test", image: "some:image").{{method.id}}
        end
        expect_raises(Docker::APIClient::Exception) do
          Docker::Container.new(id: "test", image: "some:image").{{method.id}}
        end
      end
      ENV.delete("DOCKER_HOST")
    end

    context "server error" do
      WebMock.reset
      ENV["DOCKER_HOST"] = "tcp://localhost:80"
      WebMock.stub(:post, "localhost/containers/test/{{method.id}}").to_return(status: 500)
      WebMock.stub(:post, "localhost/containers/test/{{method.id}}").with(query:{"t" => "5"}).to_return(status: 500)
      it "raises error" do
        expect_raises(Docker::APIClient::InternalServerError) do
          Docker::Container.new(id: "test", image: "some:image").{{method.id}}
        end
        expect_raises(Docker::APIClient::Exception) do
          Docker::Container.new(id: "test", image: "some:image").{{method.id}}
        end
      end
      ENV.delete("DOCKER_HOST")
    end
  end
  {% end %}

  describe ".create" do
    context "success" do
      WebMock.reset
      WebMock
        .stub(:post, "localhost/containers/create")
        .with(body: CreateContainerSampleData.to_json)
        .with(query: {"name" => "test-image-name"})
        .to_return(status: 200, body: {"Id" => "test", "Warnings" => ["fake warning"]}.to_json)
      buffer = IO::Memory.new
      subject = Docker::Container.create(
        image: Docker::Tag.new(image_name: "some", tag: "image"),
        name: "test-image-name",
        warnings: buffer)
      it "responds with the correct values" do
        subject.should be_a Docker::Container
        subject.id.should eq "test"
        subject.image.image_name.should eq "some"
        subject.image.tag.should eq "image"
        subject.names.should eq ["test-image-name"]
        buffer.rewind.gets.should eq "fake warning"
      end
    end
    context "server error" do
      WebMock.reset
      WebMock
        .stub(:post, "localhost/containers/create")
        .with(body: {"Image" => "some:image"}.to_json)
        .with(query: {"name" => "test-image-name"})
        .to_return(status: 500)
      it "raises Docker::APIClient::InternalServerError" do
        expect_raises Docker::APIClient::InternalServerError do
          subject = Docker::Container.create(
            image: Docker::Tag.new(image_name: "some", tag: "image"),
            name: "test-image-name")
        end
      end
    end
    context "when not found" do
      WebMock.reset
      WebMock
        .stub(:post, "localhost/containers/create")
        .with(body: {"Image" => "some:image"}.to_json)
        .with(query: {"name" => "test-image-name"})
        .to_return(status: 404)
      it "raises Docker::APIClient::NotFound" do
        expect_raises Docker::APIClient::NotFound do
          Docker::Container.create(
            image: Docker::Tag.new(image_name: "some", tag: "image"),
            name: "test-image-name")
        end
      end
    end
    context "when a conflict arises" do
      WebMock.reset
      WebMock
        .stub(:post, "localhost/containers/create")
        .with(body: {"Image" => "some:image"}.to_json)
        .with(query: {"name" => "test-image-name"})
        .to_return(status: 409)
      it "raises Docker::APIClient::Exception" do
        expect_raises Docker::APIClient::Exception do
          Docker::Container.create(
            image: Docker::Tag.new(image_name: "some", tag: "image"),
            name: "test-image-name")
        end
      end
    end
  end
end
