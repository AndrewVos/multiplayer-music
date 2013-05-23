host = "ws://" + window.location.host
socket = new WebSocket(host)

$().ready ->
  createInstrumentButtons()

socket.onmessage = (event)->
  json = jQuery.parseJSON(event.data)
  if json.type == "play_sound"
    playSound(json.client_key, json.instrument, json.play)
  else if json.type == "log"
    console.log(json.message)

playSound = (client_key, instrument, play) ->
  @soundPlayers ||= {}
  soundPlayerId = client_key + instrument

  unless soundPlayerId of @soundPlayers
    @soundPlayers[soundPlayerId] = new SoundPlayer(instrument)

  if play
    @soundPlayers[soundPlayerId].play()
    highlightUserInstrument(client_key, instrument, "red")
  else
    @soundPlayers[soundPlayerId].stop()
    highlightUserInstrument(client_key, instrument, "grey")

highlightUserInstrument = (client_key, instrument, colour) ->
  id = client_key.replace(/[^\w]/g, "")
  if $("div#" + id).length > 0
    clientInstruments = $("div#" + id)
  else
    clientInstruments = $("<div>")
    clientInstruments.attr("id", id)
    clientInstruments.append($("<h2>" + id + "</h2>"))
    $(".other-instruments").append(clientInstruments)
    for x in window.instruments
      do (x) ->
        clientInstruments.append($("<div id='#{x + id}' class='instrument'></div>"))
  $("div#" + instrument + id).css("background-color", colour)

createInstrumentButtons = ->
  jQuery.getJSON "/instruments", (instruments) ->
    window.instruments = instruments
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
  stop: ->
    @player.stop()
