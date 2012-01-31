require 'fileutils'
require './lib/simple_shell'
require 'strscan'

class Git
  VERBOSE=true

  # meh - should use a gem for this, but im lacking interwebs...

  def initialize(path=Dir.pwd, verbose=VERBOSE)
    @path = path
    Dir.chdir(@path)
    @shell = SimpleShell.new
  end

  # get the latest commit hash
  def commit
    @shell.system("git", "log", "-n", "1", "--pretty=%H").out 
  end
  alias_method :HEAD, :commit
  alias_method :head, :commit

  def branch
    res = @shell.system("git", "branch", "--no-color")
    active = res.out.scan(/\* \w+/).first
    active.scan(/\w+$/).first
  end

  def branches
    res = @shell.system("git", "branch", "--no-color")
    res.out.split("\n").collect{ |b| b.gsub(/^[\s*]+/, '') }
  end

  def switch(name)
    @shell.system("git", "checkout", name)
  end

  def pull(where="origin", what=nil)
    command = [ "git", "pull", where ]
    command << what if !what.nil?

    @shell.system(*command)
  end

  def push(where="origin", what=nil)
    command = [ "git", "push", where ]
    if !what.nil?
      if what == "--tags"
        command.insert(2, what)
      else
        command << what
      end
    end

    @shell.system(*command)
  end

  def tags
    res = @shell.system("git", "tag")
    res.out.split("\n")
  end
    
  def tag(name, message)
    command = [ "git", "tag", "-a", "-m", message, name ]
    if tags.include?(name)
      command.insert(4, "-f")
    end
    @shell.system(*command)
  end

  def []=(key, value)
    @shell.system("git", "config", key, value)
  end

  def [](key)
    @shell.system("git", "config", key).out
  end
end
