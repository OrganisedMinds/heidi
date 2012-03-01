require 'spec_helper'

describe Heidi::Integrator do
  # not using all, might be slow - but I need clean projects every time
  before(:each) do
    fake_me_a_heidi
    @project = @heidi[:heidi_test]
    @integrator = Heidi::Integrator.new(@project)
  end

  after(:each) do
    FileUtils.remove_entry_secure @fake
  end

  it "should create a build" do
    @integrator.build.should_not be_nil
    @integrator.build.should be_kind_of(Heidi::Build)
  end

  it "should integrate" do
    res = @integrator.integrate
    res.should_not be_kind_of(String)
    res.should_not be_false
  end

  describe "recording" do
    it "should not have any record files" do
      ( File.exists?(
         File.join(@integrator.build.root, Heidi::Build::FAILURE)
        ) | File.exists?(
          File.join(@integrator.build.root, Heidi::Build::SUCCESS)
        )
      ).should be_false
    end

    it "should record success on success" do
      expect {
        @integrator.integrate
      }.to change {
        File.exists? File.join(@integrator.build.root, Heidi::Build::SUCCESS)
      }
    end

    it "should not record anything without test hooks" do
      # remove the test hooks, so the build will fail
      Dir[ File.join(@project.root, "hooks", "tests", "*") ].each do |hook|
        File.unlink hook
      end

      expect {
        @integrator.integrate
      }.to_not change {
        ( File.exists?(
            File.join(@integrator.build.root, Heidi::Build::FAILURE)
          ) | File.exists?(
            File.join(@integrator.build.root, Heidi::Build::SUCCESS)
          )
        ) == false
      }
    end

    it "should record failure on failure" do
      # fix the tests so that they exit 1 (and thus fail)
      Dir[ File.join(@project.root, "hooks", "tests", "*") ].each do |hook|
        File.open(hook, File::WRONLY|File::APPEND) do |f|
          f.puts "\n\nexit 1"
        end
      end

      expect {
        res = @integrator.integrate
      }.to change {
        File.exists? File.join(@integrator.build.root, Heidi::Build::FAILURE)
      }
    end
  end

  describe "Hooks" do
    it "should run hooks" do
      # see MockProject#fake_me_a_heidi as to why this would work
      expect {
        @integrator.integrate
      }.to change {
        File.exists? File.join(@fake, File.basename(@fake))
      }
    end

    it "should survive an empty hooks run" do
      @integrator.run_hooks("no such hooks").should be_true
    end

    it "should keep record of the hooks executed" do
      expect {
        @integrator.integrate
      }.to change {
        @integrator.instance_variable_get :@hooks_ran
      }
    end
  end
end