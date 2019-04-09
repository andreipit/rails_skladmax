class AdminController < ApplicationController
    #skip_before_action :verify_authenticity_token
    
    http_basic_authenticate_with name: "admin", password: "admin"#, except: :show
	
	def index
		@products = Product.where(category_id: '2') #test
	    @categories = Category.all
	    @edit_mode = true

	    @img_links = get_gdrive_imgs_for_products (@products)
      
	end

	def show
      @edit_mode = true
      @categories = Category.all
      @current_category_id = params[:category_id]
      leaves = []
      @categories.each do |cat|
        if (cat.parent_id == @current_category_id.to_i()) 
          then leaves << cat.id 
        end
      end
      if leaves.length == 0 then leaves = [@current_category_id] end
      @products = Product.where(category_id: leaves)
      @img_links = get_gdrive_imgs_for_products (@products)
	end

	def upload
      uploaded_io = params[:new_prices][:price_xls]
      File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end
      redirect_to admin_update_path(uploaded_io.original_filename)
      # redirect_to catalog_update_path("rails_temp_upload2.xls")
  end

  def update
		require 'roo'
		xlsx = Roo::Spreadsheet.open("public/uploads/" + params[:filename] + ".xls")
		@info2 = xlsx.info
		@data = []
		require 'activerecord-import'
		product_columns = [ :code, :name, :price, :category_id ]
		category_columns = [ :id, :name, :parent_id]


		# for  x  in 11..13
		# 	unless xlsx.sheet(0).row(x)[2] == nil
		# 		@data << [777, xlsx.sheet(0).row(x)[1], xlsx.sheet(0).row(x)[2], 4]
		# 	end
		# end

		products = []
		categories = []
		category_id = 0
		line_num = 0
		require 'bigdecimal'

		xlsx.sheet(0).each do |xrow|
			line_num += 1
			if line_num > 10
				if xrow[2] == nil
					category_id += 1
					categories << [category_id, xrow[1], 0]
				else
					products << [(sprintf '%05d', xrow[0]).to_s(), xrow[1], xrow[2].to_f(), category_id]
				end
			end
		end
		Product.delete_all
		Category.delete_all
		Product.import product_columns, products, validate: false
		Category.import category_columns, categories, validate: false

    end

		def test_gdrive
      require "google_drive"
      session = GoogleDrive::Session.from_config("config.json")
      # session.files.each do |file|
      #   p file.title
      # end
      file = session.file_by_title("cover.png")
      @img_link = file.web_content_link 
      @img_link
    end



	def get_gdrive_imgs_for_products (products)
      require "google_drive"
      @img_links = []
      session = GoogleDrive::Session.from_config("config.json")
      all_files = session.files
      @products.each do |product|
        search_result = all_files.select {|k| k.title == product.code+"_small.jpg"}
        if search_result.count != 0
          @img_links << {product_id: product.id, img_link: search_result[0].web_content_link}
        elsif
          @img_links << {product_id: product.id, img_link: all_files.select {|k| k.title == "no_image_small.jpg"}[0].web_content_link}
        end
      end
      @img_links
    end


end
