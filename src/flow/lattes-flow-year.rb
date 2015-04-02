require 'csv'
require 'byebug'
require 'progress_bar'

# SELECT kind, place, place_ascii, place_abbr, start_year, end_year, 
#        city, city_ascii, state, country, country_ascii, country_abbr, 
#        latitude, longitude
#   FROM locationslatlon where kind != 'birth' and kind != 'work' and start_year is null and end_year is null order by kind limit 1000;
# degrees_empty = ["doutorado", "ensino-medio", "especializacao", "graduacao", "livre-docencia", "mestrado", "pos-doutorado"]

# locationslatlon_id

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
locations = CSV.read("locationslatlon.csv", col_sep: ';')
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

network = []
countEdge = 0 
bar = ProgressBar.new(edges.size)
puts
edges.each{|edge|
	bar.increment!
	source_kind = edge[:source][2]
	target_kind = edge[:target][2]

	kind = ""
	if source_kind == "birth"
		kind = "birth"
	elsif target_kind == "work"
		kind = "work"
	else
		kind = "degree"
	end

	distance = geo_distance(edge[:source][14].to_f, edge[:source][15].to_f, edge[:target][14].to_f, edge[:target][15].to_f)
	
	start_year = edge[:source][6]
	end_year = edge[:source][7]
	if !start_year.nil? and !end_year.nil?
		start_year = start_year.to_i
		end_year = end_year.to_i
	elsif start_year.nil?
		start_year = end_year.to_i
		end_year = end_year.to_i
	elsif end_year.nil?
		start_year = start_year.to_i
		end_year = start_year.to_i
	end
	year = start_year.nil? ? nil: (start_year+end_year)/2
	
	countEdge += 1
	
	latlon_source = edge[:source][14].to_s+edge[:source][15].to_s
	latlon_target = edge[:target][14].to_s+edge[:target][15].to_s

	# Source,Target, Kind, Kind_source, Kind_target, Type, Id, Label, Weight, Start Year, End Year, Year, Id16
	network << [places[latlon_source][:id], places[latlon_target][:id], kind, edge[:source][2], edge[:target][2], "Directed", countEdge, nil, distance, start_year, end_year, year, edge[:source][1]]
}

csv_string = CSV.generate(:col_sep => ",") do |csv|
	# Id,Label,Modularity Class
	csv << ["Id", "Label", "Modularity Class", "City", "State", "Country", "Latitude", "Longitude"]
	places.each{|index,place|
		csv << [place[:id],"#{place[:city]},#{place[:state]},#{place[:country]}",nil,place[:city],place[:state],place[:country],place[:latitude],place[:longitude]]
	}
end
File.write("nodes-flow-year.csv", csv_string)

csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["Source", "Target","Kind", "Kind_source", "Kind_target", "Type", "Id", "Label", "Weight", "Start Year", "End Year", "Year", "Id16"]
	network.each{|edge|
		csv << edge
	}
end
File.write("edges-flow-year2.csv", csv_string)

puts "fim"
