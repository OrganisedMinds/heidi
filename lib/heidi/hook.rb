require 'simple_shell'

class Heidi
  class Hook
    attr_reader :build
    def initialize(build, script)
      @build  = build
      @script = script
    end

    def perform(where=build.build_root)
      # before / failure hooks might like this
      if !File.exists?(where)
        where = build.root
      end

      start = Time.now
      env = {
        'HEIDI_DIR'          => build.project.root,
        'HEIDI_LOG_DIR'      => build.log_root,
        'HEIDI_BUILD_DIR'    => where,
        'HEIDI_BUILD_COMMIT' => build.commit,
        'HEIDI_BRANCH'       => build.project.branch

        'RUBYOPT'         => nil,
        'BUNDLE_BIN_PATH' => nil,
        'BUNDLE_GEMFILE'  => nil,
        'GEM_HOME'        => nil,
        'GEM_PATH'        => nil,
      }

      shell = SimpleShell.new(where, env)
      @res = shell.do @script

      return @res
    end

    def message
      @res.err.empty? ?
        @res.out.empty? ?
          "No error message given" :
          @res.out :
      @res.err
    end

    def output
      @res.out.empty? ?
        @res.err.empty? ?
          "No output" :
          @res.err :
      @res.out
    end

    def failed?
      @res.S?.to_i != 0
    rescue
      false
    end

    def name
      File.join(File.basename(File.dirname(@script)), File.basename(@script))
    end
  end
end
