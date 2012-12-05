require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra/content_for'
require 'sinatra/flash'
require './database'

set :environment, :production
set :logging, true
enable :sessions

get '/' do
  with_plain_layout :index
end

get '/issued-books' do
  @reservations = Reservation.all({:state => :issued})
  with_base_layout :issued_books
end

get '/books/:isbn' do
  content_type :json
  load_book
  not_found and return if @book.nil?
  @reservation = Reservation.last(:book => @book)
  load_messages
  without_layout :book_info
end

get '/user/new' do
  with_base_layout :new_user
end

get '/barcode/:employee_id/create' do
  Process.detach(barcode_job)
  redirect '/barcode/success'
end

get '/barcode/success' do
  with_base_layout :barcode_success
end

post '/user/create' do
  user = User.create(params[:user])
  if user.errors.empty?
    flash[:success] = "Successfully created user !!!"
  else
    flash[:error] = user.errors.full_messages.join(", ")
  end
  redirect '/user/new'
end


get '/donate' do
  with_plain_layout :donate
end

get '/users/:employee_id/reserve/:isbn' do
  load_user_and_book
  load_messages
  not_found and return if @user.nil? || @book.nil?
  criteria = {:user => @user, :book => @book, :state => :issued}
  @reservation = get_reservation criteria
  @reservation.save
  send("send_#{@reservation.state}_msg")
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

def barcode_job
  fork do
    load_user
    exec "sh ./create_barcode.sh #{params[:employee_id]}"
    email = Email.new(@user, nil)
    email.send_barcode_image
  end
end

def send_issued_msg
  email = Email.new(@user, @book)
  email.send_issued_msg
end

def send_returned_msg
  email = Email.new(@user, @book)
  email.send_returned_msg
end

def load_user_and_book
  load_user
  load_book
end

def load_user
  @user = User.first(:employee_id => params[:employee_id])
end

def load_book
  @book = Book.first(:isbn => params[:isbn]) || Book.create_from_openlibrary(params[:isbn])
end

def load_messages
  @messages = YAML::load(File.read(File.expand_path('config/en.yml','.')))
end

def get_reservation criteria
  reservation = Reservation.first(criteria)
  reservation.forward! unless reservation.nil?
  reservation ||= Reservation.create(criteria)
  return reservation
end
