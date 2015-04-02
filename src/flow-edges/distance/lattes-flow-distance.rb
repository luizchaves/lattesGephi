require 'byebug'

def normalise(x)
	xmin = 0.0
	xmax = 52324.0
	ymin = 0.0
	ymax = 1.0
  xrange = xmax - xmin
  yrange = ymax - ymin
  ymin + (x - xmin) * (yrange.to_f / xrange) 
end

edges_file = File.read('edges-flow-year.csv')

result = []
edges_file.split("\n").each{|row|
	row = row.split(",")
	# result << row[-3] if row[4] == 'doutorado'
	result << row[-3].to_i if row[4] == 'doutorado'
}

File.write("lattes-flow-distance.csv", "distances\n"+result.sort.join("\n"))