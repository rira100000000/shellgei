require 'securerandom'

class Book
  def initialize(isbn, title, author)
    @id = SecureRandom.uuid
    @isbn = isbn
    @title = title
    @author = author
  end
end
