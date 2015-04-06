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
places = {}
puts "Iniciar"
locations = CSV.read("../../../data/locationslatlon.csv", col_sep: ';')
locations.shift
bar = ProgressBar.new(locations.size)
puts
countNode = 0
locations.each{|loc|
	bar.increment!
	id16 = loc[1]
	kind = loc[2]

	mod_class = if kind == "birth"
		"city"
	else
		"instituition"
	end

	place = if mod_class == "city"
		loc[9]
	else
		loc[4]
	end

	id = if mod_class == "city"
		loc[14]+loc[15]
	else
		loc[3]+loc[4]+loc[14]+loc[15]
	end

	ids16[id16] ||= {}
	ids16[id16][kind] ||= [] 
	ids16[id16][kind] << loc 
	if places[id].nil?
		countNode += 1
		places[id] = {id: countNode, place: place, class: mod_class,city: loc[9], state: loc[10], country: loc[12], latitude: loc[14], longitude: loc[15]} 
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
			edges << {source: source, target: target} unless source.nil?
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

	kind = ""
	if source[2] == "birth"
		kind = "birth"
	elsif target[2] == "work"
		kind = "work"
	else
		kind = "degree"
	end

	source_id = if kind == "birth"
		edge[:source][14]+edge[:source][15]
	else
		edge[:source][3]+edge[:source][4]+edge[:source][14]+edge[:source][15]
	end

	target_id = edge[:target][3]+edge[:target][4]+edge[:target][14]+edge[:target][15]

	id = source_id+"-"+target_id+"-"+kind
	
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
	countEdge += 1

	kind = ""
	if edge[:source][2] == "birth"
		kind = "birth"
	elsif edge[:target][2] == "work"
		kind = "work"
	else
		kind = "degree"
	end

	source_id = if kind == "birth"
		edge[:source][14]+edge[:source][15]
	else
		edge[:source][3]+edge[:source][4]+edge[:source][14]+edge[:source][15]
	end

	target_id = edge[:target][3]+edge[:target][4]+edge[:target][14]+edge[:target][15]

	source = places[source_id][:id]
	target = places[target_id][:id]

	network << [source, target, kind, "Directed", countEdge, nil, edge[:weight]]
}

csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["Id", "Label", "Modularity Class", "City", "State", "Country", "Latitude", "Longitude"]
	places.each{|index,place|
		csv << [place[:id],place[:place],place[:class],place[:city],place[:state],place[:country],place[:latitude],place[:longitude]]
	}
end
File.write("data/nodes-flow-instituition.csv", csv_string)

csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["Source", "Target","Kind","Type", "Id", "Label", "Weight"]
	network.each{|edge|
		csv << edge
	}
end
File.write("data/edges-flow-instituition.csv", csv_string)

puts "fim"
