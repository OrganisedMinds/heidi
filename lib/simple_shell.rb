require 'open3'

class SimpleShell
  attr_reader :commands
  def initialize
    @commands = []
  end

  def in(dir, &block)
    before = @commands.clone

    Dir.chdir(dir) do
      yield self
    end

    return @commands - before
  end

  def do(*args) 
    command = Command.new(*args)
    @commands << command

    return command
  end  
  alias_method :system, :do

  def S?
    @commands.last.S?
  end

  class Command
    attr_reader :out, :err, :S
 
    def initialize(*args)
      @out = ""
      @err = ""
      @S   = -1

      execute(*args)
    end 

    def execute(command, *args)
      Open3.popen3(command, *args) do |stdin, stdout, stderr, thread|
        @out = stdout.read.chomp
        @err = stderr.read.chomp
        @S   = thread.value rescue 0
      end
    end

    def S?  # cheap copy of $?
      @S
    end

    def to_s
      @out
    end
  end
end
