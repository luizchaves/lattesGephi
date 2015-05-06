require 'byebug'
require 'progress_bar'

def geo_distance(lat1, long1, lat2, long2)
	dtor = Math::PI/180
  r = 6378.14*1000
 
  rlat1 = lat1 * dtor 
  rlong1 = long1 * dtor 
  rlat2 = lat2 * dtor 
  rlong2 = long2 * dtor 
 
  dlon = rlong1 - rlong2
  dlat = rlat1 - rlat2
 
  a = Math::sin(dlat/2) ** 2 + Math::cos(rlat1) * Math::cos(rlat2) * Math::sin(dlon/2) ** 2
  c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
  d = r * c
 
  return d
end

nodes_file = File.read("data/nodes-flow-instituition.csv")
nodes_row = nodes_file.split("\n")
nodes = {}
nodes_row[1..-1].each{|node|
	node = node.split(",")
	nodes[node[0]] = [node[-2],node[-1],node[-3],node[1]]
}

edges_file = File.read("data/edges-flow-instituition-degree.csv")
edges_row = edges_file.split("\n")

result = edges_row[0]+",distance"
bar = ProgressBar.new(edges_row.size)

edges_row[1..-1].each{|row|
	bar.increment!
  row_splited = row.split(",")
  source = row_splited[0]
  target = row_splited[1]
  # byebug
  # if nodes[target][2] == "brazil"
  # if nodes[target][3] == "university of london"
  # if nodes[target][3] == "university of florida"
  # if nodes[target][3] == "university of tokyo"
  # if nodes[target][3] == "university of london" || nodes[source][3] == "university of london"
  if nodes[source][2] == "brazil" and nodes[target][2] == "brazil"
	 result += "\n#{row},#{geo_distance(nodes[source][0].to_f,nodes[source][1].to_f,nodes[target][0].to_f,nodes[target][1].to_f)}"
  end
}

# File.write("data/edges-flow-instituition-degree-distance.csv", result)
# File.write("data/edges-flow-instituition-degree-distance-br.csv", result)
# File.write("data/edges-flow-instituition-degree-distance-london.csv", result)
# File.write("data/edges-flow-instituition-degree-distance-florida.csv", result)
# File.write("data/edges-flow-instituition-degree-distance-tokyo.csv", result)
File.write("data/edges-flow-instituition-degree-distance-br.csv", result)
