require "sinatra"
require "haml"
require "coffee-script"

get "/" do
  haml :index
end

get "/script.js" do
  content_type "text/javascript"
  coffee :script
end
