require "linefit"
require "csv"
require "gruff"

lf= LineFit.new

x= []
y= []
labels= {}
CSV.foreach("../data/BITSTAMPUSD_reverse.csv") do |row|
  x<< Date.parse(row[0]).to_time.to_i
  y<< row[1].to_f
  labels[x[-1]]= row[0]
end

len_err= Hash[(2..10).map do |l|
  [l, (600..810- l).map do |n|
    xc= x[n..n+ l]
    yc= y[n..n+ l]
    lf.setData(xc, yc)
    lf.residuals.map(&:abs).max
  end]
end]

g = Gruff::Line.new(800)
g.title = "btstamp"
len_err.each do |k, v|
  g.data(k, v)
end
g.write("draw.png")

=begin
g = Gruff::Line.new(800)
g.title = "btstamp"
g.labels= labels
g.data("open", yc)
g.data("fit", lf.predictedYs)
g.data("errmax", (1..l).map{ max })
g.data("err", lf.residuals)
g.write('draw.png')
=end
