require "../spec_helper"

describe Docker::APIClient do
  describe ".new" do
    context "defaults" do
      it "uses unix" do
        Docker::APIClient.new.url.to_s.should eq("unix:///var/run/docker.sock")
      end
    end

    context "env vars" do
      ENV["DOCKER_HOST"] = "tcp://0.0.0.0:8000"
      it "applies environment" do
        Docker::APIClient.new.url.to_s.should eq("tcp://0.0.0.0:8000")
      end
      ENV.delete("DOCKER_HOST")
    end

    context "manual setting" do
      it "applies custom setting" do
        subject = Docker::APIClient.new
        subject.url = "tcp://0.0.0.0:8001"
        subject.url.to_s.should eq("tcp://0.0.0.0:8001")
      end
    end
  end
end
