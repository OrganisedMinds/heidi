require 'heidi/build'
require 'heidi/builder'
require 'heidi/tester'

class Heidi
  class Integrator
    attr_reader :build, :project

    def initialize(project)
      @project = project
      @build   = Heidi::Build.new(project)
      @failed  = false
    end

    def failure
      @failed = true
    end

    def integrate
      build.lock
      build.load_hooks
      build.clean

      return failure if !run_hooks(:before)

      builder = Heidi::Builder.new(build)
      tester = Heidi::Tester.new(build)

      return failure if !builder.build!
      return failure if !tester.test!
      return failure if !run_hooks(:after)

      # record the new succesful
      build.record

      # create a tarball
      build.create_tar_ball

      return true

    rescue Exception => e
      $stderr.puts e.message
      $stderr.puts e.backtrace.join("\n")

      return $!

    ensure
      run_hooks(:failed) if @failed == true

      # always unlock the build root, no matter what
      build.unlock

      return @failed == true ? false : true

    end

    def run_hooks(where)
      return true if build.hooks[where].nil? || build.hooks[where].empty?

      hooks_failed = false
      build.hooks[where].each do |hook|
        res = hook.perform(build.build_root)

        if res.S?.to_i != 0
          build.log :error, "--- #{where} hook: #{hook.name} failed ---"
          build.log :error, res.err

          hooks_failed = true
          break

        else
          build.log :info, res.out
        end
      end

      return hooks_failed == true ? false : true
    end

  end
end
