require 'date'

class Loan
  PERIOD_OF_LOAN = 14

  def initialize(patron, book)
    @patron = patron
    @book = book
    @loan_on = Date.today
    @due_date = @loan_on + PERIOD_OF_LOAN
    @give_backed_on = nil
  end

  def give_back
    @give_backed_on = Date.today
  end

  def give_backed?
    !@give_backed_on.nil?
  end

  def overdue?
    !give_backed? && @due_date <= Date.today
  end
end
