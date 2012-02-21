require 'spec_helper'
require 'fileutils'

describe Heidi::Project do
  before(:all) do
    fake_me_a_heidi
  end

  after(:all) do
    FileUtils.remove_entry_secure @fake
  end

  before(:each) do
    @project = @heidi[:heidi_test]
  end

  it "should be available" do
    @project.should_not be_nil
  end

  describe "Before first fetch" do
    it "should have no builds" do
      @project.builds.count == 0
    end

    it "should have a base name" do
      @project.basename.should == "heidi_test"
    end

    it "should have a given name" do
      @project.name.should == "heidi_test"
    end

    it "should have a settable name" do
      @project.name = "Heidi Test"
      @project.name.should == "Heidi Test"
    end

    it "should have a current commit" do
      @project.commit.should_not be_empty
      @project.commit.length.should == 8
    end

    it "should have a current author" do
      @project.author.should_not be_empty
    end

    it "should have a current date" do
      @project.date.should_not be_empty
    end

    it "should not have a last commit" do
      @project.last_commit.should be_empty
    end

    it "should not have a current build" do
      @project.current_build.should be_empty
    end

    it "should not have a latest build" do
      @project.latest_build.should be_empty
    end

    it "should not have build status" do
      @project.build_status.should be_empty
    end
  end

  describe "Fetching" do
    it "should fetch" do
      expect { @project.fetch }.not_to raise_error
    end

    it "should have a last commit" do
      @project.last_commit.should_not be_empty
    end
  end

  describe "Integration" do
    it "should integrate" do
      output = ""
      expect { output = @project.integrate }.not_to raise_error
      output.should be_nil
    end

    it "should have a current build" do
      @project.current_build.should_not be_empty
    end

    it "should have a latest build" do
      @project.latest_build.should_not be_empty
    end

    it "should have build status" do
      @project.build_status.should_not be_empty
      @project.build_status.should == Heidi::PASSED
    end
  end

  describe "Locking" do
    it "should not be locked" do
      @project.should_not be_locked
    end

    it "should be lockable" do
      @project.lock
      @project.should be_locked
    end

    it "should have surviving locks" do
      @project.should be_locked
    end

    it "should be unlockable" do
      @project.unlock
      @project.should_not be_locked
    end

    it "should be block lockable" do
      @project.should_not be_locked
      @project.lock do
        @project.should be_locked
      end
      @project.should_not be_locked
    end
  end

  describe "Branches" do
    it "should return a list of integration branches" do
      @project.integration_branches.should_not be_empty
      @project.integration_branches.should include("origin/master")
    end

    it "should have no default integration branch" do
      @project.integration_branch.should be_nil
    end

    it "should allow for the setting of a branch" do
      @project.integration_branch = "foo"
      @project.integration_branch.should == "foo"
    end

    it "should strip origin from the branch name" do
      @project.integration_branch = "origin/master"
      @project.integration_branch.should == "master"
    end

    it "should set cached to the integration branch" do
      git = Heidi::Git.new(@project.cached_root)
      git.checkout("something_else", "develop")
      git.branch.should_not == "develop"

      @project.integration_branch = "origin/develop"
      @project.fetch

      git.branch.should == @project.integration_branch
    end
  end

  describe "Commits" do
    it "should return the stat of a commit" do
      @project.stat(@project.HEAD).should_not be_empty
    end

    it "should return the diff of a commit" do
      @project.diff(@project.HEAD).should_not be_empty
    end
  end
end