require 'sinatra'
require 'sinatra/namespace'
require 'mongoid'

require 'json/ext' # required for .to_json

class Quote
  include Mongoid::Document
  field :index
  field :author
  field :content
end

Mongoid.load!("mongoid.yml", :development)
set :port, 8080
set :bind, '0.0.0.0'


before do
  content_type 'application/json', :charset => 'utf-8'
end

  namespace "/api" do
     # list all
    get '/quotes' do
      Quote.all.desc(:index).limit(10).to_json
    end

     # create
    post '/quotes' do
      top = Quote.all.desc(:index).limit(1)
      newnumber = top[0][:index] + 1
      json = JSON.parse(request.body.read)
      if not json['content'] then
        return [400, "New quotes must include content"]
      end
      quote = Quote.new(
                        content: json['content'], 
                        author: json['author'], 
                        index: newnumber)
      quote.save
      return_obj = {"index" => newnumber}
      return [201, return_obj.to_json]
    end

    get '/quotes/random' do
      top = Quote.all.desc(:index).limit(1)
      random_num = rand(top[0][:index]).to_i
      quote = Quote.find_by(index: random_num)
      return status 404 if quote.nil?
      quote.to_json
    end

    # view one
    get '/quotes/:index' do
      quote = Quote.find_by(index: params[:index].to_i).to_json
    end

      # update
    put '/quotes/:index' do
      json = JSON.parse(request.body.read)
      quote = Quote.find_by(index: params[:index].to_i)

      if json['content'] then
        quote.update(content: json['content'])
      end

      if json['author'] then
        quote.update(author: json['author'])
      end

      return_obj = {"index" => params[:index].to_i}
      return [201, return_obj.to_json]
    end

    delete '/quotes/:index' do
      quote = Quote.find_by(index: params[:index].to_i)
      return status 404 if quote.nil?
      quote.delete
      status 204
    end
  end

get '/demo*' do
  content_type :html
  File.read(File.join('../../static', 'index.html'))
end

get '/' do
  content_type :html
  "Hello World from Sinatra"
end

