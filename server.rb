require "em-websocket"
require "json"

sound_effects = Dir.glob("public/ogg/**/*.ogg").map do |path|
  path = path.gsub("public/ogg/", "")
  path = path.gsub(/\.ogg$/, "")
end
connected_count = 0

EventMachine.run {
  @channel = EM::Channel.new
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
    ws.onopen do |handshake|
      client_key = handshake.headers["Sec-WebSocket-Key"]
      instrument = sound_effects.sample.gsub(/^public/, "")

      sid = @channel.subscribe { |msg| ws.send msg }
      @channel.push({
        :type => "log",
        :message => "A new client connected"
      }.to_json)
      connected_count += 1

      ws.onmessage do |value|
        message = {
          :type        => "play_sound",
          :client_key  => client_key,
          :button_down => value == "d" ? true : false,
          :instrument  => instrument
        }
        @channel.push(message.to_json)
      end

      ws.onclose do
        connected_count -= 1
        @channel.unsubscribe(sid)
      end

      ws.onerror do |e|
        puts e.message
      end
    end
  end
}
