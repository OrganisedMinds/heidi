require 'spec_helper'

describe Heidi do
  before(:all) do
    fake_me_a_heidi
  end

  after(:all) do
    FileUtils.remove_entry_secure @fake
  end

  it "should gather projects on load" do
    @heidi.projects.should be_kind_of(Array)
    @heidi.projects.count.should == 1
  end

  it "should return projects" do
    @heidi.projects.first.should be_kind_of(Heidi::Project)
  end

  it "should respond to [] syntax" do
    @heidi[:heidi_test].should be_kind_of(Heidi::Project)
    @heidi["heidi_test"].should == @heidi.projects.first
  end
end
