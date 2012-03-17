require 'sinatra'
require 'sinatra/content_for'
require 'sequel'
require 'yaml'

DB = Sequel.connect('sqlite://db/ol.db')
set :views, Proc.new { File.join(root, "views") }

get "/" do
	with_base_layout :index
end

get "/help" do
	with_base_layout :help
end

# show the reserve.erb; scan the isbn, reserve the book against a name.
get "/reserve" do
	erb :reserve
end

# calls the list.erb; lists down who has what and option to renew and return
get "/list" do
	erb :list
end

# backend ajax handler which returns the book info, reservation info., etc
post "/backend" do

end

def with_base_layout template, options={}
	@menu_items = YAML::load(File.read(File.expand_path('config/menu.yml','.')))
	erb template, options.merge(:layout => :'common/base_layout')
end