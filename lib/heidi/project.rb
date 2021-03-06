require 'heidi/git'
require 'heidi/integrator'
require 'heidi/hook'
require 'time'

class Heidi
  class Project
    attr_reader :root, :cached_root, :lock_file

    def initialize(root)
      @root        = root
      @lock_file   = File.join(root, ".lock")
      @cached_root = File.join(root, "cached")
      @git         = Heidi::Git.new(@cached_root)
    end

    def builds
      @builds || load_builds
    end

    def load_builds
      @builds = []
      Dir[File.join(root, "logs", "*")].each do |build|
        next unless File.directory? build
        @builds << Heidi::Build.new(self, File.basename(build))
      end

      def @builds.find(commit)
        return nil unless commit.is_a?(String)
        return nil unless commit.length >= 5

        self.select do |build|
          build.commit == commit || build.commit =~ Regexp.new("^#{commit}")
        end.first
      end

      return @builds.sort_by(&:time)
    end

    def name=(name)
      @git["name"] = name
    end

    def name
      name ||= @git[:name] || basename
      name = basename if name.empty?
      name
    end

    def basename
      File.basename(@root)
    end

    def commit
      @git.commit[0..7]
    end
    alias_method :HEAD, :commit

    def author(commit=self.commit)
      @git.log(1, "%cN <%cE>", commit)
    end

    def date(commit=self.commit)
      @git.log(1, "%ci", commit)
    end

    def message(commit=self.commit)
      @git.log(1, "%B", commit)
    end

    def last_commit
      @git["commit"]
    end
    def record_last_commit
      @git["commit"] = self.commit
    end

    def latest_build
      @git["build.latest"]
    end
    def record_latest_build
      @git["build.latest"] = self.commit
    end

    def current_build
      @git["build.current"]
    end
    def record_current_build
      @git["build.current"] = self.commit
    end

    def build_status
      @git["build.status"] || "unknown"
    end
    def build_status=(status)
      @git["build.status"] = status
    end

    def branch
      name = @git["build.branch"]
      name == "" ? nil : name
    end
    def branch=(name)
      name.gsub!("origin/", "")
      @git["build.branch"] = name
    end

    def integration_branches
      @git.remote_branches
    end

    def integrate(forced=false)
      must_build = !(self.current_build == self.commit)
      must_build = build_status != "passed"

      return true if !forced && !must_build
      return "locked" if locked?

      status = Heidi::DNF

      self.lock do
        record_current_build
        res = Heidi::Integrator.new(self).integrate
        if res == true
          status = nil
        elsif res.is_a? String
          status = res
        else
          status = Heidi::FAILED
        end
      end

      return status
    end

    def fetch
      return if locked?

      self.lock do
        if branch && @git.branch != branch
          if @git.branches.include? branch
            @git.switch(branch)
            @git.merge "origin/#{branch}"

          else
            @git.checkout(branch, "origin/#{branch}")

          end
        end

        @git.pull

        # when the head has changed, update some stuff
        if last_commit != self.commit
          record_last_commit
        end
      end
    end

    def lock(&block)
      File.open(lock_file, File::TRUNC|File::CREAT|File::WRONLY) do |f|
        f.puts Time.now.strftime("%c")
      end

      if block_given?
        yield
        self.unlock
      end
    end

    def log(length=60)
      log = @git.graph(length)

      lines = []
      log.out.lines.each do |line|
        commit  = nil
        message = nil
        graph   = nil

        if line =~ /\*/
          color_less = line.gsub(/\e\[[^m]*m?/, '')
          commit = color_less.scan(/^[^a-z0-9]+([a-z0-9]+)/).flatten.first
          (graph, message) = line.chomp.split(commit)
        else
          graph = line.chomp
        end

        lines << {
          :line    => line,
          :commit  => commit,
          :build   => builds.find(commit),
          :graph   => graph,
          :message => message,
        }
      end

      return lines
    end

    def stat(commit)
      @git.stat(commit)
    end

    def diff(commit)
      @git.diff(commit)
    end

    def unlock
      File.unlink lock_file
    end

    def locked?
      File.exists? lock_file
    end

  end
end
