require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
	"Hello World"
end

get '/hello_world' do
	erb :'hello_world/hello_world'
end
