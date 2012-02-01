require 'spec_helper'

describe Heidi::Git do
  let(:git) { Heidi::Git.new() }

  it "should can find the HEAD" do
    git.commit.should_not be_empty
    git.commit.should == git.HEAD
  end

  it "should list all branches" do
    git.branches.should be_kind_of(Array)
  end

  it "should list the current branch" do
    git.branch.should_not be_empty
    git.branch.should_not =~ /^\*/
  end

  it "should list the tags" do
    git.tags.should be_kind_of(Array)
  end

  describe "config" do
    let(:random) { "#{rand(1000)}.#{rand(1000)}" }

    it "should write configs" do
      git["test.entry"].should_not == random
      git["test.entry"] = random
    end

    it "should read configs" do
      git["test.entry"].should_not == be_empty
    end
  end
end
