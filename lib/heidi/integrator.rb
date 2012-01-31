require './lib/heidi/builder'
require './lib/heidi/tester'

class Heidi
  class Integrator
   def self.integrate(project)
      builder = Heidi::Builder.new(project)
      message = builder.build
      return message unless message.nil?

      message = Heidi::Tester.test(project, builder.build_root)
      return message unless message.nil?

      # create tar ball

      project.record_latest_build
    end
  end
end
