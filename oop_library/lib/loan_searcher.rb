require_relative './loan'

class LoanSearcher
  def initialize
    @loans = []
  end

  def create_loan(patron, book)
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
end
