require "linefit"
require "csv"
require "gruff"

lf= LineFit.new

x= []
y= []
@ts= []
CSV.foreach("../data/BITSTAMPUSD_reverse.csv") do |row|
  x<< Date.parse(row[0]).to_time.to_i
  y<< row[1].to_f
  @ts<< [x, y]
end

lf.setData(x, y)

g = Gruff::Line.new(400)
g.title = 'Many Values Line Test 400px'
g.labels = {
    0 => '5/6',
    10 => '5/15',
    20 => '5/24',
    30 => '5/30',
    40 => '6/4',
    50 => '6/16'
}
%w{jimmy jane philip arthur julie bert}.each do |student_name|
  g.data(student_name, (0..50).collect { |i| rand 100 })
end

# Default theme
g.write('line_many_lines_small.png')
