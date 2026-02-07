class Library
  def initialize
    @books = []
  end

  def add_book(book)
    @books << book
  end

  def find_book_by_id(id)
    @books.find { it.id == id }
  end

  def find_books_by_isbn(isbn)
    @books.filter { it.isbn == isbn }
  end
end
