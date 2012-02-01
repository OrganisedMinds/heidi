require 'heidi/web/routes/projects'
require 'heidi/web/routes/home'

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
