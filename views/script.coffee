host = "ws://" + window.location.hostname + ":8080"
socket = new WebSocket(host)

logSomething = (l) ->
  $("body").append($("<p>" + l + "</p>"))

socket.onmessage = (event)->
  json = jQuery.parseJSON(event.data)
  @soundPlayers ||= {}

  if json.type == "play_sound"
    unless json.client_key of @soundPlayers
      soundPlayer = new SoundPlayer(json.instrument)
      @soundPlayers[json.client_key] = soundPlayer

    if json.button_down
      @soundPlayers[json.client_key].play()
    else
      @soundPlayers[json.client_key].stop()
  else if json.type == "log"
    logSomething(json.message)

$().ready ->
  $("#play").mousedown ->
    try
      socket.send("d")

  $("#play").mouseup ->
    try
      socket.send("u")

class SoundPlayer
  constructor: (@instrument) ->
    if buzz.isAACSupported()
      @player = new buzz.sound("/aac/" + @instrument + ".m4a")
    else if buzz.isOGGSupported()
      @player = new buzz.sound("/ogg/" + @instrument + ".ogg")

  play: ->
    @player.loop().play()
    logSomething("playing  " + @instrument)

  stop: ->
    @player.stop()
    logSomething("stopping " + @instrument)
