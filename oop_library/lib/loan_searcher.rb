require_relative './loan'

class LoanSearcher
  def initialize
    @loans = []
  end

  def create_loan(patron, book)
    @loans << Loan.new(patron, book)
  end

  def checked_out_loans
    @loans.reject(&:give_backed?)
  end

  def loans_by_patron(patron)
    @loans.filter { it.patron == patron }
  end

  def checked_out_loans_by_patron(patron)
    checked_out_loans.filter { it.patron == patron }
  end

  def checked_out_loans_by_book(book)
    checked_out_loans.filter { it.book == book }
  end

  def overdue_loans
    @loans.filter(&:overdue?)
  end
end
