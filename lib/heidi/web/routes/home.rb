class Heidi; module Web; module Routes

  module Home
    get '/' do
      '<h1>Welcome to Heidi!</h1>Psst. Want to see my <a href="/projects">projects</a>?'
    end
  end

end; end; end