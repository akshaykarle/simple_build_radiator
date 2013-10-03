require 'sinatra'
require 'ci_status'
require 'yaml'
require 'sass'

get '/' do
  return halt 422 unless ci_servers
  projects = []
  ci_servers.each do |ci_server|
    cc = CiStatus::CruiseControl.new(ci_server['url'], ci_server['username'], ci_server['password'])
    projects += cc.projects
  end
  @failure_projects, @success_projects = projects.partition { |project| project.failure? }
  erb 'projects.html'.to_sym
end

get '/projects.css' do
  scss 'projects.css'.to_sym
end

error Errno::ENOENT do
  "Please create a config/app_config.yml file"
end

error Psych::SyntaxError do
  'Could not parse the supplied yaml file'
end

def ci_servers
  @ci_servers ||= YAML::load(File.read('config/app_config.yml'))
end