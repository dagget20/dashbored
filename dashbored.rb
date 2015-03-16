require 'sinatra'
require 'instagram'

enable :sessions

CALLBACK_URL = "http://localhost:4567/oauth/callback"

Instagram.configure do |config|
	config.client_id = "a993c9e8a9e04fd18edcd183f92b14d6"
	config.client_secret = "5032e6b1ba78481f87b5a28db26a4b7a"
end

get '/' do
	@title = "Dashbored - Instagram"
	erb :index
end

get '/oauth/connect' do 
	redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get '/oauth/callback' do
	response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
	session[:access_token] = response.access_token
	redirect "/home"
end

get '/signout' do
	session[:access_token] = nil
	redirect "/"
end

get '/home' do
	if session[:access_token]
		client = Instagram.client(:access_token => session[:access_token])
		@user = client.user
	else 
		redirect "/"
	end

	erb :home
end

get '/media_like/:id' do
  client = Instagram.client(:access_token => session[:access_token])
  client.like_media("#{params[:id]}")
  redirect "/user_recent_media"
end

get "/user_recent_media" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user
  html = "<h1>#{user.username}'s recent media</h1>"
  for media_item in client.user_recent_media(:count => 10)
    html << "<div style='float:left;'><img src='#{media_item.images.thumbnail.url}'><br/> <a href='/media_like/#{media_item.id}'>Like</a>  <a href='/media_unlike/#{media_item.id}'>Un-Like</a>  <br/>LikesCount=#{media_item.likes[:count]} CommentsCount=#{media_item.comments[:count]}</div>"
  end
  html
end
