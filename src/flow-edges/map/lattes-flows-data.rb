require 'csv'
require 'byebug'
require 'progress_bar'

# kind_data = "country"
kind_data = "instituition"

# edges = "/Users/lucachaves/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-#{kind_data}/data-code/edges-flow-#{kind_data}-distance-years-code.csv"
edges = "/Users/lucachaves/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-#{kind_data}/data-code/edges-flow-#{kind_data}-distance-years-code-br.csv"
edges = File.read(edges).split("\n")

nodes = "/Users/lucachaves/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/nodes-flow-#{kind_data}.csv"
nodes = File.read(nodes).split("\n")

countries = {}
flows = []
year = 2013

year_column = {}
year_column[2013] = -2
year_column["all"] = -1

nodes[1..-1].each{|row|
	row = row.split(",")
	# id, lat, long
	countries[row[0]] = [row[-2],row[-1]]
}

# byebug
edges[1..-1].each_with_index{|row,index|
	row = row.split(",")
	# source, target, year
	flows << [index]+countries[row[0]]+countries[row[1]]+[row[year_column[year]]]
}

result = CSV.generate(:col_sep => ",") do |csv|  
	csv << ["id", "oX", "oY","dX","dY","trips"]
	flows.each{|row|
		csv << row
	}
end

# File.write("lattes-flows-#{kind_data}-#{year}.csv", result)
File.write("lattes-flows-#{kind_data}-#{year}-br.csv", result)
