require 'heidi/build'
require 'heidi/builder'
require 'heidi/tester'
require 'time'

class Heidi
  class Integrator
    attr_reader :build, :project

    def initialize(project)
      @project   = project
      @build     = Heidi::Build.new(project)
      @failed    = false
      @hooks_ran = []
    end

    def failure
      @failed = true
      run_hooks(:failure)
      build.log :info, ("Integration failed after: %.2fs" % (Time.now - @start))

      build.record(:failure)

      return false
    end

    def success
      # record the new succesful
      build.record(:success)
      build.log :info, ("Integration took: %.2fs" % (Time.now - @start))

      return true
    end

    def integrate
      build.load_hooks
      return "no test hooks!" if build.hooks[:tests].empty?

      build.lock
      @start = Time.now
      build.clean

      return failure if !run_hooks(:before)

      builder = Heidi::Builder.new(build)
      tester = Heidi::Tester.new(build)

      return failure if !builder.build!
      return failure if !tester.test!

      return failure if !run_hooks(:success)

      # create a tarball
      builder.create_tar_ball

      return success

    rescue Exception => e
      $stderr.puts e.message
      $stderr.puts e.backtrace.join("\n")

      return $!

    ensure
      run_hooks(:failed) if @failed == true

      # always unlock the build root, no matter what
      build.unlock

    end

    def run_hooks(where)
      return true if @hooks_ran.include?(where)
      return true if build.hooks[where].nil? || build.hooks[where].empty?

      hooks_failed = false
      build.hooks[where].each do |hook|
        res = hook.perform

        if res.S?.to_i != 0
          build.log :error, "--- #{where} hook: #{hook.name} failed ---"
          build.log :error, res.err

          hooks_failed = true
          break

        else
          build.log :info, res.out
        end
      end

      @hooks_ran << where

      return hooks_failed == true ? false : true
    end

  end
end
