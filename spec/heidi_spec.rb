require 'spec_helper'

describe Heidi do
  before(:all) do
    fake_me_a_heidi
  end

  it "should gather projects on load" do
    h = Heidi.new("/tmp/heidi_spec")
    h.projects.should be_kind_of(Array)
    h.projects.count.should == 1
  end
end
