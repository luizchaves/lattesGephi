require 'csv'
require 'byebug'
require 'progress_bar'
require 'rinruby' 

kind_data = "city"

edges = "data-code/edges-flow-#{kind_data}-distance-years-code.csv"
# edges = "data-code/edges-flow-#{kind_data}-distance-years-code-br.csv"
edges = File.read(edges).split("\n")

nodes = "../nodes-flow-#{kind_data}.csv"
nodes = File.read(nodes).split("\n")

cities = {}
countries = {}
flows = []

year_column = {}
(1950..2013).each_with_index{|year,index|
	year_column[year] = -65+index
}
year_column["all"] = -1

# years = (2013..2013)
years = (1950..2013)
bar = ProgressBar.new(years.size)
years.each{|year|
	bar.increment!

	nodes[1..-1].each{|row|
		row = row.split(",")
		# id, lat, long
		cities[row[0]] = [row[-2],row[-1]]
		countries[row[0]] = row[-3]
	}

	# byebug
	flows = []
	edges[1..-1].each_with_index{|row,index|
		row = row.split(",")
		# source, target, year
		trips = row[year_column[year]]
		next if trips == "0"
		next if row[0] == row[1] #loops
		flows << [index]+cities[row[0]]+cities[row[1]]+[trips, countries[row[0]], countries[row[1]]]
	}

	result = ""
	result = CSV.generate(:col_sep => ",") do |csv|  
		csv << ["id","oX","oY","dX","dY","trips","cO","cD"]
		flows.each{|row|
			csv << row
		}
	end

	file_result = "data-latlon/lattes-flows-#{kind_data}-all-#{year}.csv"
	# file_result = "data-latlon/lattes-flows-#{kind_data}-#{year}-br.csv"
	File.write(file_result, result)
}
