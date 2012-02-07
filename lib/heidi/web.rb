require 'sinatra/base'
require 'heidi'
require 'simple_shell'

class Heidi
  class Web < Sinatra::Base

    def self.start(host="0.0.0.0", port="4567", project_path=Dir.pwd)
      @project_path = project_path
      Heidi::Web.run! :host => host, :port => port
    end

    def self.project_path
      @project_path
    end

    before {
      @heidi = Heidi.new(self.class.project_path)
    }

    dir = File.dirname(File.expand_path(__FILE__))

    set :sessions, true

    set :views,  "#{dir}/web/views"
    set :public_folder, "#{dir}/web/public"
    set :root, dir

    get '/' do
      redirect '/projects/', 302
    end

    get '/projects/' do
      erb(:home, { :locals => { :projects => @heidi.projects }})
    end

    get '/projects/:name' do
      project = @heidi[params[:name]]
      if project.nil?
        return "no project by that name: #{params[:name]}"
      end

      erb(:project, { :locals => { :project => project }})
    end

    get '/projects/:name/build/:commit' do
      project = @heidi[params[:name]]
      if project.nil?
        return "no project by that name: #{params[:name]}"
      end

      # load build of project
      build = Heidi::Build.new(project, params[:commit])
      erb(:build, { :locals => { :build => build, :project => project }})
    end

    get '/projects/:name/build/:commit/tar_ball' do
      project = @heidi[params[:name]]
      if project.nil?
        return "no project by that name: #{params[:name]}"
      end

      # load build of project
      build = Heidi::Build.new(project, params[:commit])

      ball = build.tar_ball
      if ball.nil?
        return "no tar ball here..."
      end

      content_type 'application/x-tar'
      headers "Content-type" => "application/x-tar",
        "Content-disposition" => "attachment; filename=#{build.commit}.tar.bz2"

      stream do |out|
        while true
          begin
            out << ball.sysread(1024)
          rescue EOFError
            break
          end
        end
      end

    end

    put '/projects/:name/build' do
      project = $heidi[params[:name]]
      if project.nil?
        return "no project by that name: #{params[:name]}"
      end

      project.integrate
    end


    helpers do
      def ansi_color_codes(string)
        string.gsub("\e[0m", '</span>').
          gsub(/\e\[(\d+)m/, "<span class=\"color\\1\">")
      end
    end
  end
end
