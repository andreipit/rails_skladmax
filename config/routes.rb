Rails.application.routes.draw do

  	# get '' =>  'catalog#index', as: 'root' # главная страница
  	get root 'catalog#index', as: 'root' # главная страница
	get '/catalog/:category_id' => 'catalog#show', as: 'catalog_show' # показать категорию
	
	get '/search' => 'search#index', as: 'search_index' # поиск товара
    #get '/admin/panel/community/:id/search' => 'category#category_user_search', as: 'category_user_search'
	
	# get '/order/' => 'order#index', as: 'order_index' # корзина
	# get '/order/add/:code' => 'order#add', as: 'order_add' # добавить в корзину
	# get '/order/remove/:code' => 'order#remove', as: 'order_remove' # удалить из корзины
	# post '/order/send_email' => 'order#send_email', as: 'order_send_email' # отправить заказ на емаил
	
	get '/product/:code' => 'product#show', as: 'product_show' # отображение одного продукта
	# post '/product/upload_img' => 'product#upload_img', as: 'product_upload_img', :defaults => { :format => 'js' } # смена изображения
	post '/product/upload_img' => 'product#upload_img', as: 'product_upload_img'# смена изображения
	
	get '/about/' => 'about#index', as: 'about_index' # контакты
	get '/about/get_price' => 'about#get_price', as: 'about_get_price' # скачать прайс со ссылками

	get '/admin' => 'admin#index', as: 'admin_index' # секретная страница для загрузки нового прайса
	get '/admin/:category_id' => 'admin#show', as: 'admin_show' # показать категорию
	post '/admin/upload' => 'admin#upload', as: 'admin_upload' # сохранить новый прайс
	get '/admin/update/:filename' => 'admin#update', as: 'admin_update' # обновить базу в соответствие с новым прайсом
	
	# get '/welcome/index' => 'welcome#index', as: 'welcome_index' # 
	# get '/welcome/test' => 'welcome#test', as: 'welcome_test' # 
  	
end
