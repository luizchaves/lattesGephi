require 'csv'
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
# locations = CSV.read("../../../data/locationslatlon2.csv", col_sep: ';')
locations.shift
bar = ProgressBar.new(locations.size)
puts
countNode = 0
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
		places[latlon] = {id: countNode, idRecord: loc[0], id16: id16, city: loc[9], state: loc[10], country: loc[12], latitude: loc[14], longitude: loc[15]} 
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

network = {}
countEdge = 0 
bar = ProgressBar.new(edges.size)
puts
edges.each{|edge|
	bar.increment!
	countEdge += 1

	source = edge[:source]
	target = edge[:target]

	# next if target[2] != "doutorado"

	kind = ""
	if source[2] == "birth"
		kind = "birth"
	elsif target[2] == "work"
		kind = "work"
	else
		kind = "degree"
	end

	source_id = edge[:source][14]+edge[:source][15]
	target_id = edge[:target][14]+edge[:target][15]

	source = places[source_id][:id]
	target = places[target_id][:id]

	destination = edge[:target][9]
	from = edge[:source][9]

	toCountry = edge[:target][12]
	fromCountry = edge[:source][12]

	distance = geo_distance(edge[:source][14].to_f, edge[:source][15].to_f, edge[:target][14].to_f, edge[:target][15].to_f)
	byebug
	
	# start_year = edge[:target][6]
	end_year = edge[:target][7]
	year = nil
	if !end_year.nil?
		year = end_year.to_i
	# elsif end_year.nil? and !start_year.nil?
	# 	year = end_year.to_i+2
	else	
		next
	end
	
	# network << [places[latlon_source][:id], places[latlon_target][:id], kind, edge[:source][2], edge[:target][2], "Directed", countEdge, nil, distance, start_year, end_year, year, edge[:source][1]]
	id = "#{source}-#{target}-#{kind}-#{year}"

	if network[id].nil?
		network[id] = [source, target, kind, "Directed", countEdge, nil, 1, from, destination, year, distance, fromCountry, toCountry]
	else
		network[id][6] += 1
	end
}

csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["Source", "Target","Kind","Type", "Id", "Label", "Weight", "From", "Destination", "year", "Distance", "fromCountry", "toCountry"]
	network.each{|id, edge|
		csv << edge
	}
end
# File.write("data/edges-flow-city-distance-year.csv", csv_string)
# File.write("data/edges-flow-city-distance-year-all.csv", csv_string)
File.write("data/edges-flow-city-distance-year-country-all.csv", csv_string)

puts "fim"
