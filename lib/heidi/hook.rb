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

      env = {
        'HEIDI_LOG_DIR'   => build.log_root,
        'HEIDI_BUILD_DIR' => where,
        'RUBYOPT'         => nil,
        'BUNDLE_BIN_PATH' => nil,
        'BUNDLE_GEMFILE'  => nil,
      }

      shell = SimpleShell.new(where, env)
      res = shell.do @script
      return res
    end

    def name
      File.basename(@script)
    end
  end
end
