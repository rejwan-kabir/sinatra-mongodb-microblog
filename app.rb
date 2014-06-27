require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'mongoid'
require 'slim'
require 'kramdown'

Slim::Engine.set_default_options pretty: true

configure do
  Mongoid.load! "./mongoid.yml"
  enable :sessions
end

configure :development do
  enable :logging
end

class User
  include Mongoid::Document
  field :name, type: String
  embeds_many :blogs
end

class Blog
  include Mongoid::Document
  field :content, type: String
  embedded_in :user
end

get '/?' do
  @all_user = User.all
  @user = User.new
  slim :index
end

post '/?' do # for creating new user
  user = User.create(params[:user])
  redirect to("/")
end

get '/user/delete/:user_id/?' do
  User.find(params[:user_id]).destroy
  redirect to("/")
end

get '/user/:user_id/?' do
  @user = User.find(params[:user_id])
  @all_blog = @user.blogs
  @new_blog = Blog.new
  slim :user
end

post '/blog/create/?' do
  user = User.find(params[:user_id])
  user.blogs << Blog.new(params[:new_blog])
  redirect to("/user/#{params[:user_id]}")
end

get '/blog/delete/:user_id/:blog_id/?' do
  user = User.find(params[:user_id])
  user.blogs.destroy_all( {_id: "#{params[:blog_id]}"} )
  redirect to("/user/#{params[:user_id]}")
end