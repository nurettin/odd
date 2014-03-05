require "sinatra"
require "sinatra-websocket"
require "json"
require "pusher-client"
require_relative "../../lib/finance/io/candle_stream"

set :server, "thin"
set :bind, "0.0.0.0"
set :sockets, []
candle_stream1= Finance::IO::CandleStream.start(60) do |row|
  puts "output: #{row}"
  EM.next_tick { settings.sockets.each{ |s| s.send(row.to_json) } }
end
set :candle_stream1, candle_stream1

set :btce_client, PusherClient::Socket.new("de504dc5763aeef9ff52")

live_trades= settings.btce_client.subscribe("live_trades")
live_trades.bind("trade") do |data|
  json= JSON.parse(data)
  wut= [Time.now.to_i, json["price"], json["amount"]]
  puts "input: #{wut}"
  settings.candle_stream1<< wut
  # EM.next_tick { settings.sockets.each{ |s| s.send(wut.to_json) } }
end

# async connect
settings.btce_client.connect(true)

get "/" do
  if !request.websocket?
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
        ws.send("Baglandi!")
        settings.sockets << ws
      end
      ws.onclose do
        warn("Adam kapatti.")
        settings.sockets.delete(ws)
      end
    end
  end
end

__END__
@@ index
<html>
  <body>
     <div id="msgs"></div>
  </body>

  <script type="text/javascript">
    window.onload = function(){
      (function(){
        var show = function(el){
          return function(msg){ el.innerHTML = msg + "<br />" + el.innerHTML; }
        }(document.getElementById("msgs"));

        var ws       = new WebSocket("ws://" + window.location.host+ window.location.pathname);
        ws.onopen    = function()  { show("canli bitstamp verileri"); };
        ws.onclose   = function()  { show("soket kapandi"); }
        ws.onmessage = function(m) { show("veri: " +  m.data); };

      })();
    }
  </script>
</html>

