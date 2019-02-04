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

    # view one
    get '/quotes/:index' do
      Quote.find_by(index: params[:index].to_i).to_json
    end
  end

get '/demo*' do
  content_type :html
  File.read(File.join('../../../static', 'index.html'))
end

get '/' do
  content_type :html
  "Hello World from Sinatra"
end

