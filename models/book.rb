class Book
  include DataMapper::Resource

  property :id, Serial, :required => true
  property :isbn, String, :index => true, :required => true, :length => 255
  property :title, String, :required => true, :length => 255
  property :author, String, :required => true, :length => 255
  property :photo_remote_url, String, :length => 255
  has n, :book_copies
  has n, :reservation

  def self.create_from_openlibrary(isbn)
    details = ::Openlibrary::Data.find_by_isbn(isbn)
    return unless details
    params = {}.tap do |p|
      p[:isbn]   = details.identifiers["isbn_13"][0]
      p[:title]  = details.title
      p[:author] = details.authors.map{|a| a["name"]}.join(", ") if details.authors
      p[:photo_remote_url] = details.cover["medium"] if details.cover
      p[:book_copies] = [BookCopy.new]
    end
    Book.create! params
  end
end
