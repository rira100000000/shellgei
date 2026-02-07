require_relative './loan'

class LoanRepository
  def initialize
    @loans = []
  end

  def record(patron, book)
    loan = Loan.new(patron, book)
    @loans << loan

    loan
  end

  def active_loans
    @loans.reject(&:give_backed?)
  end

  def loans_by_patron(patron)
    @loans.filter { it.patron == patron }
  end

  def active_loans_by_patron(patron)
    active_loans.filter { it.patron == patron }
  end

  def find_loan_by_book(book)
    active_loans.find { it.book == book }
  end

  def overdue_loans
    @loans.filter(&:overdue?)
  end

  def loaned_books_by_isbn(isbn)
    active_loans.filter { it.book.isbn == isbn }.map(&:book)
  end
end
