require "sinatra"
require "haml"
require "coffee-script"
require "sinatra-websocket"
require "json"

set :server, "thin"
set :sockets, []
set :sound_effects, Dir.glob("public/ogg/**/*.ogg").map { |p| p.gsub("public/ogg/", "").gsub(/\.ogg$/, "") }

connected_count = 0

get "/instruments" do
  content_type :json
  settings.sound_effects.to_json
end

get "/?" do
  if request.websocket?
    request.websocket do |socket|
      client_key = env["HTTP_SEC_WEBSOCKET_KEY"]

      socket.onopen do
        settings.sockets << socket
        socket.send({
          :type => "log",
          :message => "A new client connected"
        }.to_json)

        socket.onmessage do |value|
          value = JSON.parse(value)
          message = {
            :key         => client_key + value["instrument"],
            :type        => "play_sound",
            :play        => value["state"] == "down" ? true : false,
            :instrument  => value["instrument"]
          }.to_json
          EM.next_tick { settings.sockets.each{|s| s.send(message) } }
        end

        socket.onclose do
          connected_count -= 1
          settings.sockets.delete(socket)
        end
      end
    end
  else
    haml :index
  end
end

get "/scripts/script.js" do
  content_type "text/javascript"
  coffee :script
end
