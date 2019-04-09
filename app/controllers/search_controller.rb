class SearchController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index


      filter_type = params[:filter][:filter_type]
      query = params[:filter][:query] 



      @products = []


      #byebug

      #@products = Product.where(category_id: '3') #test


      if filter_type == "0"
        @products = Product.where(code: query) 
      elsif filter_type == "1"
        @products = Product.where("name like ?", "%#{query}%")
      end

     	@product_test = Product.first
      @categories = Category.all

      
      # products = Product.find_by(:id=>params[:question_id])
      # redirect_to catalog_show_path
      # @img_link = test_gdrive
      @img_links = get_gdrive_imgs_for_products (@products)
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


# def course_params
#   params.require(:course).permit(:user_id)
# end

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
    