# test/librarian_test.rb
require 'minitest/autorun'
require_relative './test_helper'

class LibrarianTest < Minitest::Test
  def test_check_out_は本を貸し出せる
    library = create_library
    loan_repository = create_loan_repository
    librarian = Librarian.new(loan_repository, library)
    patron = create_patron
    book = create_book('978-1234', '吾輩は猫である', '夏目漱石')

    library.add_book(book)

    result = librarian.check_out(patron, '978-1234')

    assert result.success?
    assert_instance_of Book, result.value
    assert_equal book, result.value
  end

  def test_check_out_は取扱のないISBNの場合エラーを返す
    library = create_library
    loan_repository = create_loan_repository
    librarian = Librarian.new(loan_repository, library)
    patron = create_patron

    result = librarian.check_out(patron, '978-9999')

    assert result.failure?
    assert_equal '当館では978-9999の書籍は取扱しておりませぬ！！', result.error_message
  end

  def test_check_out_は在庫がない場合エラーを返す
    library = create_library
    loan_repository = create_loan_repository
    librarian = Librarian.new(loan_repository, library)
    patron1 = create_patron('山田太郎')
    patron2 = create_patron('鈴木花子')
    book = create_book('978-1234', '吾輩は猫である', '夏目漱石')

    library.add_book(book)
    librarian.check_out(patron1, '978-1234')

    result = librarian.check_out(patron2, '978-1234')

    assert result.failure?
    assert_equal '在庫ないよ！', result.error_message
  end

  def test_check_out_は貸出上限に達している場合エラーを返す
  library = create_library
  loan_repository = create_loan_repository
  librarian = Librarian.new(loan_repository, library)
  patron = create_patron
  book1 = create_book('978-1111', '本1', '著者1')
  book2 = create_book('978-2222', '本2', '著者2')
  book3 = create_book('978-3333', '本3', '著者3')
  book4 = create_book('978-4444', '本4', '著者4')
  book5 = create_book('978-5555', '本5', '著者5')
  book6 = create_book('978-6666', '本6', '著者6')

  library.add_book(book1)
  library.add_book(book2)
  library.add_book(book3)
  library.add_book(book4)
  library.add_book(book5)
  library.add_book(book6)

  # 5冊借りる
  librarian.check_out(patron, '978-1111')
  librarian.check_out(patron, '978-2222')
  librarian.check_out(patron, '978-3333')
  librarian.check_out(patron, '978-4444')
  librarian.check_out(patron, '978-5555')

  # 6冊目を借りようとする
  result = librarian.check_out(patron, '978-6666')

  assert result.failure?
  assert_equal '5冊までしか借りれないのよ！まじで！', result.error_message
end

  def test_check_out_は返却後なら再び借りられる
    library = create_library
    loan_repository = create_loan_repository
    librarian = Librarian.new(loan_repository, library)
    patron = create_patron
    book1 = create_book('978-1111', '本1', '著者1')
    book2 = create_book('978-2222', '本2', '著者2')
    book3 = create_book('978-3333', '本3', '著者3')
    book4 = create_book('978-4444', '本4', '著者4')
    book5 = create_book('978-5555', '本5', '著者5')
    book6 = create_book('978-6666', '本6', '著者6')

    library.add_book(book1)
    library.add_book(book2)
    library.add_book(book3)
    library.add_book(book4)
    library.add_book(book5)
    library.add_book(book6)

    # 5冊借りる
    result1 = librarian.check_out(patron, '978-1111')
    librarian.check_out(patron, '978-2222')
    librarian.check_out(patron, '978-3333')
    librarian.check_out(patron, '978-4444')
    librarian.check_out(patron, '978-5555')

    # 1冊返却
    loan = loan_repository.find_loan_by_book(result1.value)
    loan.give_back

    # 6冊目を借りられる
    result = librarian.check_out(patron, '978-6666')

    assert result.success?
  end
end
