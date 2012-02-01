require './lib/heidi/web/routes/projects'
require './lib/heidi/web/routes/home'

class Heidi
  module Web
    module Routes
      def self.included(base)
        base.extend Routes::Home
        base.extend Routes::Projects
      end
    end
  end
end
