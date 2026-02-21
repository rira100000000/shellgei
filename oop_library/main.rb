require_relative './lib/book'
require_relative './lib/library'
require_relative './lib/loan'
require_relative './lib/loan_repository'
require_relative './lib/librarian'
require_relative './lib/patron'
library = Library.new
loan_repository = LoanRepository.new
librarian = Librarian.new(loan_repository, library)

book1 = Book.new('978-1234', '吾輩は猫である', '夏目漱石')
book2 = Book.new('978-5678', 'こころ', '夏目漱石')
book3 = Book.new('978-9012', '坊っちゃん', '夏目漱石')
book4 = Book.new('978-3456', '走れメロス', '太宰治')
book5 = Book.new('978-1234', '吾輩は猫である', '夏目漱石')

patron1 = Patron.new('rira1000000')
patron2 = Patron.new('sadanora')
patron3 = Patron.new('hori')

library.add_book(book1)
library.add_book(book2)
library.add_book(book3)
library.add_book(book4)
library.add_book(book5)

binding.irb
