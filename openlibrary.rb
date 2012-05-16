require 'rubygems'
require 'sinatra'
require 'sinatra/content_for'
require 'yaml'
require 'json'
require './database'

set :environment, :production
set :logging, true

get '/' do
	with_plain_layout :index
end

get '/books/:isbn' do
  content_type :json
  @book = Book.first(:isbn => params[:isbn])
  not_found and return if @book.nil?
  @reservation = Reservation.last(:book => @book)
  load_messages
  without_layout :book_info
end

get '/donate' do
  with_plain_layout :donate
end

get '/users/:employee_id/reserve/:isbn' do
  @book = Book.first(:isbn => params[:isbn])
  @user = User.first(:employee_id => params[:employee_id])
  not_found and return if @user.nil? || @book.nil?
  criteria = {:user => @user, :book => @book, :state => :issued}
  @reservation = get_reservation criteria
  @reservation.save
  load_messages
  without_layout :reservation
end

def with_base_layout template, options={}
	@menu_items = YAML::load(File.read(File.expand_path('config/menu.yml','.')))
	erb template, options.merge(:layout => :'layout/base')
end

def with_plain_layout template, options={}
  erb template, options.merge(:layout => :'layout/plain')
end

def without_layout template
  erb template
end

private

def load_messages
  @messages = YAML::load(File.read(File.expand_path('config/en.yml','.')))
end

def get_reservation criteria
  reservation = Reservation.first(criteria)
  reservation.forward! unless reservation.nil?
  reservation ||= Reservation.create(criteria)
  return reservation
end