require "em-websocket"
require "json"

EventMachine.run {
  @channel = EM::Channel.new
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
    ws.onopen do |handshake|
      client_key = handshake.headers["Sec-WebSocket-Key"]

      sid = @channel.subscribe { |msg| ws.send msg }
      # @channel.push "#{sid} connected!"

      ws.onmessage do |value|
        message = {
          :client_key  => client_key,
          :button_down => value[0,1] == "d" ? true : false,
          :instrument  => Integer(value[1,1])
        }
        puts message
        @channel.push(message.to_json)
      end

      ws.onclose do
        @channel.unsubscribe(sid)
      end

      ws.onerror do |e|
        puts e.message
      end
    end
  end
}
