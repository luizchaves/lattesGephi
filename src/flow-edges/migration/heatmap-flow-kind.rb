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

kind = "country"
# kind = "region"
# kind = "state"
# kind = "city"
# kind = "instituition"

scale = ""
# scale = "-log"
# scale = "-sqrt"

# flow_name = "#{kind}-work#{scale}"
# flow_name = "#{kind}-birth#{scale}"
flow_name = "#{kind}-degree#{scale}"
# flow_name = "#{kind}-all#{scale}"

nodes_file = File.read("../gephi/data/nodes-flow-#{kind}.csv")
edges_file = File.read("../gephi/data/edges-flow-#{flow_name}.csv")

nodes = {}
nodes_file.split("\n")[1..-1].each{|row|
	row = row.split(",")
	nodes[row[0]] = row[1]
}

heat_map = {}
(1..nodes.size).each{|x|
	heat_map[x] = {}
	(1..nodes.size).each{|y|
		heat_map[x][y] = 0
	}
}

edges_file.split("\n")[1..-1].each{|row|
	row = row.split(",")
	x = row[0].to_i
	y = row[1].to_i
	heat_map[x][y] = row[-1].to_i
}

result = []
result << "#{kind},#{nodes.values.join(',')}"
heat_map.each{|i, x|
	result << "#{nodes[i.to_s]},#{x.values.join(',')}"
}

File.write("heatmap-flow-#{flow_name}.csv", result.join("\n"))
