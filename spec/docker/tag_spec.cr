require "../spec_helper"

describe Docker::Tag do
  it "interpolates various string versions" do
    repo, image_name, tag = "repo", "image", "tag"
    full_string = Docker::Tag.from_s "#{repo}/#{image_name}:#{tag}"
    full_string.repo.should eq repo
    full_string.image_name.should eq image_name
    full_string.tag.should eq tag
    without_tag = Docker::Tag.from_s "#{repo}/#{image_name}"
    without_tag.repo.should eq repo
    without_tag.image_name.should eq image_name
    without_tag.tag.should eq "latest"
    without_repo = Docker::Tag.from_s "#{image_name}:#{tag}"
    without_repo.repo.should be_nil
    without_repo.image_name.should eq image_name
    without_repo.tag.should eq tag
    just_image = Docker::Tag.from_s image_name
    just_image.image_name.should eq image_name
    just_image.tag.should eq "latest"
    just_image.repo.should be_nil
  end
  it "converts properly to a string" do
    repo, image_name, tag = "repo", "image", "tag"
    Docker::Tag.new(repo, image_name, tag).to_s.should eq "repo/image:tag"
    Docker::Tag.new(repo, image_name, tag).to_s.should eq "repo/image:tag"
    Docker::Tag.new(image_name, tag).to_s.should eq "image:tag"
  end
end
