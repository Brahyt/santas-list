#!/usr/bin/env ruby

require 'csv'
require 'debug'

drinks_file_path = ARGV[0]
shopify_file_path = ARGV[1]

def make_object(sheet)
  CSV.parse(File.open(sheet), headers: :first_row)
end

def grab_order_nums(object, field)
  object[field]
end

def list_missing_gids(drinks_input, shopify_input)
  missing = shopify_input.delete_if{|x| drinks_input.include?(x['Name'])}

  grab_order_nums(missing, 'Id').compact
end

drinks_csv = make_object(drinks_file_path)
shopify_csv = make_object(shopify_file_path)

drinks_order_names = grab_order_nums(drinks_csv, 'ORDER_NAME')
shopify_order_names = grab_order_nums(shopify_csv, 'Name')

output = File.open('output.txt', 'w')

output.puts 'FILE       COUNT MISSING'
output.puts '-' * 40
output.puts "shopify    #{(drinks_order_names.uniq - shopify_order_names.uniq).count}"
output.puts "drinks     #{(shopify_order_names.uniq - drinks_order_names.uniq).count}"
output.puts
output.puts '====MISSING SHOPIFY GIDS===='
output.print list_missing_gids(drinks_order_names, shopify_csv)

puts "generated 'output.txt'"
