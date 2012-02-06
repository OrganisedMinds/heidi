require 'heidi/git'
require 'heidi/integrator'
require 'heidi/hook'
require 'time'

class Heidi
  class Project
    attr_reader :root, :cached_root, :lock_file, :builds

    def initialize(root)
      @root        = root
      @lock_file   = File.join(root, ".lock")
      @cached_root = File.join(root, "cached")
      @git         = Heidi::Git.new(@cached_root)
      load_builds
    end

    def load_builds
      @builds = []
      Dir[File.join(root, "logs", "*")].each do |build|
        next unless File.directory? build
        @builds << Heidi::Build.new(self, File.basename(build))
      end
    end

    def name=(name)
      @name = name
      @git["name"] = name
    end

    def name
      @name ||= @git[:name]
    end

    def commit
      @git.commit[0..8]
    end

    def last_commit
      @git["commit"]
    end
    def record_last_commit
      @git["commit"] = self.commit
    end

    def latest_build
      @git["build.latest"]
    end
    def record_latest_build
      @git["build.latest"] = self.commit
    end

    def build_status
      @git["build.status"]
    end
    def build_status=(status)
      @git["build.status"] = status
    end

    def integration_branch
      name = @git["build.branch"]
      name == "" ? nil : name
    end

    def integrate
      return "locked" if locked?

      status = ""
      self.lock do
        res = Heidi::Integrator.new(self).integrate
        status = res != true ? "failed" : "passed"
      end

      return status
    end

    def fetch
      if integration_branch && git.branch != integration_branch
        if @git.branches.include? integration_branch
          @git.switch(integration_branch)
          @git.merge "origin/#{integration_branch}"

        else
          @git.checkout(integration_branch, "origin/#{integration_branch}")

        end
      end

      @git.pull

      record_last_commit
    end

    def lock(&block)
      File.open(lock_file, File::TRUNC|File::CREAT|File::WRONLY) do |f|
        f.puts Time.now.strftime("%c")
      end

      if block_given?
        yield
        self.unlock
      end
    end

    def unlock
      File.unlink lock_file
    end

    def locked?
      File.exists? lock_file
    end

  end
end
