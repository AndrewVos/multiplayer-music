host = "ws://localhost:8080"
socket = new WebSocket(host)
instrument = Math.round(Math.random(0, 1) * 10) - 1

socket.onmessage = (event)->
  $("body").append($("<p>" + event.data + "</p>"))

$().ready ->
  $("#play").mousedown ->
    try
      socket.send("d" + instrument)

  $("#play").mouseup ->
    try
      socket.send("u" + instrument)

class SoundPlayer
  constructor: (@client_key, @instrument) ->
