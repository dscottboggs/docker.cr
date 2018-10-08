require "../spec_helper"

describe Docker::Container do

  describe "#start" do

    # TODO: Find a way to test those.

    # context "success" do
    #   before do
    #     WebMock.stub(:post, "localhost/containers/test/start").to_return(status: 204)
    #   end
    #   it "returns itself" do
    #     expect(subject.start).to be(subject)
    #   end
    # end

    # context "already started" do
    #   before do
    #     WebMock.stub(:post, "localhost/containers/test/start").to_return(status: 304)
    #   end
    #   it "returns itself" do
    #     expect(subject.start).to be(subject)
    #   end
    # end

    context "not found" do
      WebMock.reset
      ENV["DOCKER_HOST"] = "tcp://localhost:80"
      WebMock.stub(:post, "localhost/containers/test/start").to_return(status: 404)
      it "raises error" do
        expect_raises(Docker::APIClient::NotFound) do
          Docker::Container.from_json({"Id" => "test"}.to_json).start
        end
        expect_raises(Docker::APIClient::Exception) do
          Docker::Container.from_json({"Id" => "test"}.to_json).start
        end
      end
      ENV.delete("DOCKER_HOST")
    end

    context "server error" do
      WebMock.reset
      ENV["DOCKER_HOST"] = "tcp://localhost:80"
      WebMock.stub(:post, "localhost/containers/test/start").to_return(status: 500)
      it "raises error" do
        expect_raises(Docker::APIClient::InternalServerError) do
          Docker::Container.from_json({"Id" => "test"}.to_json).start
        end
        expect_raises(Docker::APIClient::Exception) do
          Docker::Container.from_json({"Id" => "test"}.to_json).start
        end
      end
      ENV.delete("DOCKER_HOST")
    end

  end

  describe "#stop" do

    # TODO: Find a way to test those.

    # context "success" do
    #   before do
    #     WebMock.stub(:post, "localhost/containers/test/stop?t=5").to_return(status: 204)
    #   end
    #   it "returns itself" do
    #     expect(subject.stop).to be(subject)
    #   end
    # end

    # context "already stoped" do
    #   before do
    #     WebMock.stub(:post, "localhost/containers/test/stop?t=5").to_return(status: 304)
    #   end
    #   it "returns itself" do
    #     expect(subject.stop).to be(subject)
    #   end
    # end

    context "not found" do
      WebMock.reset
      ENV["DOCKER_HOST"] = "tcp://localhost:80"
      WebMock.stub(:post, "localhost/containers/test/stop?t=5").to_return(status: 404)
      expect_raises(Docker::APIClient::NotFound) do
        Docker::Container.from_json({"Id" => "test"}.to_json).stop
      end
      expect_raises(Docker::APIClient::Exception) do
        Docker::Container.from_json({"Id" => "test"}.to_json).stop
      end
      ENV.delete("DOCKER_HOST")
    end

    context "server error" do
      WebMock.reset
      ENV["DOCKER_HOST"] = "tcp://localhost:80"
      WebMock.stub(:post, "localhost/containers/test/stop?t=5").to_return(status: 500)
      expect_raises(Docker::APIClient::InternalServerError) do
        Docker::Container.from_json({"Id" => "test"}.to_json).stop
      end
      expect_raises(Docker::APIClient::Exception) do
        Docker::Container.from_json({"Id" => "test"}.to_json).stop
      end
      ENV.delete("DOCKER_HOST")
    end
  end

  describe "#restart" do

    # TODO: Find a way to test those.

    # context "success" do
    #   before do
    #     WebMock.stub(:post, "localhost/containers/test/restart?t=5").to_return(status: 204)
    #   end
    #   it "returns itself" do
    #     expect(subject.restart).to be(subject)
    #   end
    # end

    # context "already restarted" do
    #   before do
    #     WebMock.stub(:post, "localhost/containers/test/restart?t=5").to_return(status: 304)
    #   end
    #   it "returns itself" do
    #     expect(subject.restart).to be(subject)
    #   end
    # end

    context "not found" do
      WebMock.reset
      ENV["DOCKER_HOST"] = "tcp://localhost:80"
      WebMock.stub(:post, "localhost/containers/test/restart?t=5").to_return(status: 404)
      expect_raises(Docker::APIClient::NotFound) do
        Docker::Container.from_json({"Id" => "test"}.to_json).restart
      end
      expect_raises(Docker::APIClient::Exception) do
        Docker::Container.from_json({"Id" => "test"}.to_json).restart
      end
      ENV.delete("DOCKER_HOST")
    end

    context "server error" do
      WebMock.reset
      ENV["DOCKER_HOST"] = "tcp://localhost:80"
      WebMock.stub(:post, "localhost/containers/test/restart?t=5").to_return(status: 500)
      expect_raises(Docker::APIClient::InternalServerError) do
        Docker::Container.from_json({"Id" => "test"}.to_json).restart
      end
      expect_raises(Docker::APIClient::Exception) do
        Docker::Container.from_json({"Id" => "test"}.to_json).restart
      end
      ENV.delete("DOCKER_HOST")
    end
  end

  describe "#kill" do

    # TODO: Find a way to test those.

    # context "success" do
    #   before do
    #     WebMock.stub(:post, "localhost/containers/test/kill").to_return(status: 204)
    #   end
    #   it "returns itself" do
    #     expect(subject.kill).to be(subject)
    #   end
    # end

    # context "already killed" do
    #   before do
    #     WebMock.stub(:post, "localhost/containers/test/kill").to_return(status: 304)
    #   end
    #   it "returns itself" do
    #     expect(subject.kill).to be(subject)
    #   end
    # end

    context "not found" do
      WebMock.reset
      ENV["DOCKER_HOST"] = "tcp://localhost:80"
      WebMock.stub(:post, "localhost/containers/test/kill").to_return(status: 404)
      expect_raises(Docker::APIClient::NotFound) do
        Docker::Container.from_json({"Id" => "test"}.to_json).kill
      end
      expect_raises(Docker::APIClient::Exception) do
        Docker::Container.from_json({"Id" => "test"}.to_json).kill
      end
      ENV.delete("DOCKER_HOST")
    end

    context "server error" do
      WebMock.reset
      ENV["DOCKER_HOST"] = "tcp://localhost:80"
      WebMock.stub(:post, "localhost/containers/test/kill").to_return(status: 500)
      expect_raises(Docker::APIClient::InternalServerError) do
        Docker::Container.from_json({"Id" => "test"}.to_json).kill
      end
      expect_raises(Docker::APIClient::Exception) do
        Docker::Container.from_json({"Id" => "test"}.to_json).kill
      end
      ENV.delete("DOCKER_HOST")
    end
  end
end
