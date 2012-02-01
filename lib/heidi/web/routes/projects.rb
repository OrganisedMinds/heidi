class Heidi; module Web; module Routes

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

      output = "<h1>#{project.name}</h1>"
      output += "Build status: #{project.build_status}"
      output += "<br /><br /><h2>Build history</h2>"
      project.builds.each do |build|
        output += %Q{<a href="/projects/#{project.name}/build/#{build.commit}">#{build.commit}</a> - #{build.status}<br />}
      end

      output
    end

    get '/projects/:name/build/:commit' do
      project = $heidi[params[:name]]
      if project.nil?
        return "no project by that name: #{params[:name]}"
      end

      # load build of project
      build = Heidi::Build.new(project, params[:commit])
      output = "<h1>#{project.name}</h1>"
      output += "<h2>Build: #{build.commit} - #{build.status}<h2>"

      %w(heidi.info heidi.errors build.log test.log).each do |log_file|
        log = build.logs(log_file)
        if (!log.nil? and !log.empty?)
          output += "<h3>#{log_file}</h3>"
          output += "<pre>#{log}</pre>"
        end
      end

      output
    end

    put '/projects/:name/build' do
      project = $heidi[params[:name]]
      if project.nil?
        return "no project by that name: #{params[:name]}"
      end

      project.integrate
    end
  end

end; end; end
