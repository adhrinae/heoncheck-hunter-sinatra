require 'sinatra'
require_relative './lib/book_search'

get '/' do
  erb :index
end

get '/search' do
  book_title = params[:title]

  @results = BookSearch.new(book_title).search
  erb :result, locals: { results: @results }
end
