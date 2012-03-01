require 'spec_helper'
require 'rack/test'
require 'heidi/web'

describe Heidi::Web do
  before :all do
    fake_me_a_heidi
  end

  before :each do
    Heidi::Web.stub(:project_path).and_return(@fake)
    @project = @heidi[:heidi_test]
    @project.name = "Heidi Test Project on the web"
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
    last_response.status.should == 200
    last_response.body.should =~ /heidi_test/
  end

  it "should display the project page" do
    get '/projects/heidi_test'
    last_response.status.should == 200
    last_response.body.should =~ /<h1>Heidi Test Project on the web<\/h1>/
  end

  it "should display the configuration page" do
    get '/projects/heidi_test/configure'
    last_response.status.should == 200
    last_response.body.should =~ /Configure Heidi Test Project on the web/
  end

  describe "Project internals" do
    before :each do
      @project.integrate
    end

    it "should display a build" do
      get "/projects/heidi_test/build/#{@project.builds.last.commit}"
      last_response.status.should == 200

      title = Regexp.new("<h2 class=[^>]+>#{@project.builds.last.commit}</h2>")
      last_response.body.should =~ title
    end

    it "should display a commit" do
      get "/projects/heidi_test/commit/#{@project.commit}"
      last_response.status.should == 200
      last_response.body.should =~ Regexp.new("<h2>#{@project.commit}</h2>")

      author = @project.author.gsub("<", "&lt;")
      author.gsub!(">", "&gt;")
      check = Regexp.new("Author: #{author}")
      last_response.body.should =~ check
    end
  end
end