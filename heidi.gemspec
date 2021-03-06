# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "heidi"
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hartog C. de Mik"]
  s.date = "2012-02-15"
  s.description = "CI-Joe alike CI system called Heidi."
  s.email = "hartog@organisedminds.com"
  s.executables = ["heidi", "heidi_web"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/heidi",
    "bin/heidi_web",
    "heidi.gemspec",
    "lib/heidi.rb",
    "lib/heidi/build.rb",
    "lib/heidi/builder.rb",
    "lib/heidi/git.rb",
    "lib/heidi/hook.rb",
    "lib/heidi/integrator.rb",
    "lib/heidi/project.rb",
    "lib/heidi/tester.rb",
    "lib/heidi/web.rb",
    "lib/heidi/web/public/css/screen.css",
    "lib/heidi/web/public/images/HeidiBlue-480.png",
    "lib/heidi/web/public/images/HeidiBlue.gif",
    "lib/heidi/web/public/images/OrganisedMinds.png",
    "lib/heidi/web/public/images/heidi.jpeg",
    "lib/heidi/web/views/build.erb",
    "lib/heidi/web/views/commit.erb",
    "lib/heidi/web/views/config.erb",
    "lib/heidi/web/views/home.erb",
    "lib/heidi/web/views/layout.erb",
    "lib/heidi/web/views/project.erb",
    "spec/heidi/build_spec.rb",
    "spec/heidi/builder_spec.rb",
    "spec/heidi/git_spec.rb",
    "spec/heidi/hook_spec.rb",
    "spec/heidi/integrator_spec.rb",
    "spec/heidi/project_spec.rb",
    "spec/heidi/tester_spec.rb",
    "spec/heidi/web_spec.rb",
    "spec/heidi_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/coffeeaddict/heid"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "A naive CI system"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thin>, [">= 0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0"])
      s.add_runtime_dependency(%q<simple_shell>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<thin>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<simple_shell>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<thin>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<simple_shell>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

