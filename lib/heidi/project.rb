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

      return @builds
    end

    def name=(name)
      @name = name
      @git["name"] = name
    end

    def name
      @name ||= @git[:name]
    end

    def basename
      File.basename(@root)
    end

    def commit
      @git.commit[0..8]
    end

    def author(commit=self.commit)
      @git.log(1, "%cN <%cE>", commit)
    end

    def date(commit=self.commit)
      @git.log(1, "%ci", commit)
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
      @git["build.status"]
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
      return true if !forced && self.current_build == self.commit
      return "locked" if locked?

      status = "unknown"

      self.lock do
        record_current_build
        res = Heidi::Integrator.new(self).integrate
        if res == true
          status = nil
        elsif res.is_a? String
          status = res
        else
          status = "failed"
        end
      end

      return status
    end

    def fetch
      if integration_branch && @git.branch != integration_branch
        if @git.branches.include? integration_branch
          @git.switch(integration_branch)
          @git.merge "origin/#{integration_branch}"

        else
          @git.checkout(integration_branch, "origin/#{integration_branch}")

        end
      end

      @git.pull

      # when the head has changed, update some stuff
      if last_commit != self.commit
        record_last_commit
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

    def log
      log = @git.graph(120)

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
