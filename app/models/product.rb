class Product < ApplicationRecord
	belongs_to :category

	def self.to_csv(make)
	    attributes = %w{id name price} #customize columns here
	    lines = Product.where(maker_name: make)

	    Product.generate(headers: true) do |csv|
	      csv << attributes

	      lines.each do |line|
	        csv << attributes.map{ |attr| line.send(attr) }
	      end
	    end
  	end








end
