require 'fileutils'
require 'heidi/project'

class Heidi
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
