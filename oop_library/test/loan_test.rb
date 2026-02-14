require 'minitest/autorun'
require 'date'
require_relative './test_helper'

class LoanTest < Minitest::Test
  def setup
    @patron = Patron.new('さだのら')
    @book = Book.new('978-4-10-100101-0', '吾輩は猫である', '夏目漱石')
  end

  def test_期限内の場合はoverdueがfalseを返す
    loan = Loan.new(@patron, @book)

    travel 3.days do
      refute loan.overdue?
    end
  end

  def test_期限を過ぎている場合はoverdueがtrueを返す
    loan = Loan.new(@patron, @book)

    travel 20.days do
      assert loan.overdue?
    end
  end

  def test_本が返却済みなら期限を過ぎていてもoverdueはfalseを返す
    loan = Loan.new(@patron, @book)

    travel 20.days do
      assert loan.overdue?

      loan.give_back
      refute loan.overdue?
    end
  end

  def test_返却前はgive_backedがfalseを返す
    loan = Loan.new(@patron, @book)

    refute loan.give_backed?
  end

  def test_返却後はgive_backedがtrueを返す
    loan = Loan.new(@patron, @book)

    loan.give_back
    assert loan.give_backed?
  end
end
