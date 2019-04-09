class ProductController < ApplicationController
  skip_before_action :verify_authenticity_token # vs error in js console:
  def show
    @product = Product.find_by(code: params[:code])
    @test = 889
      @img_link = get_gdrive_image(@product.code + '.jpg')



  end

  def upload_img


    uploaded_io = params[:new_imgs][:new_img]

    # save big and small local version
    big_name = params[:new_imgs][:product_code]+ '.jpg'
    big_path = Rails.root.join('app', 'assets', 'images', big_name)
    small_name = params[:new_imgs][:product_code]+ '_small.jpg'
    small_path = Rails.root.join('app', 'assets', 'images', small_name)
    save_local_file(uploaded_io, big_path)
    FileUtils.cp big_path, small_path

    # optimize local versions
    resize_img(big_path, "1920x1080")
    compress_img(big_path)
    resize_img(small_path, "250x250")
    compress_img(small_path)

    # upload to gdrive and delete local version
    upload_to_gdrive(big_path.to_s, big_name, 'Electro')
    upload_to_gdrive(small_path.to_s, small_name, 'Electro')
    File.delete(big_path) if File.exist?(big_path)
    File.delete(small_path) if File.exist?(small_path)


    if params[:new_imgs][:category_id] == ""
      redirect_to admin_index_path
    else
      redirect_to admin_show_path(params[:new_imgs][:category_id])
    end

  end



  def file_dir_or_symlink_exists?(path_to_file)
      File.exist?(path_to_file) || File.symlink?(path_to_file)
  end


  def get_gdrive_image (file_name)
      require "google_drive"
      session = GoogleDrive::Session.from_config("config.json")
      # session.files.each do |file|
      #   p file.title
      # end
      # file = session.file_by_title("cover.png")


      file = session.file_by_title(file_name)

      if file == nil
        file = session.file_by_title('no_image.jpg')
      end

      @img_link = file.web_content_link 
      @img_link
  end




private
    def save_local_file (uploaded_file, new_path)
      # new_path = Rails.root.join('app', 'assets', 'images', filename + '.jpg')
      # new_path = Rails.root.join('app', 'assets', 'images', params[:new_imgs][:product_code]+ '.jpg')
      File.open(new_path, 'wb') do |file|
        # file.write(uploaded_io.read)
        file.write(uploaded_file.read)
      end
    end

    def compress_img (img_path)
      require 'image_optim' # compresses images
      #image_optim = ImageOptim.new
      image_optim = ImageOptim.new(:pngout => false)
      # image_optim = ImageOptim.new(:pngcrush => false)
      #image_optim = ImageOptim.new(:nice => 20)
      # image_optim.optimize_image!(Rails.root.join('app', 'assets', 'images', '1217.jpg'))
      image_optim.optimize_image!(img_path)
    end
    
    def resize_img (img_path, resolution)
      require "mini_magick"
      # image = MiniMagick::Image.open(Rails.root.join('app', 'assets', 'images', '1217.jpg'))
      image = MiniMagick::Image.open(img_path)
      # image.resize "248x156"
      image.resize resolution
      # image.write Rails.root.join('app', 'assets', 'images', '1217.jpg')
      image.write(img_path)
    end


    def upload_to_gdrive (local_file_path, gdrive_file_name, gdrive_folder_name) #share folder!!!
      require "google_drive"
      session = GoogleDrive::Session.from_config("config.json")

      # session.upload_from_file("/path/to/hello.txt", "hello.txt", convert: false)

      # session.upload_from_file(file_path, file_name, convert: false)

      # delete old image from folder
      old_file = session.file_by_title(gdrive_file_name)
      if old_file != nil
        session.collection_by_title(gdrive_folder_name).remove(old_file)
      end


      file = session.upload_from_file(local_file_path, gdrive_file_name, convert: false)
      session.collection_by_title(gdrive_folder_name).add(file) 
      session.root_collection.remove(file) 


    end


end
