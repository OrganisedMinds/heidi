#!/usr/bin/env ruby

require './lib/heidi'

heidi = Heidi.new
heidi.projects.each do |project|
  project.integrate
end
