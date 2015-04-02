nodes = File.read("flow/gephi-data/nodes-flow.csv").split("\n")
edges = File.read("flow/gephi-data/edges-flow.csv").split("\n")

nodes_hash = {}
table = nodes.split("\n")
table.each{|row|
	temp = row.split(",")
	nodes_hash[temp[0]] = row
}

sum = 0
table = edges.split("\n")
table.each{|row|
	row = row.split(",")
	if nodes_hash[row[1]].split(",")[7] == "brazil" and nodes_hash[row[0]].split(",")[7] == "brazil"
		sum += row.last.to_i
	end
}
puts sum
