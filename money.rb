class Money
  class InvalidValue < StandardError; end

  attr_accessor :value
  DEFAULT_DENOMINATION_QUANTITY = 10
  DENOMINATIONS_VALUES = [0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2].freeze
  DENOMINATIONS = [
    { name: 'one_pence', price: 0.01 },
    { name: 'two_pence', price: 0.02 },
    { name: 'five_pence', price: 0.05 },
    { name: 'ten_pence', price: 0.1 },
    { name: 'twenty_pence', price: 0.2 },
    { name: 'fifty_pence', price: 0.5 },
    { name: 'one_pound', price: 1 },
    { name: 'two_pound', price: 2 }
  ].freeze

  def initialize(value:)
    if (DENOMINATIONS_VALUES & [value]).empty?
      raise InvalidValue.new('Money denomination not acceptible')
    end
    @value = value
  end
end
