require 'rubygems'
require 'sinatra'
require 'sinatra/content_for'
require 'yaml'
require './database'

set :environment, :production
set :logging, true

get '/' do
	with_plain_layout :index
end

get '/books/:isbn' do
  content_type :json
  book = Book.first(:isbn => params[:isbn])
  not_found and return if book.nil?
  book.to_json
end

get '/users/:employee_id' do
  content_type :json
  user = User.first(:employee_id => params[:employee_id]);
  not_found and return if user.nil?
  user.to_json
end

def with_base_layout template, options={}
	@menu_items = YAML::load(File.read(File.expand_path('config/menu.yml','.')))
	erb template, options.merge(:layout => :'layout/base')
end

def with_plain_layout template, options={}
  erb template, options.merge(:layout => :'layout/plain')
end