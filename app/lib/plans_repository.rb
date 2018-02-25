class PlansRepository
  def all
    [
      Plan.new(id: 'a', price: '$15.99', description: 'abc abc abc abc abc abc abc abc abc abc abc abc abc abc abcabc abc abc abc abc abc abc abc abc abc abc abc abc abc abcabc abc abc abc abc abc abc abc abc abc abc abc abc abc abc'),
      Plan.new(id: 'b', price: '$15.99', description: 'abc abc abc abc abc abc abc abc abc abc abc abc abc abc abcabc abc abc abc abc abc abc abc abc abc abc abc abc abc abcabc abc abc abc abc abc abc abc abc abc abc abc abc abc abc'),
      Plan.new(id: 'c', price: '$15.99', description: 'abc abc abc abc abc abc abc abc abc abc abc abc abc abc abcabc abc abc abc abc abc abc abc abc abc abc abc abc abc abcabc abc abc abc abc abc abc abc abc abc abc abc abc abc abc'),
    ]
  end

  def find(id)
    all.find { |plan| plan.id == id }
  end

  class Plan
    attr_reader :id, :description, :price

    def initialize(id:, description:, price:)
      @id = id
      @description = description
      @price = price
    end
  end
end
