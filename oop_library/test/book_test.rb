require 'minitest/autorun'
require_relative '../lib/book'

class BookTest < Minitest::Test
  def test_同一タイトルの書籍は異なるインスタンスとみなす
    book1 = Book.new('978-4-10-100101-0', '吾輩は猫である', '夏目漱石')
    book2 = Book.new('978-4-10-100101-0', '吾輩は猫である', '夏目漱石')

    refute_equal book1.id, book2.id
  end
end
