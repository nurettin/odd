require "interpolator"

# a curve that rise and fall fast
t = Interpolator::Table.new 0.1 => 2, 0.4 => 3, 0.8 => 10, 1.0 => 12, 1.2 => 11, 1.4 => 8
# LINEAR
t.style = 1
[0, 0.5, 1.0, 1.5, 2.0].each {|x| puts( t.interpolate(x)) }   
 
# LAGRANGE
t.style = 2
[0, 0.5, 1.0, 1.5, 2.0].each {|x| puts( t.interpolate(x)) }
 
# LAGRANGE 3
t.style = 3
[0, 0.5, 1.0, 1.5, 2.0].each {|x| puts( t.interpolate(x)) }
 
# CUBIC
t.style = 4
[0, 0.5, 1.0, 1.5, 2.0].each {|x| puts( t.interpolate(x)) }
 
# SPLINE
t.style = 5
[0, 0.5, 1.0, 1.5, 2.0].each {|x| puts( t.interpolate(x)) }

