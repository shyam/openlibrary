class Book
  include DataMapper::Resource

  property :id, Serial
  property :isbn, String, :index => true
  property :title, String
  property :author, String
  property :photo_remote_url, String
end