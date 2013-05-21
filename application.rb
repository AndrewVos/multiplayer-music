require "sinatra"
require "haml"
require "coffee-script"

get "/" do
  haml :index
end

get "/scripts/script.js" do
  content_type "text/javascript"
  coffee :script
end
