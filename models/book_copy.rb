class BookCopy
  include DataMapper::Resource

  property :id, Serial, :required => true
  belongs_to :book, :required => true
  property :state, String, :index => true
end