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

nodes_file = File.read('nodes-flow.csv')
edges_file = File.read('edges-flow.csv')
countries_file = File.read('countries-continent.csv')

countries_cont = {}
countries_file.split("\n").each{|row|
	row = row.split(",")
	countries_cont[row[0]] = row[1]
}

edges = []
edges_file.split("\n").each{|row|
	row = row.split(",")
	edges << row
	#only degree
	#only last 10 year
	# edges << row if row[-2].to_i >= 2005 
}

nodes = {}
nodes_file.split("\n").each{|row|
	row = row.split(",")
	nodes[row[0]] = row[-3]
}

flow_nodes = []
edges[1..-1].each{|e|
	flow_nodes << e[0]
	flow_nodes << e[1]
}
flow_nodes = flow_nodes.uniq

countries = []
flow_nodes.each{|node_id|
	countries << nodes[node_id]
}
countries = countries.uniq

continents = []
countries.each{|country|
	continents << countries_cont[country]
}
continents = continents.uniq

heat_map = {}
continents.each{|continent_source|
	heat_map[continent_source] = {}
	continents.each{|continent_target|
		heat_map[continent_source][continent_target] = 0
	}
}

edges[1..-1].each{|e|
	country_source = nodes[e[0]]
	country_target = nodes[e[1]]
	heat_map[countries_cont[country_source]][countries_cont[country_target]] += 1
}

# heat_map.each{|x, value|
# 	value.each{|y, value|
# 		heat_map[x][y] = normalise(heat_map[x][y])
# 	}
# }

puts "continents, #{heat_map['europe'].keys.join(', ')}"
heat_map.each{|id, content|
	puts "#{id}, #{content.values.join(', ')}"
}