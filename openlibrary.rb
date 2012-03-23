require 'rubygems'
require 'sinatra'
require 'sinatra/content_for'
require 'yaml'
require './database'

set :environment, :production
set :logging, true

get '/' do
	with_base_layout :index
end

get '/help' do
	with_base_layout :help
end

get '/books/:isbn' do
  content_type :json
  book = Book.first(:isbn => params[:isbn])
  not_found and return if book.nil?
  book.to_json
end

def with_base_layout template, options={}
	@menu_items = YAML::load(File.read(File.expand_path('config/menu.yml','.')))
	erb template, options.merge(:layout => :'common/base_layout')
end