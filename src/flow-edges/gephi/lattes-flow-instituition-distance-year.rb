require 'csv'
require 'byebug'
require 'progress_bar'

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

network = {}
countEdge = 0 
bar = ProgressBar.new(edges.size)
puts
count_br = 0
edges.each{|edge|
	bar.increment!
	countEdge += 1

	source = edge[:source]
	target = edge[:target]

	count_br +=1 if target[12] == "brazil"
	next if target[2] != "doutorado"
	# next unless source[12] == "brazil" and target[12] == "brazil"

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

	source = places[source_id][:id]
	target = places[target_id][:id]

	destination = edge[:target][4]
	from = edge[:source][4]

	# distance = geo_distance(edge[:source][14].to_f,edge[:target][14].to_f,edge[:source][15].to_f,edge[:target][15].to_f)
	# id16 = edge[:source][1]
	# destination = if kind == "work"
	# 	edge[:target][4]
	# else
	# 	edge[:target][3]
	# end

	start_year = edge[:target][6]
	end_year = edge[:target][7]
	year = nil
	if !end_year.nil?
		year = end_year.to_i
	elsif end_year.nil? and !start_year.nil?
		year = end_year.to_i+2	
	end

	# network << [source, target, kind, "Directed", countEdge, nil, edge[:weight], destination, distance, id16, year]
	id = "#{source}-#{target}-#{kind}-#{year}"

	if network[id].nil?
		network[id] = [source, target, kind, "Directed", countEdge, nil, 1, from, destination, year]
	else
		network[id][6] += 1
	end
}

puts "#{count_br}/#{countEdge}"

csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["Source", "Target","Kind","Type", "Id", "Label", "Weight", "From", "Destination", "year"]
	network.each{|id, edge|
		csv << edge
	}
end
File.write("data/edges-flow-instituition-distance-year.csv", csv_string)
# File.write("data/edges-flow-instituition-distance-year-br.csv", csv_string)

puts "fim"
