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
  unless client_key of @soundPlayers
    @soundPlayers[client_key] = new SoundPlayer(client_key)
  if play
    @soundPlayers[client_key].play(instrument)
  else
    @soundPlayers[client_key].stop(instrument)

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
  constructor: (@clientKey) ->
    @instruments = {}
    @id = @clientKey.replace(/[^\w]/g, "")
    @clientInstruments = $("<div>")
    @clientInstruments.attr("id", @id)
    @clientInstruments.append($("<h2>" + @id + "</h2>"))
    $(".other-instruments").append(@clientInstruments)
    for instrument in window.instruments
      do (instrument) =>
        @clientInstruments.append($("<div id='#{instrument + @id}' class='instrument'></div>"))

  play: (instrument) ->
    unless instrument of @instruments
      if buzz.isAACSupported()
        @instruments[instrument] = new buzz.sound("/aac/" + instrument + ".m4a")
      else if buzz.isOGGSupported()
        @instruments[instrument] = new buzz.sound("/ogg/" + instrument + ".ogg")
    @instruments[instrument].loop().play()
    $("div#" + instrument + @id).css("background-color", "red")

  stop: (instrument) ->
    @instruments[instrument].stop()
    $("div#" + instrument + @id).css("background-color", "grey")
