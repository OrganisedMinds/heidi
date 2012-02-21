require 'spec_helper'
require 'heidi/shell'

require 'tmpdir'
require 'fileutils'

class TestClass
end

describe Heidi::Shell do
  before(:all) do
    @dir   = Dir.mktmpdir(nil, "/tmp")
    FileUtils.chdir(@dir)
  end

  after(:all) do
    FileUtils.remove_entry_secure @dir
  end

  before(:each) do
    @shell = Class.new
    @shell.extend(Heidi::Shell)
  end

  it "should create a root directory" do
    @shell.new_heidi_root("test")
    File.exists?(File.join(@dir, "test")).should be_true
    File.directory?(File.join(@dir, "test", "projects")).should be_true
    File.exists?(File.join(@dir, "test", "Gemfile")).should be_true
  end

  it "should create a project directory" do
    FileUtils.chdir(File.join(@dir, "test"))
    @shell.new_project("test", "git://github.com/OrganisedMinds/heidi.git")
    File.directory?(File.join(@dir, "test", "projects", "test")).should be_true
    File.directory?(File.join(@dir, "test", "projects", "test", "cached")).should be_true
    File.directory?(File.join(@dir, "test", "projects", "test", "cached", ".git")).should be_true
  end

  it "should perform integration" do
    FileUtils.chdir(File.join(@dir, "test"))

    # Patch the default test so it will write a random file.
    # Then we can test the existance of the file
    rndm = "#{rand(1000)}.#{rand(1000)}"
    File.exists?(File.join(@dir, "test", "projects", "test", ".test_#{rndm}")).should be_false

    File.open(File.join(@dir, "test", "projects", "test", "hooks", "tests", "01_rspec"), File::TRUNC|File::WRONLY) do |f|
      f.puts %Q{#!/bin/sh

touch $HEIDI_DIR/.test_#{rndm}
}
    end

    # do the integration
    @shell.integrate("test")

    # and now it should be true
    File.exists?(File.join(@dir, "test", "projects", "test", ".test_#{rndm}")).should be_true
  end

  it "should remove a project directory" do
    FileUtils.chdir(File.join(@dir, "test"))
    @shell.remove_project("test")
    File.directory?(File.join(@dir, "test", "projects", "test", "cached")).should be_false
    File.directory?(File.join(@dir, "test", "projects", "test")).should be_true
  end
end