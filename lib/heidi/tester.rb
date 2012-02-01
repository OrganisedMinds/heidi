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
        res = hook.perform(build.build_root)

        if res.S?.to_i != 0
          log "--- test #{hook.name} failed ---"
          log res.err

          @message = "tests failed"
          tests_failed = true
          break

        else
          log res.out
        end
      end

      return tests_failed ? false : true
    end

    def log(string)
      File.open(
        File.join(build.root, "test.log"),
        File::CREAT|File::WRONLY|File::APPEND
      ) do |f|
        f.puts string
      end
    end


  end
end
