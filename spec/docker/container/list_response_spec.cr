require "../../spec_helper"

subject = Docker::Container::ListResponse.from_json ListResponseSample

describe Docker::Container::ListResponse do
  it "parses the sample data" do
    subject.id.should eq "8dfafdbc3a40"
    subject.names.should eq ["/boring_feynman"]
    subject.image.should eq "ubuntu:latest"
    subject.image_id.should eq "d74508fb6632491cea586a1fd7d748dfc5274cd6fdfedee309ecdcbc2bf5cb82"
    subject.command.should eq "echo i"
    subject.created.should eq 1367854155
    subject.state.should eq "Exited"
    subject.status.should eq "Exit 0"
    subject.labels.should_not be_nil
    subject.labels.not_nil!["com.example.vendor"].should eq "Acme"
    subject.labels.not_nil!["com.example.license"].should eq "GPL"
    subject.labels.not_nil!["com.example.version"].should eq "1.0"
    subject.size_rw.should eq 12288
    subject.size_root_fs.should eq 0
  end
  describe Docker::Container::ListResponse::PortConfig do
    it "parses the sample data" do
      subject.ports.should be_a Array(PortConfig)
      subject.ports[0].should be_a PortConfig
      subject.ports[0].ip.should be_nil
      subject.ports[0].private_port.should eq 2222
      subject.ports[0].public_port.should eq 3333
      subject.ports[0].type.should eq "tcp"
    end
  end
end
