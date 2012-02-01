module Routes
  module Projects
    get '/projects' do
      # load all projects
    end

    get '/projects/:name' do
      # load specific project
      "no project by that name: #{params[:name]}"
    end

    get '/projects/:name/build/:id' do
      # load build of project
    end

    put '/projects/:name/build' do
      # request integration
    end

    post '/projects' do
      # create a new project
    end
  end
end
