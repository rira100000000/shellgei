require 'minitest/autorun'
require_relative './test_helper'
require_relative '../lib/loan_searcher'
require_relative '../lib/loan'
require_relative '../lib/book'
require_relative '../lib/patron'

class LoanSearcherTest < Minitest::Test
  def test_record_は貸出記録を作成して返す
    loan_searcher = create_loan_searcher
    patron = create_patron
    book = create_book

    loan = loan_searcher.record(patron, book)

    assert_instance_of Loan, loan
    assert_equal patron, loan.patron
    assert_equal book, loan.book
  end

  def test_active_loans_は貸出中の記録のみ返す
    loan_searcher = create_loan_searcher
    patron1 = create_patron('山田太郎')
    patron2 = create_patron('鈴木花子')
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-5678', 'こころ', '夏目漱石')
    book3 = create_book('978-9012', '坊っちゃん', '夏目漱石')

    loan1 = loan_searcher.record(patron1, book1)
    loan2 = loan_searcher.record(patron1, book2)
    loan3 = loan_searcher.record(patron2, book3)

    loan2.give_back

    active = loan_searcher.active_loans

    assert_equal 2, active.size
    assert_includes active, loan1
    assert_includes active, loan3
    refute_includes active, loan2
  end

  def test_loans_by_patron_は特定利用者の全記録を返す
    loan_searcher = create_loan_searcher
    patron1 = create_patron('山田太郎')
    patron2 = create_patron('鈴木花子')
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-5678', 'こころ', '夏目漱石')
    book3 = create_book('978-9012', '坊っちゃん', '夏目漱石')

    loan1 = loan_searcher.record(patron1, book1)
    loan2 = loan_searcher.record(patron1, book2)
    loan3 = loan_searcher.record(patron2, book3)

    loan1.give_back  # loan1 を返却

    loans = loan_searcher.loans_by_patron(patron1)

    assert_equal 2, loans.size
    assert_includes loans, loan1  # 返却済みも含む
    assert_includes loans, loan2
    refute_includes loans, loan3
  end

  def test_active_loans_by_patron_は特定利用者の貸出中記録のみ返す
    loan_searcher = create_loan_searcher
    patron1 = create_patron('山田太郎')
    patron2 = create_patron('鈴木花子')
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-5678', 'こころ', '夏目漱石')
    book3 = create_book('978-9012', '坊っちゃん', '夏目漱石')

    loan1 = loan_searcher.record(patron1, book1)
    loan2 = loan_searcher.record(patron1, book2)
    loan3 = loan_searcher.record(patron2, book3)

    loan1.give_back  # loan1 を返却

    active = loan_searcher.active_loans_by_patron(patron1)

    assert_equal 1, active.size
    assert_includes active, loan2
    refute_includes active, loan1  # 返却済みは含まない
    refute_includes active, loan3
  end

  def test_find_loan_by_book_は貸出中の本の記録を返す
    loan_searcher = create_loan_searcher
    patron = create_patron
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-5678', 'こころ', '夏目漱石')

    loan1 = loan_searcher.record(patron, book1)
    loan2 = loan_searcher.record(patron, book2)

    found = loan_searcher.find_loan_by_book(book1)

    assert_equal loan1, found
  end

  def test_find_loan_by_book_は返却済みの本はnilを返す
    loan_searcher = create_loan_searcher
    patron = create_patron
    book = create_book

    loan = loan_searcher.record(patron, book)
    loan.give_back

    found = loan_searcher.find_loan_by_book(book)

    assert_nil found
  end

  def test_find_loan_by_book_は貸出されてない本はnilを返す
    loan_searcher = create_loan_searcher
    book = create_book

    found = loan_searcher.find_loan_by_book(book)

    assert_nil found
  end

  def test_overdue_loans_は延滞中の記録のみ返す
    loan_searcher = create_loan_searcher
    patron1 = create_patron('山田太郎')
    patron2 = create_patron('鈴木花子')
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-5678', 'こころ', '夏目漱石')
    book3 = create_book('978-9012', '坊っちゃん', '夏目漱石')

    loan1 = loan_searcher.record(patron1, book1)
    loan2 = loan_searcher.record(patron1, book2)
    loan3 = loan_searcher.record(patron2, book3)

    travel 20.days do
      loan1.give_back  # loan1 だけ返却

      overdue = loan_searcher.overdue_loans

      assert_equal 2, overdue.size
      assert_includes overdue, loan2
      assert_includes overdue, loan3
      refute_includes overdue, loan1  # 返却済みは延滞じゃない
    end
  end

  def test_overdue_loans_は期限内の記録は含まない
    loan_searcher = create_loan_searcher
    patron = create_patron
    book = create_book

    loan = loan_searcher.record(patron, book)

    travel 3.days do
      overdue = loan_searcher.overdue_loans

      assert_empty overdue
    end
  end

  # 以下ヘルパーメソッド
  private

  def create_patron(name = '山田太郎')
    Patron.new(name)
  end

  def create_book(isbn = '978-1234', title = '吾輩は猫である', author = '夏目漱石')
    Book.new(isbn, title, author)
  end

  def create_loan_searcher
    LoanSearcher.new
  end
end
