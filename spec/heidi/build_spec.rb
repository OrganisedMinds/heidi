require 'spec_helper'

describe Heidi::Build do
  before(:all) do
    fake_me_a_heidi

    @project = @heidi[:heidi_test]
  end

  after(:all) do
    FileUtils.remove_entry_secure @fake
  end

  before :each do
    @build = Heidi::Build.new(@project)
  end

  it "should have a project" do
    @build.project.should == @project
  end

  it "should be tied to a commit" do
    @build.commit.should == @project.commit
  end

  it "should have a root" do
    @build.root.should == File.join(@project.root, "logs", @project.commit)
  end

  it "should have a log root" do
    @build.log_root.should == File.join(@build.root, "logs")
  end

  it "should have a build root" do
    @build.build_root.should == File.join(@build.root, "build")
  end

  describe "Locking" do
    it "should not be locked" do
      @build.should_not be_locked
    end

    it "should be lockable"
    it "should be block-lockable"
    it "should be unlockable"
  end

  describe "Logging" do
    it "should have logs"
    it "should write to a log file"
    it "should read from a log file"
    it "should have convenience methods for heidi.* logs"
    it "should have x"
  end

  it "has not enough tests" do
    pending "more tests please!"
  end
end
