require 'heidi/git'
require 'heidi/integrator'
require 'heidi/hook'
require 'time'

class Heidi
  class Project
    attr_reader :root, :cached_root, :lock_file

    def initialize(root)
      @root        = root
      @lock_file   = File.join(root, ".lock")
      @cached_root = File.join(root, "cached")
      @git         = Heidi::Git.new(@cached_root)
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

    def build_status
      @git[:build_status]
    end
    def build_status=(status)
      @git[:build_status] = status
    end

    def integration_branch
      name = @git[:integration_branch]
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
