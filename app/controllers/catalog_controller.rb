class CatalogController < ApplicationController
    skip_before_action :verify_authenticity_token


    def index
      # @products = Product.all.paginate(:page => params[:page], :per_page => 3).order('code DESC')
      # @products = Product.all
      @products = []

      @products = Product.where(category_id: '2') #test

     	@product_test = Product.first
      @categories = Category.all
      @edit_mode = false


      @img_links = get_gdrive_imgs_for_products (@products)
    end

  	def secret
      # require 'roo'
      # xlsx = Roo::Spreadsheet.open('app/assets/rails_temp_upload.xls')
      # @info = xlsx.info
  	end

  	

    def filter

    end


    def show
      @edit_mode = false
      @categories = Category.all
      @current_category_id = params[:category_id]
      
      # find all final categories (like leaves on tree)
      leaves = []


      @categories.each do |cat|
        if (cat.parent_id == @current_category_id.to_i()) 
          then leaves << cat.id 
        end
      end

      # while find_children_categories(params[:category_id].to_i()).length != 0
      # end


      if leaves.length == 0 then leaves = [@current_category_id] end

      @products = Product.where(category_id: leaves)


      @img_links = get_gdrive_imgs_for_products (@products)

    end

    def test_ajax

      # byebug
      # respond_to :js

      # @products = Product.where(category_id: 2)
      @product_test = Product.second

      respond_to do |format|
        # format.html
        format.js
      end

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
