class Product
  attr_accessor :name, :quantity, :price

  DEFAULT_PRODUCT_QUANTITY = 10

  DEFAULT_PRODUCTS = [
    { name: 'coke', price: 2 },
    { name: 'water', price: 1 },
    { name: 'energy_drink', price: 0.5 }
  ].freeze

  def initialize(name:, price:)
    @name = name
    @price = price
  end
end
