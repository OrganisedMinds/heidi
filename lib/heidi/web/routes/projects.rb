module Routes
  module Projects
    get '/projects' do
      output = ""
      $heidi.projects.each do |project|
        output += "<a href='/projects/#{project.name}'>#{project.name}</a><br />"
      end

      output
    end

    get '/projects/:name' do
      project = $heidi[params[:name]]
      if project.nil?
        return "no project by that name: #{params[:name]}"
      end

      output = ""
    end

    get '/projects/:name/build/:id' do
      project = $heidi[params[:name]]
      if project.nil?
        return "no project by that name: #{params[:name]}"
      end

      # load build of project
    end

    put '/projects/:name/build' do
      project = $heidi[params[:name]]
      if project.nil?
        return "no project by that name: #{params[:name]}"
      end

      project.integrate
    end
  end
end
