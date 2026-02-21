require 'minitest/autorun'
require_relative './test_helper'

class LoanRepositoryTest < Minitest::Test
  def test_record_は貸出記録を作成して返す
    loan_repository = create_loan_repository
    patron = create_patron
    book = create_book

    loan = loan_repository.record(patron, book)

    assert_instance_of Loan, loan
    assert_equal patron, loan.patron
    assert_equal book, loan.book
  end

  def test_active_loans_は貸出中の記録のみ返す
    loan_repository = create_loan_repository
    patron1 = create_patron('山田太郎')
    patron2 = create_patron('鈴木花子')
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-5678', 'こころ', '夏目漱石')
    book3 = create_book('978-9012', '坊っちゃん', '夏目漱石')

    loan1 = loan_repository.record(patron1, book1)
    loan2 = loan_repository.record(patron1, book2)
    loan3 = loan_repository.record(patron2, book3)

    loan2.give_back

    active = loan_repository.active_loans

    assert_equal 2, active.size
    assert_includes active, loan1
    assert_includes active, loan3
    refute_includes active, loan2
  end

  def test_loans_by_patron_は特定利用者の全記録を返す
    loan_repository = create_loan_repository
    patron1 = create_patron('山田太郎')
    patron2 = create_patron('鈴木花子')
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-5678', 'こころ', '夏目漱石')
    book3 = create_book('978-9012', '坊っちゃん', '夏目漱石')

    loan1 = loan_repository.record(patron1, book1)
    loan2 = loan_repository.record(patron1, book2)
    loan3 = loan_repository.record(patron2, book3)

    loan1.give_back  # loan1 を返却

    loans = loan_repository.loans_by_patron(patron1)

    assert_equal 2, loans.size
    assert_includes loans, loan1  # 返却済みも含む
    assert_includes loans, loan2
    refute_includes loans, loan3
  end

  def test_active_loans_by_patron_は特定利用者の貸出中記録のみ返す
    loan_repository = create_loan_repository
    patron1 = create_patron('山田太郎')
    patron2 = create_patron('鈴木花子')
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-5678', 'こころ', '夏目漱石')
    book3 = create_book('978-9012', '坊っちゃん', '夏目漱石')

    loan1 = loan_repository.record(patron1, book1)
    loan2 = loan_repository.record(patron1, book2)
    loan3 = loan_repository.record(patron2, book3)

    loan1.give_back  # loan1 を返却

    active = loan_repository.active_loans_by_patron(patron1)

    assert_equal 1, active.size
    assert_includes active, loan2
    refute_includes active, loan1  # 返却済みは含まない
    refute_includes active, loan3
  end

  def test_find_loan_by_book_は貸出中の本の記録を返す
    loan_repository = create_loan_repository
    patron = create_patron
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-5678', 'こころ', '夏目漱石')

    loan1 = loan_repository.record(patron, book1)
    loan2 = loan_repository.record(patron, book2)

    found = loan_repository.find_loan_by_book(book1)

    assert_equal loan1, found
  end

  def test_find_loan_by_book_は返却済みの本はnilを返す
    loan_repository = create_loan_repository
    patron = create_patron
    book = create_book

    loan = loan_repository.record(patron, book)
    loan.give_back

    found = loan_repository.find_loan_by_book(book)

    assert_nil found
  end

  def test_find_loan_by_book_は貸出されてない本はnilを返す
    loan_repository = create_loan_repository
    book = create_book

    found = loan_repository.find_loan_by_book(book)

    assert_nil found
  end

  def test_overdue_loans_は延滞中の記録のみ返す
    loan_repository = create_loan_repository
    patron1 = create_patron('山田太郎')
    patron2 = create_patron('鈴木花子')
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-5678', 'こころ', '夏目漱石')
    book3 = create_book('978-9012', '坊っちゃん', '夏目漱石')

    loan1 = loan_repository.record(patron1, book1)
    loan2 = loan_repository.record(patron1, book2)
    loan3 = loan_repository.record(patron2, book3)

    travel 20.days do
      loan1.give_back  # loan1 だけ返却

      overdue = loan_repository.overdue_loans

      assert_equal 2, overdue.size
      assert_includes overdue, loan2
      assert_includes overdue, loan3
      refute_includes overdue, loan1  # 返却済みは延滞じゃない
    end
  end

  def test_overdue_loans_は期限内の記録は含まない
    loan_repository = create_loan_repository
    patron = create_patron
    book = create_book

    loan = loan_repository.record(patron, book)

    travel 3.days do
      overdue = loan_repository.overdue_loans

      assert_empty overdue
    end
  end

  def test_loaned_books_by_isbn_は貸し出し中の本を返す
    loan_repository = create_loan_repository
    patron1 = create_patron('山田太郎')
    patron2 = create_patron('鈴木花子')
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-1234', '吾輩は猫である', '夏目漱石')  # 同じISBN
    book3 = create_book('978-5678', 'こころ', '夏目漱石')

    loan_repository.record(patron1, book1)
    loan_repository.record(patron2, book2)
    loan_repository.record(patron1, book3)

    loaned_books = loan_repository.loaned_books_by_isbn('978-1234')

    assert_equal 2, loaned_books.size
    assert_equal loaned_books, [book1, book2]
  end

  def test_loaned_books_by_isbn_は返却済みの本は含まない
    loan_repository = create_loan_repository
    patron = create_patron
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-1234', '吾輩は猫である', '夏目漱石')

    loan1 = loan_repository.record(patron, book1)
    loan2 = loan_repository.record(patron, book2)

    loan1.give_back  # book1 を返却

    loaned_books = loan_repository.loaned_books_by_isbn('978-1234')

    assert_equal 1, loaned_books.size
    assert_equal loaned_books, [book2]
  end

  def test_loaned_books_by_isbn_は該当なしの場合空配列を返す
    loan_repository = create_loan_repository

    loaned_books = loan_repository.loaned_books_by_isbn('978-1234')

    assert_empty loaned_books
  end
end
