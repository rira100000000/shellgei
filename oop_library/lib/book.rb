require 'securerandom'

class Book
  attr_reader :id, :isbn, :title, :author

  def initialize(isbn, title, author)
    @id = SecureRandom.uuid
    @isbn = isbn
    @title = title
    @author = author
  end
end
