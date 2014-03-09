require "statsample"
require "csv"

x_data= []
y_data= []

CSV.foreach("../data/BITSTAMPUSD_reverse.csv") do |row|
  ts= Date.parse(row[0]).to_time.to_i
  open= row[1].to_f
  x_data<< ts
  y_data<< open
end

x_vector=x_data.to_vector(:scale)
y_vector=y_data.to_vector(:scale)
ds={'x'=>x_vector,'y'=>y_vector}.to_dataset
mlr=Statsample::Regression.multiple(ds,'y')
mlr.summary

p mlr
