#!/usr/bin/ruby
require_relative  "#{__dir__}/money"
require_relative  "#{__dir__}/product"
require_relative  "#{__dir__}/setup_products"
require_relative  "#{__dir__}/setup_funds"

class VendingMachine
  class IncorrectItemNumberError < StandardError; end
  class InsufficientAmountInsertedError < StandardError; end
  include SetupProducts
  include SetupFunds

  attr_accessor :changes

  def initialize
    default_products
    default_funds
  end

  def start
    @products.each_with_index do |prod_category, index|
      puts "-- ENTER #{index} -- FOR #{prod_category.first.name.upcase} - price[#{prod_category.first.price}] - available[#{ prod_category.count }] \n\n\n"
    end
    input = get_input_from_user
    @cost = get_item_cost(input)
    puts "=== ITEM COST #{ @cost } ===="
    get_funds_from_user(input)
    release_product_to_user(input)
  end

  def release_product_to_user(input)
    # TODO - return product
    # TODO - subtract total balance of money from vending machine
    # TODO - return balance money if any
    puts "--- PRODUCT PURCHASED ---"
    puts "PRODUCT NAME = #{@products[input].first.name}"
    puts "PRODUCT PRICE = #{@products[input].first.price}"
    puts "TOTAL PAID PRICE = #{@user_inserted_money.to_f}"
    # puts "TOTAL PAID PRICE DENOMINATIONS = #{@total_amount_paid}"
    remove_product(name: @products[input].first.name)
    calculate_funds_deduction(input)
    puts "TOTAL ITEMS LEFT #{ @products.flatten.count }"
    puts "BALANCE PAID TO CUSTOMER = #{@return_amount}"
    puts "--- PRODUCT PURCHASED END---"
  end

  def calculate_funds_deduction(input)
    item_price = @products[input].first.price
    @return_amount = @user_inserted_money.to_f - item_price.to_f
    amt_paid_per_denomination = 0
    # Scenario 1
    # 1
    # 0.5 => 3 => 1.5
    # Scenario 2
    # 1
    # 0.10 => 8 => 0.80
    # 0.20 => 3 => 0.60  => 1.40
    @total_amount_paid.each do |coins_per_denomination|
      if item_price.to_f < @user_inserted_money
        amt_paid_per_denomination += coins_per_denomination[0] * coins_per_denomination[1]
        if amt_paid_per_denomination <= item_price.to_f

          deduct_funds(value: coins_per_denomination[0], times: coins_per_denomination[1])
        else
          balance = amt_paid_per_denomination - item_price.to_f
          times = balance/coins_per_denomination[0]
          deduct_funds(value: coins_per_denomination[0], times: times.to_i)
          # puts "@funds #{funds.inspect } #{funds.flatten.count}"
          break
         end
      else
        deduct_funds(value: coins_per_denomination[0], times: coins_per_denomination[1])
        # puts "@funds #{funds.inspect } #{funds.flatten.count}"
      end
    end
  end

  def get_funds_from_user(input)
    @user_inserted_money ||= 0
    @user_inserted_money += get_money_from_user
    # check if inserted funds are sufficient else ask more
    are_funds_sufficient_for_purchase?

  rescue InsufficientAmountInsertedError => e
    puts e.message
    get_funds_from_user(input)
  end

  def get_input_from_user
    puts "=== ENTER YOUR NUMBER HERE ===="
    input = STDIN.gets.chomp.to_i
    return input if is_input_valid?(input)
  rescue IncorrectItemNumberError => e
    puts e.message
    get_input_from_user
  end

  def get_money_from_user
    @total_amount_paid = Money::DENOMINATIONS_VALUES.each_with_object({}) do |denomination, hash|
      puts "COIN £ #{denomination}"
      puts "=== PRESS Y TO SELECT COIN or N TO GO TO NEXT COIN ===="
      answer = STDIN.gets.chomp.to_s.downcase
      if answer == 'y'
        puts "=== HOW MANY #{ denomination } ===="
         count = STDIN.gets.to_i
         if count > Money::DEFAULT_DENOMINATION_QUANTITY
          raise InsufficientAmountInsertedError.new("Can't process #{ count} number of coins; max is #{Money::DEFAULT_DENOMINATION_QUANTITY}")
         end
        hash[denomination] = count
      elsif answer == 'n'
        next
      end
    end
    sum = 0
    @total_amount_paid.each { |coin, count| sum += coin*count }
    sum
  end

  def are_funds_sufficient_for_purchase?
    # TODO - validate amount paid and cost of product
    # ask for more money if less and return change (after subtracting product) if any

    # check if total paid >= cost of product
    if @user_inserted_money.to_f >= @cost.to_f
      puts "TODO - RETURN PRODUCT TO CUSTOMER AND CHANGE IF ANY"
      true
    elsif @user_inserted_money.to_f < @cost.to_f
      raise InsufficientAmountInsertedError.new('Insufficient funds have been inserted')
    end
  end

  def get_item_cost(input)
    @products[input].first.price
  end

  def is_input_valid?(input)
    if (input > (@products.size - 1) || input < 0) && !@products[input]
      raise IncorrectItemNumberError.new("INCORRECT NUMBER ENTERED")
    end
  true
  end

end


v = VendingMachine.new
v.start
# v.add('pepsi', 2)

# Limitations of current program
=begin

Can buy an item just once, doesn't ask if you would like to buy
more products.

Design Problems
The funds and products load modules methods add and remove methods
have similar functionality and need to be extracted to a module so that
those methods can be resued in both the modules

Programs asks to choose each type of coin and total number per coin
(bad design). Would like to improve this part to select a
coin in a denomination and the count and calculate if that covers the total cost of the
item being purchased, if so then proceed to return the item with funds deducted etc.

VendingMachine methods - need to be refacted and methods need to be extracted in
appriate classes/modules
=end