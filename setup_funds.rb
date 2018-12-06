module SetupFunds
  class SetupFundsError < StandardError; end
  attr_accessor :funds

  DEFAULT_FUNDS_PER_DENOMINATION = 10

  def default_funds
    @funds ||= []
    Money::DENOMINATIONS.each do |denomination|
      add_funds(name: denomination[:name],  price: denomination[:price])
    end
  end

  def add_funds(name:, price:)
    # TODO - if its a fund refill, check money default qty -
    # available and only add diff amount if less than default quantity
    if @funds.size < Money::DEFAULT_DENOMINATION_QUANTITY
      instance_variable_set("@#{name}", Array.new(
        Money::DEFAULT_DENOMINATION_QUANTITY,
        Money.new(value: price)
      ))
      @funds.push instance_variable_get("@#{name}")
      self.class.__send__(:attr_accessor, "#{name}")
    else
      raise SetupFundsError.new('Vending Machine cannot accomodate more funds')
    end
  end

  def deduct_funds(value:, times:)
    @funds.each_with_index do |funds_category, index|
      @current_index = index
      @found_item = funds_category.detect { |item| item.value == value }
      break if @found_item
    end
    @funds[@current_index].shift(times) if @found_item
  end
end
