class AboutController < ApplicationController
	require 'axlsx_rails'
	require 'axlsx'

	def index
	# @products = Product.all
	# products = Product.find_by(:id=>params[:question_id])

	end


    def get_price
        categories = Category.all
        products = Product.all
        price = []

        categories.each do |cat|
        	price << ['', cat[:name], '']
        	products.where(category_id: cat.id).each do |prod|
        		price << [prod[:code], '=HYPERLINK("' + request.url.chomp('about/get_price') + 'product/' + prod[:code].to_s() + '","' + prod[:name] + '")', prod[:price]]
        	end
        end

        a = [{"action_id": 1}, {"action_id": 2}, {"action_id": 3}]
        # data = get_xlsx_data a
        data = get_xlsx_data price
        send_data data.to_stream.read, filename: "subscribers.xlsx"
        # redirect_to :back
    end

    def get_xlsx_data entries
        p = Axlsx::Package.new do |p|
            p.workbook.add_worksheet(name: "awe") do |sheet|
                sheet.add_row ['Код', 'Номенклатура', 'Опт штучно']
                entries.each do |entry|
                    sheet.add_row ["'"+entry[0]+"'", entry[1], entry[2]]
                    # sheet.add_row [entry[:action_id], '=HYPERLINK("http://localhost:3000/product/7315","linkTS")', 22]
                end
            end
        end
        return p
    end


end
