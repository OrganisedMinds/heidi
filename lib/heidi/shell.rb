require 'heidi'
require 'simple_shell'

class Heidi
  module Shell
    def shell
      @shell ||= SimpleShell.new
    end

    def check_heidi_root()
      if !File.exists?("./projects")  && File.directory?("./projects")
        $stderr.puts "You're not inside Heidi"
        exit 1
      end
    end

    def noisy
      @noisy=true
    end

    def silent
      @noisy=false
    end

    def shout(msg)
      @noisy ||= false
      return if @noisy == false
      puts msg
    end

    def new_heidi_root(name)
      shout "creating #{name}/"
      shout "creating #{name}/projects"
      shell.mkdir %W(-p #{name}/projects)
      shell.mkdir %W(-p #{name}/bin)
      shout "creating #{name}/Gemfile"
      File.open("#{name}/Gemfile", File::CREAT|File::WRONLY) do |f|
        f.puts 'source "http://rubygems.org"'
        f.puts 'gem "heidi"'
      end

      shout "\nIf you like you can run: bundle install --binstubs"
      shout "this will tie heidi and heidi_web to this location"
      shout "\nFor even more tying down, run: bundle install --deployment"
      shout "after running bundle install --binstubs"
    end

    def new_project(name, repo)
      if File.exists? "projects/#{name}"
        $stderr.puts "projects/#{name} is in the way. Please remove it"
        exit 1
      end

      # create a logs dir
      shout "creating projects/#{name}"
      shout "creating projects/#{name}/logs"
      shell.mkdir %W(-p projects/#{name}/logs)

      %w(build tests failure success before).each do |hook|
        shout "creating projects/#{name}/hooks/#{hook}"
        shell.mkdir %W(-p projects/#{name}/hooks/#{hook})
      end

      # make a clone
      shell.in("projects/#{name}") do |sh|
        shout "filling #{name} cache"

        shout "git clone #{repo}"
        sh.git %W(clone #{repo} cached)

        sh.in("cached") do |cached|
          shout "setting the name of the project to: #{name}"
          cached.git %W(config heidi.name #{name})
        end
      end

      shout "Creating default test hook: projects/#{name}/hooks/tests/01_rspec"
      File.open("projects/#{name}/hooks/tests/01_rspec", File::CREAT|File::WRONLY) do |f|
        f.puts %q(#!/bin/sh

# edit this file to your needs
bundle exec rake spec
)
      end
      shell.chmod %W(+x projects/#{name}/hooks/tests/01_rspec)
      shout "\n"
      shout "Now edit or add some hooks and run: heidi integrate #{name}"

    end

    def remove_project(name)
      # remove build and cache dir, expose logs directly
      shout "removing build dir"
      shell.rm %W(-r projects/#{name}/build)
      shout "removing cache (preserving project config)"
      shell.cp %W(-pr projects/#{name}/cached/.git/config projects/#{name})
      shell.rm %W(-r projects/#{name}/cached)
      shout "exposing builds"
      shell.mv %W(projects/#{name}/logs/* projects/#{name}/)
      shell.rm %W(-r projects/#{name}/logs)
    end

    def integrate(name)
      heidi = Heidi.new
      heidi.projects.each do |project|
        next if !name.nil? && project.name != name

        project.fetch
        msg = project.integrate(!name.nil?)
        unless msg.nil? || msg == true
          $stderr.puts "#{project.name}: #{msg}"
        end
      end
    end

  end
end