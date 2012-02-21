require 'simple_shell'
require 'time'

class Heidi
  # An integration is called a build.
  # The collections of builds is the log of the project.
  # A single build lives in $project/
  # A build is tied to a commit
  #
  class Build
    FAILURE = "FAILURE"
    SUCCESS = "SUCCESS"

    attr_reader :project, :commit, :root, :log_root, :build_root, :shell,
      :hooks, :logs

    def initialize(project, commit=project.commit)
      @project = project
      @commit  = commit

      @root       = File.join(project.root, "logs", commit)
      @log_root   = File.join(@root, "logs")
      @build_root = File.join(@root, "build")

      if !File.exists? @root
        SimpleShell.new(project.root).mkdir %W(-p #{@root})
      end
      @shell = SimpleShell.new(@root)

      @shell.mkdir %W(-p #{@log_root}) unless File.exists?(@log_root)
      @logs = Logs.new(@log_root)

      @i_locked_build = false
    end

    def author
      project.author(@commit)
    end

    def date
      project.date(@commit)
    end

    def time
      Time.parse(date)
    end

    def load_hooks
      log :info, "Loading hooks"
      @hooks  = {
        :before  => [],
        :build   => [],
        :tests   => [],
        :success => [],
        :failure => [],
      }

      @hooks.keys.each do |key|
        log :debug, "Loading #{key} hooks"

        Dir[File.join(project.root, "hooks", key.to_s, "*")].sort.each do |hook|
          next if File.directory? hook
          next unless File.executable? hook

          log :debug, "Loaded hook: #{hook}"

          @hooks[key] << Heidi::Hook.new(self, hook)
        end
      end

      log :info, "Hooks loaded"
    end

    def clean
      1.downto(0) do |i|
        if File.exists? "#{@log_root}.#{i}"
          if i - 1 < 0
            shell.mv %W(#{@log_root}.#{i} #{@log_root}.#{i+1})
          else
            shell.rm %W(-rf #{@log_root}.#{i})
          end
        end
      end

      if File.exists? "#{@log_root}"
        shell.mv %W(#{@log_root} #{@log_root}.0)
      end

      %w(build/ SUCCESS FAILURE).each do |inode|
        shell.rm("-r", "-f", inode) if File.exists? File.join(@root, inode)
      end

      # re-instate the logs
      @shell.mkdir %W(-p #{@log_root})
    end

    def log(type, msg, raw=false)
      name = case type
      when :error
        "heidi.errors"
      else
        "heidi.#{type}"
      end

      logs[name].send(raw == false ? :write : :raw, msg)
    end

    def lock_file
      File.join(@root, ".lock")
    end

    def lock(&block)
      log(:info, "Locking build")
      File.open(lock_file, File::CREAT|File::TRUNC|File::WRONLY) do |f|
        @i_locked_build = true
        f.puts Time.now.ctime
      end


      if block_given?
        yield
        unlock
      end
    end

    def unlock
      return unless locked?
      log(:info, "Unlocking build")
      File.unlink lock_file
      @i_locked_build = false
    end

    def locked?
      File.exists? lock_file
    end

    def locked_build?
      @i_locked_build == true ? true : false
    end

    def record(what)
      flags = File::CREAT|File::TRUNC|File::WRONLY
      file = nil
      case what
      when :failure
        project.build_status = Heidi::FAILED
        file = File.open(File.join(@root, FAILURE), flags)
      when :success
        project.build_status = Heidi::PASSED
        project.record_latest_build
        file = File.open(File.join(@root, SUCCESS), flags)
      end

      unless file.nil?
        file.puts Time.now.ctime
        file.close
      end
    end

    def failed?
      File.exists?(File.join(@root, FAILURE))
    end

    def success?
      File.exists?(File.join(@root, SUCCESS))
    end

    def status
      self.failed? ?
        Heidi::FAILED :
        self.success? ?
          Heidi::PASSED :
          Heidi::DNF
    end

    # file handle to tar ball
    def tar_ball
      ball = File.join(@root, "#{commit}.tar.bz2")

      return nil if !File.exists?(ball)
      return File.open(ball, File::RDONLY)
    end

    class Logs
      def initialize(log_root)
        @log_root = log_root
        @logs = []

        FileUtils.mkdir_p log_root if !File.directory?(log_root)

        Dir[File.join(@log_root, "*")].each do |file|
          @logs << Log.new(file)
        end
      end

      def [](key)
        log = @logs.select { |log| log.file_name == "#{key}" }.first
        if log.nil?
          @logs << ( log = Log.new( File.join(@log_root, "#{key}") ) )
        end

        return log
      end

      def each(&block)
        heidi = @logs.select { |l| l.file_name =~ /heidi/ }
        (heidi + (@logs - heidi)).each(&block)
      end

      class Log
        attr_reader :file_name, :contents
        def initialize(file)
          @file      = file
          @file_name = File.basename(file)
          @contents  = File.read(file) rescue ""
        end

        def write(msg,fmt=true)
          File.open(@file, File::CREAT|File::APPEND|File::WRONLY) do |f|
            if fmt == true
              f.puts "%s\t%s" % [ Time.now.strftime("%c"), msg ]
            else
              f.puts msg
            end
          end

          read
        end

        def read
          @contents = File.read(@file)
        rescue
          @contents = ""
        end

        def raw(msg)
          write(msg, false)
        end
      end
    end

  end
end
