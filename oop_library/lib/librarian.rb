require_relative './lib/library'

class Librarian
  Result = Data.define(:value, :error_message) do
    def success? = error_message.nil?
    def failure? = !error_message.nil?
  end

  def initialize(loan_repository, library)
    @loan_repository = loan_repository
    @library = library
  end

  def check_out(patron, isbn)
    # isbn を受け取って管理している本を取得する
    books = @library.find_books_by_isbn(isbn)
    if books.empty?
      return Result.new(value: nil, error_message: "当館では#{isbn}の書籍は取扱しておりませぬ！！")
    end

    loaned_books = @loan_repository.loaned_books_by_isbn(isbn)
    # books - 貸し出せない本たち = 貸し出せる本たち
    loanable_book = (books - loaned_books).first
    if loanable_book.nil?
      return Result.new(value: nil, error_message: "在庫ないよ！")
    end

    active_loans = @loan_repository.active_loans_by_patron(patron)
    if active_loans.size > Library::MAX_LOANS_PER_PATRON
      return Result.new(value: nil, error_message: "#{Library::MAX_LOANS_PER_PATRON}までしか借りれないのよ！まじで！")
    end

    # 貸す
    @loan_repository.record(patron, loanable_book)

    Result.new(value: loanable_book, error_message: nil)
  end
end
