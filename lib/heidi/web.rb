require 'sinatra/base'
require 'heidi'
require 'heidi/shell'
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
      @crumbs = []
    }

    dir = File.dirname(File.expand_path(__FILE__))

    set :sessions, true

    set :views,  "#{dir}/web/views"
    set :public_folder, "#{dir}/web/assets"
    set :root, dir

    get '/' do
      @crumbs = [ { 'home' => ''} ]
      erb(:home, { :locals => { :projects => @heidi.projects }})
    end

    get '/projects/' do
      @crumbs = [ { 'home' => '/'}, { 'new project' => '' } ]
      erb(:new_project)
    end

    post '/projects/' do
      basename = params[:name].downcase.gsub(/\W/,'_')

      Thread.new(basename) do |name|
        worker = Class.new
        worker.extend(Heidi::Shell)
        worker.silent

        worker.new_project(name, params[:origin], params[:branch])
      end

      sleep 1

      redirect "/projects/#{basename}", 302
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

    get '/projects/:name/commit/:commit' do
      project = @heidi[params[:name]]
      if project.nil?
        return "no project by that name: #{params[:name]}"
      end

      commit = params[:commit]

      erb(:commit, { :locals => {
        :commit  => commit,
        :project => project,
        :stat    => project.stat(commit),
        :diff    => project.diff(commit),
      }})
    end

    get '/projects/:name/configure' do
      project = @heidi[params[:name]]
      if project.nil?
        return "no project by that name: #{params[:name]}"
      end

      erb(:config, { :locals => { :project => project } } )
    end

    post '/projects/:project_name' do
      # update project
      project = @heidi[params[:project_name]]
      if project.nil?
        return "no project by that name: #{params[:project_name]}"
      end

      project.name = params[:name]
      project.branch = params[:branch]


      redirect "/projects/#{project.basename}", 302
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      def ansi_color_codes(string)
        return "" if string.nil?

        string.gsub(/\e\[0?m/, '</span>').
          gsub /\e\[[^m]+m/ do |codes|
            colors = codes.gsub(/[\e\[m]+/, '')
            classes = colors.split(";").collect { |c| "color#{c}" }
            "<span class=\"#{classes.join(" ")}\">"
          end
      end

      def breadcrumbs
        ""
      end

      def status2alert(status)
        case status
        when "passed"
          "alert-success"
        when "failed"
          "alert-error"
        else
          ""
        end
      end

      def status2label(status)
        case status
        when "passed"
          "label-success"
        when "failed"
          "label-important"
        else
          "label-info"
        end
      end


    end
  end
end
