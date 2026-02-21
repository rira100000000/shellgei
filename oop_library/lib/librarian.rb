require_relative './library'

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
    if active_loans.size >= Library::MAX_LOANS_PER_PATRON
      return Result.new(value: nil, error_message: "#{Library::MAX_LOANS_PER_PATRON}冊までしか借りれないのよ！まじで！")
    end

    # 貸す
    @loan_repository.record(patron, loanable_book)

    Result.new(value: loanable_book, error_message: nil)
  end

  def check_in(book)
    # 返却記録を取ってくる
    loan = @loan_repository.find_loan_by_book(book)
    if loan.nil?
      return Result.new(value: nil, error_message: "#{book.title}に貸出記録がありませぬ！")
    end
    # 本を返したという記録を残す
    loan.give_back
    Result.new(value: loan, error_message: nil)
  end

  def overdue_patrons
    loans = @loan_repository.overdue_loans
    loans.each_with_object(Hash.new { |h, k| h[k] = [] }) do |loan, result|
      # 誰が何の本を借りたか詰め込む
      result[loan.patron.name] << loan.book.title
    end
  end
end
