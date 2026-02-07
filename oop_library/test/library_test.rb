require 'minitest/autorun'
require_relative '../lib/library'
require_relative '../lib/book'

class LibraryTest < Minitest::Test
  def test_add_book_で本を追加できる
    library = create_library
    book = create_book

    library.add_book(book)

    assert_equal 1, library.books.size
    assert_includes library.books, book
  end

  def test_add_book_で複数の本を追加できる
    library = create_library
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-5678', 'こころ', '夏目漱石')
    book3 = create_book('978-9012', '坊っちゃん', '夏目漱石')

    library.add_book(book1)
    library.add_book(book2)
    library.add_book(book3)

    assert_equal 3, library.books.size
  end

  def test_find_book_by_id_でIDから本を検索できる
    library = create_library
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-5678', 'こころ', '夏目漱石')

    library.add_book(book1)
    library.add_book(book2)

    found = library.find_book_by_id(book1.id)

    assert_equal book1, found
  end

  def test_find_book_by_id_は存在しないIDの場合nilを返す
    library = create_library
    book = create_book

    library.add_book(book)

    found = library.find_book_by_id('non-existent-id')

    assert_nil found
  end

  def test_find_book_by_id_は空の図書館ではnilを返す
    library = create_library

    found = library.find_book_by_id('any-id')

    assert_nil found
  end

  def test_find_books_by_isbn_で同じISBNの本を全て取得できる
    library = create_library
    book1 = create_book('978-1234', '吾輩は猫である', '夏目漱石')
    book2 = create_book('978-1234', '吾輩は猫である', '夏目漱石')  # 同じISBN
    book3 = create_book('978-5678', 'こころ', '夏目漱石')

    library.add_book(book1)
    library.add_book(book2)
    library.add_book(book3)

    found = library.find_books_by_isbn('978-1234')

    assert_equal 2, found.size
    assert_includes found, book1
    assert_includes found, book2
    refute_includes found, book3
  end

  def test_find_books_by_isbn_は存在しないISBNの場合空配列を返す
    library = create_library
    book = create_book('978-1234', '吾輩は猫である', '夏目漱石')

    library.add_book(book)

    found = library.find_books_by_isbn('978-0000')

    assert_empty found
  end

  def test_find_books_by_isbn_は空の図書館では空配列を返す
    library = create_library

    found = library.find_books_by_isbn('978-1234')

    assert_empty found
  end
end
