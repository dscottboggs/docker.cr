require "./spec_helper"

describe Docker do
  describe ".client" do
    it "is a Docker::APIClient" do
      Docker.client.should be_a(Docker::APIClient)
    end
  end
end
