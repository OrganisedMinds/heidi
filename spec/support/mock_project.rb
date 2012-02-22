require 'simple_shell'
require 'tmpdir'

module MockProject
  def fake_me_a_heidi
    this_repo = Dir.pwd rescue ENV['PWD']

    # create a heidi dir with the bare minimum
    @fake = Dir.mktmpdir(nil, '/tmp')

    shell = SimpleShell.new(@fake)
    shell.mkdir "-p", "projects/heidi_test"
    shell.in "projects/heidi_test" do |sh|
      sh.git %W(clone #{this_repo} cached)
      sh.mkdir "logs"
      %w(build tests failure success before).each do |hook|
        sh.mkdir %W(-p hooks/#{hook})
      end
    end

    spec = File.join(@fake, "projects/heidi_test/hooks/tests", "01_rspec")
    File.open(spec, File::CREAT|File::WRONLY) do |f|
      f.puts %Q(#!/bin/sh

touch #{@fake}/#{File.basename(@fake)})
    end

    shell.chmod %W(+x #{spec})

    @heidi = Heidi.new(@fake)
  rescue Exception => ex
    $stderr.puts "Faking heidi failed... #{ex.message}"
    $stderr.puts ex.backtrace.join("\n")
  end
end

RWorld(MockProject)
