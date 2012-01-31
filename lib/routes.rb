require './lib/routes/projects'
require './lib/routes/home'

module Routes
  def self.included(base)
    base.extend Routes::Home
    base.extend Routes::Projects
  end
end
