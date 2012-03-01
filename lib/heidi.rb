require 'fileutils'
require 'simple_shell'

require 'heidi/project'

class Heidi
  PASSED = "passed"
  FAILED = "failed"
  DNF     = "DNF"

  attr_reader :projects

  def initialize(root=Dir.pwd)
    @root = root
    @projects = []
    Dir[File.join(root,"projects", "*")].each do |project|
      next unless File.directory?(project)

      @projects << Heidi::Project.new(project)
    end
  end

  def [](name)
    name = "#{name}"
    @projects.select do |project|
      project.name == name || File.basename(project.root) == name
    end.first
  end
end
