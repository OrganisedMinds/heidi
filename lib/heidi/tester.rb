class Heidi
  class Tester
    attr_reader :build, :project, :message

    def initialize(build)
      @build    = build
      @project  = build.project
      @message  = ""
    end

    def test!
      build.log(:info, "Starting tests")

      tests_failed = false

      if build.hooks[:tests].empty?
        build.log(:error, "There are no test hooks")
        @message = "There are no test hooks"
        return false
      end

      build.hooks[:tests].each do |hook|
        log(">> #{hook.name}:")
        res = hook.perform(build.build_root)

        if res.S?.to_i != 0
          log "--- #{hook.name}: failed ---"
          log(hook.message)

          @message = "tests failed"
          tests_failed = true
          break

        else
          log(res.out) unless res.out.empty?
        end
        log("\n\n")
      end

      return tests_failed ? false : true
    end

    def log(string)
      build.logs["test.log"].raw(string)
    end


  end
end
