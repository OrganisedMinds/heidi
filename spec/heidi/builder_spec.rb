require 'spec_helper'

describe Heidi::Builder do
  before(:all) do
    fake_me_a_heidi
  end

  after(:all) do
    FileUtils.remove_entry_secure @fake
  end

  before(:each) do
    @project = @heidi[:heidi_test]
    @build = Heidi::Build.new(@project)
  end

  it "should create a build dir" do
    builder = Heidi::Builder.new(@build)
    result = builder.build!
    result.should_not be_false

    File.directory?(File.join(@project.root, "logs", @project.commit))
  end

  it "should write to the info log" do
    @build.logs["heidi.info"].read.should_not be_empty
  end

  it "should replace a build dir" do
    File.directory?(File.join(@project.root, "logs", @project.commit))
    prev_logs = @build.logs["heidi.info"].read

    @build.unlock if @build.locked?

    builder = Heidi::Builder.new(@build)
    result = builder.build!
    result.should_not be_false

    File.directory?(File.join(@project.root, "logs", @project.commit))
    build_logs = @build.logs["heidi.info"].read
    build_logs.should_not == prev_logs

    build_logs.should =~ /removing previous build/i
  end

  it "should leave the heidi.errors log empty" do
    @build.logs["heidi.errors"].read.should be_empty
  end

  it "should leave the build directory locked" do
    @build.unlock

    builder = Heidi::Builder.new(@build)
    result = builder.build!
    result.should_not be_false
    @build.should be_locked
  end

  it "should not replace a locked build dir" do
    builder = Heidi::Builder.new(@build)
    result = builder.build!
    result.should be_false
    @build.logs["heidi.errors"].read.should =~ /build was locked/i
  end
end