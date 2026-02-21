require 'securerandom'

class Patron
  attr_reader :name

  def initialize(name)
    @id = SecureRandom.uuid
    @name = name
  end
end
