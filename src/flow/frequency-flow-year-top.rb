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

top_cities = [
	"brasilia - federal district - brazil",
	"guarulhos - sao paulo - brazil",
	"recife - pernambuco - brazil",
	"curitiba - parana - brazil",
	"florianopolis - santa catarina - brazil",
	"belo horizonte - minas gerais - brazil",
	"porto alegre - rio grande do sul - brazil",
	"bauru - sao paulo - brazil",
	"campinas - sao paulo - brazil",
	"rio de janeiro - rio de janeiro - brazil",
	"sao paulo - sao paulo - brazil"
]

nodes = {}
nodes_file.split("\n").each{|row|
	row = row.split(",")
	city = row[1..3].join(' - ').gsub("\"", "")
	nodes[row[0]] = city if top_cities.include? city
}

edges = []
edges_file.split("\n").each{|row|
	row = row.split(",")
	edges << row if !nodes[row[1]].nil? and row[4] == 'doutorado'
}

cities = {}
top_cities.each{|city| 
	cities[city] ||= {}
	(1930..2014).each{|year|
		cities[city][year] = 0
	}
}

edges.each{|edge|
	# print nodes[edge[1]]
	# print edge[-3].to_i
	# puts
	year = edge[-3].to_i
	cities[nodes[edge[1]]][year] += 1 if year >= 1930 and year <= 2014
}

string = "cities, #{(1930..2014).to_a.join(', ')}\n"
cities.each{|city, years|
	string += "#{city}"
	years.each{|year, value|
		string += ", #{value}"
	}
	string += "\n"
}
File.write("frequency-flow-year-phd-top-city.csv", string)
