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
distances = Hash.new(0)
distances_weigthed = Hash.new(0)
flow_weighted = Hash.new(0)
flow = Hash.new(0)

edges_row[1..-1].each{|row|
	bar.increment!
	row_splited = row.split(",")
	distance = row_splited[-1]
	count = row_splited[-2]
	node_id = row_splited[1]
	flow_weighted[node_id] += count.to_i
	flow[node_id] += 1
	distances[node_id] += distance.to_f
	distances_weigthed[node_id] += distance.to_f*count.to_i
}
# byebug
result = []
distances.each{|node_id, distance|
	# byebug
	if "brazil" != nodes[node_id][-1]
		# result << [node_id,nodes[node_id][0],nodes[node_id][-1],flow_weighted[node_id],flow[node_id],distance,distance/flow[node_id],distances_weigthed[node_id],distances_weigthed[node_id]/flow_weighted[node_id]]
		result << [node_id,nodes[node_id][0],nodes[node_id][-1],flow_weighted[node_id],flow[node_id],distance.to_i,distance/flow[node_id].to_i,distances_weigthed[node_id].to_i,distances_weigthed[node_id]/flow_weighted[node_id].to_i]
		# result << [node_id,nodes[node_id][0],nodes[node_id][-1],flow_weighted[node_id],flow[node_id],Math.log(distance),Math.log(distance/flow[node_id]),Math.log(distances_weigthed[node_id]),Math.log(distances_weigthed[node_id]/flow_weighted[node_id])]
	end
}
result = result.sort_by {|e| [e[3], e[4], e[2], e[5], e[6], e[7], e[8], e[0], e[1]]}

content = "id,name,country,flow_weighted,flow,distance,avg,distances_weigthed,avg"
result.each{|row|
	content += "\n"+row.join(",")
}

File.write("data/edges-flow-instituition-degree-distance-calc.csv", content)
content.gsub!(",", "\";\"")
content.gsub!("\n", "\"\n\"")
content = "\"#{content}\""
content.gsub!(".",",")
File.write("data/edges-flow-instituition-degree-distance-calc2.csv", content)