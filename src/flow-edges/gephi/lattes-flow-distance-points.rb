require 'byebug'
require 'progress_bar'

nodes_file = File.read("data/nodes-flow-instituition.csv")
nodes_row = nodes_file.split("\n")
nodes = {}
nodes_row[1..-1].each{|node|
	node = node.split(",")
	nodes[node[0]] = [node[1],node[-2],node[-1]]
}

nodes_file = File.read("data/nodes-flow-city.csv")
nodes_row = nodes_file.split("\n")
cities = {}
nodes_row[1..-1].each{|node|
	node = node.split(",")
	cities["#{node[-2]},#{node[-1]}"] = node[-3]
}

nodes.each{|index, node|
	nodes[index] << cities["#{node[1]},#{node[2]}"]
}

edges_file = File.read("data/edges-flow-instituition-degree-distance.csv")
edges_row = edges_file.split("\n")
bar = ProgressBar.new(edges_row.size)

result = {}
counters = Hash.new(0)

edges_row[1..-1].each{|row|
	bar.increment!
	row_splited = row.split(",")
	distance = row_splited[-1].to_i
	# distance = row_splited[-1].to_f
	count = row_splited[-2].to_i
	node_id = row_splited[1]
	if "brazil" != nodes[node_id][-1]
		result[node_id] ||= []
		result[node_id] << [count, distance]
		counters[node_id] += count
	end
}
# byebug
counters = counters.sort_by{|k, v| v}.reverse.to_h
flag = 0
bar = ProgressBar.new(counters.size)
content = []
counters.each{|node_id, total|
	bar.increment!
	flag += 1
	result[node_id].each{|values|
		content << [flag, values[0], values[1]]
	}
}

# content = content.sort_by {|e| [e[1], e[3], e[2]]}
# file = "node,distance"
file = "node,size,distance"
bar = ProgressBar.new(content.size)
content.each{|row|
# content[0..1000].each{|row|
	bar.increment!
	break if row[0] == 51
	# (0..row[1]).each{
	# 	file += "\n#{row[0]},#{row[-1]}"
	# }
	file += "\n#{row.join(',')}"
}

File.write("data/edges-flow-instituition-degree-distance-point.csv", file)
file.gsub!(",", "\";\"")
file.gsub!("\n", "\"\n\"")
file = "\"#{file}\""
file.gsub!(".",",")
File.write("data/edges-flow-instituition-degree-distance-point2.csv", file)