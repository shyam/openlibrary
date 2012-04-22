class Book
  include DataMapper::Resource

  property :id, Serial, :required => true
  property :isbn, String, :index => true, :required => true, :length => 255
  property :title, String, :required => true, :length => 255
  property :author, String, :required => true, :length => 255
  property :photo_remote_url, String, :length => 255
  has n, :book_copies
  has n, :reservation
end