require 'simple_shell'

class Heidi
  class Hook
    def initialize(project, script)
      @project = project
      @script  = script
    end

    def perform(where)
      shell = SimpleShell.new

      Dir.chdir where do
        res = shell.do script
      end

      return res
    end
  end
end
