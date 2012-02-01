require 'fileutils'
require 'simple_shell'
require 'strscan'

class Heidi

  # A very simple interface to git base on SimpleShell, no library ties and no
  # fancy stuff
  #
  class Git
    VERBOSE=false

    def initialize(path=Dir.pwd, verbose=VERBOSE)
      @path = path
      SimpleShell.noisy = verbose
      @shell = SimpleShell.new(@path)
    end

    # get the latest commit hash
    def commit
      res = @shell.git "log", "-n", "1", "--pretty=%H"
      res.out
    end
    alias_method :HEAD, :commit
    alias_method :head, :commit

    # find the current branch (the one with the *)
    def branch
      res = @shell.git "branch", "--no-color"
      active = res.out.scan(/\* \w+/).first
      active.scan(/\w+$/).first
    end

    # git branch
    def branches
      res = @shell.git "branch", "--no-color"
      res.out.split("\n").collect{ |b| b.gsub(/^[\s*]+/, '') }
    end

    # git checkout $name
    def switch(name)
      return nil unless branches.include?(name)
      @shell.git "checkout", name
    end

    # git checkout -b $name [$base]
    def checkout(name, base=nil)
      command = [ "git", "checkout", "-b", name ]
      command << base unless base.nil?
      @shell.system(*command)
    end

    # git merge $base
    def merge(base)
      @shell.git %W(merge #{base})
    end

    # git fetch $where='origin'
    def fetch(where="origin")
      @shell.git %W(fetch #{where})
    end

    # git pull $where='origin' [$what]
    def pull(where="origin", what=nil)
      command = [ "git", "pull", where ]
      command << what if !what.nil?

      @shell.system(*command)
    end

    # git push $where [$what]
    #
    #   $what may be '--tags'
    #
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

    # git tags
    def tags
      res = @shell.system("git", "tag")
      res.out.split("\n")
    end

    # git tag -a -m $message $name
    def tag(name, message)
      command = [ "git", "tag", "-a", "-m", message, name ]
      if tags.include?(name)
        command.insert(4, "-f")
      end
      @shell.system(*command)
    end

    # git config $key $value
    def []=(key, value)
      @shell.system("git", "config", "heidi.#{key}", value)
    end

    # git config $key
    def [](key)
      @shell.system("git", "config", "heidi.#{key}").out
    end
  end
end
