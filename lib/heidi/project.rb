require './lib/heidi/git'
require './lib/heidi/integrator'
require './lib/heidi/hook'

class Heidi
  class Project
    attr_reader :root, :cached_root, :build_hooks, :test_hooks

    def initialize(root)
      @root = root
      @cached_root = File.join(root, "cached") 
      @git = Heidi::Git.new(@cached_root)
      load_hooks
    end
    
    def load_hooks
      @build_hooks = []
      @test_hooks = []

      Dir[File.join(@root, "hooks", "build", "*")].each do |hook|
        next if File.directory? hook
        next unless File.executable? hook
        @build_hooks << Heidi::Hook.new(self, hook)
      end

      Dir[File.join(@root, "hooks", "tests", "*")].each do |hook|
        next if File.directory? hook
        next unless File.executable? hook
        @build_hooks << Heidi::Hook.new(self, hook)
      end
    end

    def name=(name)
      @name = name
      @git[:name] = name
    end

    def name
      @name ||= @git[:name]
    end

    def commit
      @git.commit[0..8]
    end

    def last_commit
      @git[:last_commit]
    end
    def record_last_commit
      @git[:last_commit] = self.commit
    end

    def latest_build
      @git[:latest_build]
    end
    def record_latest_build
      @git[:latest_build] = self.commit
    end

    def integrate
      Heidi::Integrator.integrate(self)
    end
  end
end
