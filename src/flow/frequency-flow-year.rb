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

nodes_file = File.read('nodes-flow-year.csv')
edges_file = File.read('edges-flow-year2.csv')

edges = []
edges_file.split("\n").each{|row|
	row = row.split(",")
	# edges << row
	# only degree
	# edges << row if row[2] == 'degree'
	# only phd
	# edges << row if row[4] == 'doutorado'
	# only last 10 year
	# edges << row if row[-2].to_i >= 2005 
	# only degree and last 10 year
	# edges << row if row[2] == 'degree' and row[-2].to_i >= 2005 
	# only phd and last 10 year
	edges << row if row[4] == 'doutorado' and row[-2].to_i >= 2005 
	# only phd and 1995-2005 year
	# edges << row if row[4] == 'doutorado' and row[-2].to_i < 2005 and row[-2].to_i >= 1995
	# only phd and 1985-1995 year
	# edges << row if row[4] == 'doutorado' and row[-2].to_i < 1995 and row[-2].to_i >= 1985
	# only phd and 1985-1995 year
	# edges << row if row[4] == 'doutorado' and row[-2].to_i < 1985 and row[-2].to_i >= 1975
}

nodes = {}
nodes_file.split("\n").each{|row|
	row = row.split(",")
	nodes[row[0]] = row[1..3].join(' - ')
}

cities = []
edges[1..-1].each{|edge|
	cities << nodes[edge[1]]
}

frequency = cities.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}
frequency = frequency.sort_by {|_key, value| value}.to_h

string = "\"cities\", \"count\"\n"
frequency.each{|city, count|
	string += "#{city}, \"#{count}\"\n"
}
File.write("frequency-flow-year-phd-2005.csv", string)

histogram = Hash.new(0)
frequency.each{|city, count|
	histogram[count] += 1
}
histogram = histogram.sort_by {|_key, value| value}.to_h

string = "count, freq\n"
histogram.each{|count, freq|
	string += "#{count}, #{freq}\n"
}
File.write("frequency-flow-year-phd-histogram-2005.csv", string)

string = "count, freq\n"
flag = 0
histogram.each{|count, freq|
	flag += 1
	string += "#{flag}, #{freq}\n"
}
File.write("frequency-flow-year-phd-histogram-pos-2005.csv", string)