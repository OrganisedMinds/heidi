require 'simple_shell'

class Heidi
  class Hook
    def initialize(project, script)
      @project = project
      @script  = script
    end

    def perform(where)
      shell = SimpleShell.new(where)
      res = shell.do @script
      return res
    end

    def name
      File.basename(@script)
    end
  end
end
