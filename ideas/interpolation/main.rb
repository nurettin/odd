require "interpolator"
require "csv"
require "json/ext"

# http://www.quandl.com/markets/bitcoin
# wget http://www.quandl.com/api/v1/datasets/BITCOIN/BITSTAMPUSD.csv?&trim_start=2011-09-13&trim_end=10/03/6&sort_order=desc
# tac BITSTAMPUSD.csv\? BITSTAMPUSD_reverse.csv

candle= []

CSV.foreach("BITSTAMPUSD_reverse.csv") do |row|
  candle<< [Date.parse(row[0]).to_time.to_i, row[4].to_f]
end

def interpolate_next(data, range, style)
  t = Interpolator::Table.new Hash[data[range]]
  t.style= style
  after= data[range.last+ 1]
  after_t= after[0]
  guess= t.interpolate(after_t)
  real= after[1]
  error= ((real- guess)/ guess* 100).abs
  { time: after_t, real: real, guess: guess, error: error }
end

def interpolate_styles(data, range)
  (1..5).map{ |s| interpolate_next(data, range, s) }
end

def interpolate_styles_summary(data, length)
  intervals= (data[-1][0]- data[0][0])/ (60* 60* 24* length)
  (1..intervals).map do |w|
    r= ( ((w- 1)* length)..(w* length- 1) )
    interpolate_styles(data, r)
  end.reduce({}) do |r, w|
    w.each_with_index do |e, i|
      r[i+ 1]||= []
      r[i+ 1]<< { intervals: intervals, length: length, errors: e }
    end
    r
  end
end

def interpolate_styles_summary_ranges(candle)
  (4..candle.count- 1).map do |length|
    interpolate_styles_summary(candle, length).map do |style, data|
      puts JSON.pretty_generate(data)
      { style: style, sum_errors: data[:errors].reduce(:+)/ data[:errors].count }
    end
  end
end

summary_ranges= interpolate_styles_summary_ranges(candle)
p summary_ranges

=begin
.reduce({}) do |r, k, v|
  r[k]+= v
  r
end
=end

