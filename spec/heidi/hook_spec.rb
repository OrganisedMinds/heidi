require 'spec_helper'

describe Heidi::Hook do
  before(:all) do
    fake_me_a_heidi
    @script = File.join(@fake, "projects/heidi_test/hooks/before/testing_hook.sh")
    File.open(@script, File::CREAT|File::WRONLY) do |f|
      f.puts %Q(#!/bin/sh

printenv > #{@fake}/testing_hook.out
)
    end

    SimpleShell.new(@fake).chmod %W(+x #{@script})
  end

  after(:all) do
    FileUtils.remove_entry_secure @fake
  end

  before(:each) do
    @project = @heidi[:heidi_test]
    @build = Heidi::Build.new(@project)
    @hook  = Heidi::Hook.new(@build, @script)
  end

  it "has a name" do
    @hook.name.should == "before/testing_hook.sh"
  end

  it "performs" do
    outfile = File.join(@fake, "testing_hook.out")
    File.exists?(outfile).should_not be_true
    @hook.perform
    @hook.should_not be_failed
    File.exists?(outfile).should be_true
  end

  it "resets the environment" do
    @hook.perform
    @hook.should_not be_failed
    contents = File.read(File.join(@fake, "testing_hook.out"))

    contents.should_not =~ /RUBYOPT/
    contents.should_not =~ /GEM_HOME/
    contents.should_not =~ /GEM_PATH/
    contents.should_not =~ /BUNDLE_/
    contents.should =~ /HEIDI_BUILD_/
    contents.should =~ /HEIDI_LOG_DIR/
  end
end