require 'spec_helper'
require 'rack/test'
require 'heidi/web'

describe Heidi::Web do
  before :all do
    fake_me_a_heidi
  end

  before :each do
    Heidi::Web.stub(:project_path).and_return(@fake)
  end

  after :all do
    FileUtils.remove_entry_secure @fake
  end

  include Rack::Test::Methods

  def app
    Heidi::Web
  end

  it "should move away from /" do
    get '/'
    last_response.status.should == 302
  end

  it "should show a homepage" do
    get '/projects/'
    last_response.status.should == 200
    last_response.body.should =~ /Heidi/
  end

  it "should display the projects on the homepage" do
    get '/projects/'
    last_response.body.should =~ /heidi_test/
  end

  it "should display the project page"
  it "should display the configuration page"
  it "should display a build"
  it "should display a commit"
end