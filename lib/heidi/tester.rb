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

      if build.hooks[:tests].empty?
        build.log(:error, "There are no test hooks")
        @message = "There are no test hooks"
        return false
      end

      return true
    end

  end
end
