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

      # have a builder build the build dir
      builder = Heidi::Builder.new(build)
      return failure if !builder.build!
      return failure if !run_hooks(:build)

      # have a tester test the build
      tester = Heidi::Tester.new(self)
      return failure if !tester.test!

      # and run the success hooks
      return failure if !run_hooks(:success)

      # create a tarball
      builder.create_tar_ball

      return success

    rescue Exception => e
      build.log(:error, e.message)
      build.log(:error, e.backtrace.join("\n"))

      return e.message

    ensure
      run_hooks(:failure) if @failed == true

      run_hooks(:after)

      # always unlock the build root, no matter what
      build.unlock

    end

    def run_hooks(where)
      build.load_hooks if build.hooks.nil? || build.hooks.empty?

      return true if @hooks_ran.include?(where)
      return true if build.hooks[where].nil? || build.hooks[where].empty?

      hooks_failed = false
      build.hooks[where].each do |hook|
        start = Time.now
        build.log :info, "Running #{hook.name} :"

        hook.perform

        if hook.failed?
          build.log :info, "\tfailed. See heidi.error"
          build.log :error, "--- #{hook.name}: failed ---"
          build.log :error, hook.message, true

          hooks_failed = true
          break

        else
          build.log :info, "#{hook.output.lines.collect { |l| "\t#{l}" }.join("")}", true
        end

        build.log(:info, ("Took %.2fs" % (Time.now-start)))
      end

      @hooks_ran << where

      return hooks_failed == true ? false : true
    end

  end
end
