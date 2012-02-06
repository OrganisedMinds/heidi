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
      return false if self.setup_build_dir != true

      if build.hooks[:build].any?
        build_failed = false
        build.hooks[:build].each do |hook|
          next if build_failed == true

          res = hook.perform(build.build_root)
          if res.S?.to_i != 0
            log("--- Build hook #{hook.name} failed ---")
            log(res.err.empty? ? "no error message given" : res.err)
            build_failed = true
            break

          else
            log(res.out) unless res.out.empty?
          end
        end

        if build_failed == true
          build.log :error, "Build failed, revert to build.log for details"
          return false
        end
      end

      return true
    end


    def setup_build_dir
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

      if project.integration_branch
        @git = Heidi::Git.new(build.build_root)

        branch = project.integration_branch
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


    def log(string)
      build.logs["builder.log"].raw(string)
    end

  end
end
