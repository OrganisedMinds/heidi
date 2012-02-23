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

  it "should have an author"
  it "should have a date"
  it "should have a time"
  it "should load hooks"
  it "should clean up"

  describe "Locking" do
    it "should not be locked" do
      @build.should_not be_locked
    end

    it "should be lockable" do
      @build.lock
      @build.should be_locked
    end

    it "should be unlockable" do
      @build.unlock
      @build.should_not be_locked
    end

    it "should be block-lockable" do
      @build.should_not be_locked
      @build.lock do
        @build.should be_locked
      end
      @build.should_not be_locked
    end

  end

  describe "Logging" do
    it "should have logs" do
      @build.logs.should be_kind_of(Heidi::Build::Logs)
    end

    it "should write to a log file" do
      log  = "my_new.log"
      file = File.join(@build.log_root, log)

      File.exists?(file).should_not be_true

      @build.logs[log].write("the message")

      File.exists?(file).should be_true
      File.read(file).should =~ /the message/
    end

    it "should read from a log file" do
      log  = "my_new.log"
      @build.logs[log].read.should =~ /the message/
    end

    it "should have convenience methods for heidi.* logs" do
      @build.log(:info, "my custom message")
      @build.logs["heidi.info"].read.should =~ /my custom message/
    end
  end

  describe "Records" do
    it "should have a status" do
      survivable do
        File.unlink(File.join(@build.root, Heidi::Build::FAILURE))
        File.unlink(File.join(@build.root, Heidi::Build::SUCCESS))
      end

      @build.status.should == Heidi::DNF
    end

    it "should return failed?" do
      survivable do
        File.unlink(File.join(@build.root, Heidi::Build::FAILURE))
      end

      @build.should_not be_failed
      @build.status.should_not == Heidi::FAILED
    end

    it "should return success?" do
      survivable do
        File.unlink(File.join(@build.root, Heidi::Build::FAILURE))
      end

      @build.should_not be_success
      @build.status.should_not == Heidi::PASSED
    end

    it "should record success" do
      @build.record(:success)
      @build.should be_success
      @build.status.should == Heidi::PASSED
    end

    it "should record failure" do
      @build.record(:failure)
      @build.should be_failed
      @build.status.should == Heidi::FAILED
    end

    it "should provide a tar-ball"
  end
end
