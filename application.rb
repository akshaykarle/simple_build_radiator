require 'sinatra'
require 'ci_status'
require 'yaml'
require 'sass'

get '/' do
  return halt 422 unless urls
  @projects = []
  urls.each do |url_hash|
    c = CiStatus::CruiseControl.new(url_hash['url'])
    @projects += c.projects
  end
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

def urls
  @urls ||= YAML::load(File.read('config/app_config.yml'))
end