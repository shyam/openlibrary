require 'rubygems'
require 'sinatra'
require 'sinatra/content_for'
require 'yaml'

set :views, Proc.new { File.join(root, "views") }

get "/" do
	with_base_layout :index
end

get "/help" do
	with_base_layout :help
end

def with_base_layout template, options={}
	@menu_items = YAML::load(File.read(File.expand_path('config/menu.yml','.')))
	erb template, options.merge(:layout => :'common/base_layout')
end
