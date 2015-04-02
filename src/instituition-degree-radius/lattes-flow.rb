require 'csv'
require 'byebug'
require 'progress_bar'

# SELECT kind, place, place_ascii, place_abbr, start_year, end_year, 
#        city, city_ascii, state, country, country_ascii, country_abbr, 
#        latitude, longitude
#   FROM locationslatlon where kind != 'birth' and kind != 'work' and start_year is null and end_year is null order by kind limit 1000;
# degrees_empty = ["doutorado", "ensino-medio", "especializacao", "graduacao", "livre-docencia", "mestrado", "pos-doutorado"]

# locationslatlon_id

def sort_degrees(degrees)
	list = {}
	degrees.each{|deg|
		start_year = deg[6]
		start_year = start_year.to_i unless start_year.nil?
		end_year = deg[7]
		end_year = end_year.to_i unless end_year.nil?

		index = 0
		if start_year.nil? and end_year.nil?
			index = 3000 
		elsif start_year.nil?
			index = end_year 
		elsif end_year.nil?
			index = start_year
		end

		list[index] = deg
	}
	Hash[list.sort].values
end

flow_degrees = [
	"birth",
	"ensino-fundamental",
	"ensino-medio",
	"curso-tecnico",
	"graduacao",
	"aperfeicoamento",
	"residencia",
	"especializacao",
	"mestrado",
	"mestrado-profissionalizante",
	"livre-docencia",
	"doutorado",
	"pos-doutorado",
	"work",
]

ids16 = {}
ids16_place = []
places = {}
puts "Iniciar"
locations = CSV.read("../flow/locationslatlon.csv", col_sep: ';')
locations.shift
bar = ProgressBar.new(locations.size)
puts
countNode = 0

place_value = "universidade de sao paulo"
# place_value = "universidade federal de pernambuco"
# place_value = "universidade federal da paraiba"

locations.each{|loc|
	if (loc[4] == place_value and loc[2] == "doutorado")
		ids16_place << loc[1]
	end
}
ids16_place = ids16_place.uniq

locations.each{|loc|
	bar.increment!
	id16 = loc[1]
	kind = loc[2]
	latlon = loc[14].to_s+loc[15].to_s
	ids16[id16] ||= {}
	ids16[id16][kind] ||= [] 
	ids16[id16][kind] << loc 
	if places[latlon].nil?
		countNode += 1
		places[latlon] = {id: countNode, city: loc[9], state: loc[10], country: loc[12], latitude: loc[14], longitude: loc[15]} 
	end
}

ids16flow = {}
bar = ProgressBar.new(ids16.size)
puts
ids16.each{|id16, degrees|
	bar.increment!
	ids16flow[id16] = []
	flow_degrees.each{|degree|
		unless degrees[degree].nil? 
			if degrees[degree].size == 1
				ids16flow[id16] << degrees[degree].first
			else
				sort_degrees(degrees[degree]).each{|deg|
					ids16flow[id16] << deg
				}
			end
		end
	}
}

edges = []
bar = ProgressBar.new(ids16flow.size)
puts
ids16flow.each{|id16, locations|
	bar.increment!
	if locations.size > 1
		source = nil
		locations.each{|location|
			target = location
			if (target[4] == place_value and target[2] == "doutorado" and !source.nil? and source[2] != "birth") 
				edges << {source: source, target: target} unless source.nil?
			end
			source = target
		}
	end
}

edges_clean = {}
bar = ProgressBar.new(edges.size)
puts
edges.each{|edge|
	bar.increment!
	source = edge[:source]
	target = edge[:target]
	id = source[14].to_s+source[15].to_s+target[14].to_s+target[15].to_s+target[2].to_s
	if edges_clean[id].nil?
		edges_clean[id] = edge 
		edges_clean[id][:weight] = 1
	else
		edges_clean[id][:weight] += 1
	end
}

network = []
countEdge = 0 
bar = ProgressBar.new(edges_clean.size)
puts
edges_clean.each{|index, edge|
	bar.increment!
	# byebug
	source = edge[:source]
	source_kind = source[2]
	source = places[source[14].to_s+source[15].to_s][:id]
	target = edge[:target]
	target_kind = target[2]
	target = places[target[14].to_s+target[15].to_s][:id]

	kind = ""
	if source_kind == "birth"
		kind = "birth"
	elsif target_kind == "work"
		kind = "work"
	else
		kind = "degree"
	end

	countEdge += 1
	# Source,Target,Type,Id,Label,Weight
	network << [source, target, kind, "Directed", countEdge, nil, edge[:weight]]
}

selected_nodes = []
network.each{|edge|
	selected_nodes << edge[0]
}
selected_nodes << network.last[1]

csv_string = CSV.generate(:col_sep => ",") do |csv|
	# Id,Label,Modularity Class
	csv << ["Id", "Label", "Modularity Class", "City", "State", "Country", "Latitude", "Longitude"]
	places.each{|index,place|
		if(selected_nodes.include? place[:id])
			csv << [place[:id],"#{place[:city]},#{place[:state]},#{place[:country]}",nil,place[:city],place[:state],place[:country],place[:latitude],place[:longitude]]
		end
	}
end
# File.write("nodes-flow-#{place_value}.csv", csv_string)
File.write("nodes-flow-#{place_value}-mestrado.csv", csv_string)

csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["Source", "Target","Kind","Type", "Id", "Label", "Weight"]
	network.each{|edge|
		csv << edge
	}
end
# File.write("edges-flow-#{place_value}.csv", csv_string)
File.write("edges-flow-#{place_value}-mestrado.csv", csv_string)

puts "fim"
