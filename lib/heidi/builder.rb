require 'simple_shell'
require 'time'

class Heidi
  class Builder
    attr_reader :build, :project

    def initialize(build)
      @build   = build
      @project = build.project
    end

    def build!
      return self.setup_build_dir
    end

    def setup_build_dir
      if build.locked? and !build.locked_build?
        build.log(:error, "The build was locked externaly")
        return false
      end

      if File.exists? build.build_root
        build.log(:info, "Removing previous build")
        build.shell.do "rm", "-r", build.build_root
      end

      build.log(:info, "Creating new clone")
      clone = build.shell.git %W(clone #{@project.cached_root} #{File.basename(build.build_root)})

      if !File.exists?(build.build_root) || clone.S?.to_i != 0
        build.log :error, "git clone failed: #{clone.err}"
        return false
      end

      if project.branch
        @git = Heidi::Git.new(build.build_root)

        branch = project.branch
        build.log(:info, "Switching to integration branch: #{branch}")
        res = @git.switch(branch)
        if res.nil?
          build.log(:info, "Creating integration branch from origin/#{branch}")
          @git.checkout(branch, "origin/#{branch}")
        end

        res = @git.switch(branch)
        if res.S?.to_i != 0
          build.log(:error, "switching to '#{branch}' failed: #{res.err}")
          return false
        end

      else
        build.log(:info, "Using master as the integration branch")

      end

      build.lock

      return true
    end

    def create_tar_ball
      shell = SimpleShell.new(build.root)
      shell.mv %W(build #{build.commit})
      tar = shell.tar %W(--exclude .git -cjf #{build.commit}.tar.bz2 #{build.commit})
      if tar.S?.to_i == 0
        shell.rm %W(-rf #{build.commit}/)
      else
        build.log(:error, "Creating tar-ball failed: #{tar.err}")
      end
    end

    def log(string)
      build.logs["builder.log"].raw(string)
    end

  end
end
