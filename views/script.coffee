host = "ws://" + window.location.host
socket = new WebSocket(host)

logSomething = (l) ->
  $(".messages").append($("<p>" + l + "</p>"))

socket.onmessage = (event)->
  json = jQuery.parseJSON(event.data)
  @soundPlayers ||= {}

  if json.type == "play_sound"
    unless json.key of @soundPlayers
      soundPlayer = new SoundPlayer(json.instrument)
      @soundPlayers[json.key] = soundPlayer

    if json.play
      @soundPlayers[json.key].play()
    else
      @soundPlayers[json.key].stop()
  else if json.type == "log"
    logSomething(json.message)

$().ready ->
  createInstrumentButtons()

createInstrumentButtons = ->
  jQuery.getJSON "/instruments", (instruments) ->
    for instrument in instruments
      do (instrument) ->
        container = $(".instruments")
        button = $("<div class='instrument'></div>")
        container.append(button)
        button.mousedown ->
          sendInstrumentStateChange("down", instrument)
          button.css("background-color", "red")
        button.mouseup ->
          sendInstrumentStateChange("up", instrument)
          button.css("background-color", "grey")

sendInstrumentStateChange = (state, instrument) ->
  socket.send(JSON.stringify({state: state, instrument: instrument}))

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
