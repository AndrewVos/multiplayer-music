require "sinatra"
require "haml"
require "coffee-script"
require "sinatra-websocket"
require "json"

set :server, "thin"
set :sockets, []

sound_effects = Dir.glob("public/ogg/**/*.ogg").map do |path|
  path = path.gsub("public/ogg/", "")
  path = path.gsub(/\.ogg$/, "")
end
connected_count = 0

get "/" do
  if request.websocket?
    request.websocket do |socket|
      client_key = env["HTTP_SEC_WEBSOCKET_KEY"]
      instrument = sound_effects.sample.gsub(/^public/, "")

      socket.onopen do
        settings.sockets << socket
        socket.send({
          :type => "log",
          :message => "A new client connected"
        }.to_json)

        socket.onmessage do |value|
          message = {
            :type        => "play_sound",
            :client_key  => client_key,
            :button_down => value == "d" ? true : false,
            :instrument  => instrument
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
