require "../../spec_helper"

describe Docker::ImageFilters do
  describe ".none" do
    it "returns the default filters" do
      none = Docker::ImageFilters.none
      none.before.should be_nil
      none.dangling.should be_nil
      none.label.should be_nil
      none.reference.should be_nil
      none.since.should be_nil
    end
  end
  describe "#none?" do
    Docker::ImageFilters.none.none?.should be_true
    Docker::ImageFilters.new.none?.should be_true
  end
end
