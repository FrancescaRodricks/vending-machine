module SetupProducts
  class SetupProductsError < StandardError; end
  attr_accessor :products

  # total no of products that can be added to the vending machine
  TOTAL_PRODUCTS_COUNTS = 100

  def default_products
    @products ||= []
    Product::DEFAULT_PRODUCTS.each do |prod|
      add_product(
        name: prod[:name],
        price: prod[:price]
      )
    end
  end

  def add_product(name:, price:)
    # TODO - if its a product refill, check Product::DEFAULT_PRODUCT_QUANTITY -
    # available and only add diff amount if less than Product::DEFAULT_PRODUCT_QUANTITY
    # This method checks if products size is <= Product::DEFAULT_PRODUCT_QUANTITY before adding a product
    # raises error if vending machine is full of products
    if @products.size < Product::DEFAULT_PRODUCT_QUANTITY
      instance_variable_set("@#{name}", Array.new(
        Product::DEFAULT_PRODUCT_QUANTITY,
        Product.new(name: "#{name}", price: price)
      ))
      @products.push instance_variable_get("@#{name}")
      self.class.__send__(:attr_accessor, "#{name}")
    else
      raise SetupProductsError.new('Vending Machine cannot accomodate more items')
    end
  end

  def remove_product(name:)
    # remove an item from the products if name matches
    @products.each_with_index do |prod_category, index|
      @current_index = index
      @found_item = prod_category.detect { |item| item.name == name }
      break if @found_item
    end
    @products[@current_index].shift if @found_item
  end
end