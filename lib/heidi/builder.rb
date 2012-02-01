require 'simple_git'
require 'simple_shell'
require 'time'

class Heidi
  class Builder
    attr_reader :build_root, :shell

    def initialize(project)
      @project    = project
      @build_root = File.join(project.root, "build")
      @log_root   = File.join(project.root, "logs", project.commit)
      @shell      = SimpleShell.new
    end

    def build
      if @project.last_commit == @project.latest_build && @project.latest_build != ""
        return "last seen commit is the latest build"
      end

      setup_logging

      if (msg = self.setup_build_dir) != nil
        log(:error, msg)
        return msg
      end

      if @project.build_hooks.any?
         build_failed = false
         @project.build_hooks.each do |hook|
           next if build_failed == true

           res = hook.perform(self.build_root)
           if res.S?.to_i != 0
             build_log("Build failed:")
             build_log(res.err)
             build_failed = true
           else
             build_log(res.out)
           end
         end

         if build_failed == true
           return "Build failed, revert to build.log for details"
         end
      end

      return nil
    end

    def setup_logging
      @shell.do "mkdir", "-p", @log_root
    end

    def setup_build_dir
      if File.exists? build_root
        if File.exists? lock_file
          return "build root is locked"
        end

        @shell.do "rm", "-r", build_root
      end

      clone = nil
      Dir.chdir @project.root do
        clone = @shell.do "git", "clone", @project.cached_root, "build"
      end

      if !File.exists? build_root
        return "git clone failed: #{clone.err}"
      end

      @git = Git.new(build_root)
      res = @git.switch("develop")
      if res.S?.to_i != 0
        return "switching to develop failed: #{res.err}"
      end

      lock_build_root

      return nil
    end

    def lock_file
      File.join(build_root, ".lock")
    end

    def lock_build_root
      File.open(lock_file, File::CREAT|File::TRUNC|File::WRONLY) do |f|
        f.puts Time.now.strftime "%c"
      end
    end

    def unlock_build_root
      File.unlink lock_file
    end

    def log(type, msg)
      name = case type
      when :error
        "heidi.errors"
      else
        "heidi.#{type}"
      end

      File.open(File.join(@log_root, name), File::CREAT|File::WRONLY|File::APPEND) do |f|
        f.puts "%s\t%s" % [ Time.now.strftime("%c"), msg ]
      end
    end

    def build_log(string)
      File.open(File.join(@log_root, "build.log"), File::CREAT|File::WRONLY|File::APPEND) do |f|
        f.puts string
      end
    end
  end
end
