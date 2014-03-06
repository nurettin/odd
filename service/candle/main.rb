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
        settings.sockets << ws
      end
      ws.onclose do
        settings.sockets.delete(ws)
      end
    end
  end
end

__END__
@@ index
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset="UTF-8">
  <title>Bitstamp Live 60s Candles</title>
  <script type='text/javascript' src='https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'></script>

<script>
  var ws;
  var chart;
    $(document).ready(function() {
        ws = new WebSocket("ws://" + window.location.host+ window.location.pathname);
        
        ws.onmessage = function(m) { 
          console.log(m.data);
          var json= JSON.parse(m.data);
          console.log(json);
          chart.series[0].addPoint( json ); 
        };

        Highcharts.setOptions({
            global: {
                useUTC: false
            }
        });

        chart = new Highcharts.Chart({
            chart: {
                renderTo: 'container',
                type: 'candlestick',
                marginRight: 10
            },
            title: {
                text: 'Live bitstamp data'
            },
            xAxis: {
                type: 'datetime',
                tickPixelInterval: 150
            },
            yAxis: {
                title: {
                    text: 'Value'
                },
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'}]
            },
            tooltip: {
                formatter: function() {
                    return '<b>' + this.series.name + '</b><br/>' + Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x) + '<br/>' + Highcharts.numberFormat(this.y, 2);
                }
            },
            legend: {
                enabled: false
            },
            exporting: {
                enabled: false
            },
            series: [{
                name: 'Random data',
                type: 'candlestick',
                data: []
                }]
        });

    });
</script>


</head>
<body>
<script src="http://code.highcharts.com/stock/highstock.js"></script>
<script src="http://code.highcharts.com/modules/exporting.js"></script>

<div id="container" style="min-width: 400px; height: 400px; margin: 0 auto"></div>

  
</body>


</html>

