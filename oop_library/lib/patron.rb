require 'securerandom'

class Patron
  def initialize(name)
    @id = SecureRandom.uuid
    @name = name
  end
end
