require 'simple_shell'
require 'time'

class Heidi
  # An integration is called a build.
  # The collections of builds is the log of the project.
  # A single build lives in $project/logs
  # A build is tied to a commit
  #
  class Build
    attr_reader :project, :commit, :root, :shell, :hooks

    def initialize(project, commit=project.commit)
      @project = project
      @commit  = commit
      @root    = File.join(project.root, "logs", commit)

      if !File.exists? @root
        SimpleShell.new(project.root).mkdir %W(-p #{@root})
      end

      @shell = SimpleShell.new(@root)
    end

    def load_hooks
      log :info, "Loading hooks"
      @hooks  = {
        :build  => [],
        :tests  => [],
        :before => [],
        :after  => [],
        :failed => [],
      }

      @hooks.keys.each do |key|
        log :debug, "Loading #{key} hooks"

        Dir[File.join(project.root, "hooks", key.to_s, "*")].each do |hook|
          next if File.directory? hook
          next unless File.executable? hook

          log :debug, "Loaded hook: #{hook}"

          @hooks[key] << Heidi::Hook.new(self.project, hook)
        end
      end

      log :info, "Hooks loaded"
    end

    def clean
      %w(heidi.info heidi.errors test.log builder.log build).each do |inode|
        shell.rm("-r", "-f", inode) if File.exists? File.join(@root, inode)
      end
    end

    def build_root
      File.join(@root, "build")
    end

    def log(type, msg)
      name = case type
      when :error
        "heidi.errors"
      else
        "heidi.#{type}"
      end

      File.open(
        File.join(@root, name),
        File::CREAT|File::WRONLY|File::APPEND
      ) do |f|
        f.puts "%s\t%s" % [ Time.now.strftime("%c"), msg ]
      end
    end

    def lock_file
      File.join(@root, ".lock")
    end

    def lock(&block)
      log(:info, "Locking build")
      File.open(lock_file, File::CREAT|File::TRUNC|File::WRONLY) do |f|
        f.puts Time.now.ctime
      end

      if block_given?
        yield
        unlock
      end
    end

    def unlock
      log(:info, "Unlocking build")
      File.unlink lock_file
    end

    def locked?
      File.exists? lock_file
    end

    def record(what)
      flags = File::CREAT|File::TRUNC|File::WRONLY
      file = nil
      case what
      when :failure
        project.build_status = "failed"
        file = File.open(File.join(@root, "FAILURE"), flags)
      when :success
        project.build_status = "passed"
        project.record_latest_build
        file = File.open(File.join(@root, "SUCCESS"), flags)
      end

      unless file.nil?
        file.puts Time.now.ctime
        file.close
      end
    end

    def failed?
      File.exists?(File.join(@root, "FAILURE"))
    end

    def success?
      File.exists?(File.join(@root, "SUCCESS"))
    end

    def status
      self.failed? ?
        "failed" :
        self.success? ?
          "passed" :
          "DNF"
    end

    def logs(what)
      File.read(File.join(@root, what))
    rescue
      ""
    end

    def create_tar_ball
      # TODO
    end
  end
end