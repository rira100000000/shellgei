require 'minitest/autorun'
require 'active_support'
require 'active_support/testing/time_helpers'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/date/calculations'

module TestHelpers
  def create_patron(name = '山田太郎')
    Patron.new(name)
  end

  def create_book(isbn = '978-1234', title = '吾輩は猫である', author = '夏目漱石')
    Book.new(isbn, title, author)
  end

  def create_library
    Library.new
  end

  def create_loan_repository
    LoanRepository.new
  end
end

class Minitest::Test
  include ActiveSupport::Testing::TimeHelpers
  include TestHelpers
end
