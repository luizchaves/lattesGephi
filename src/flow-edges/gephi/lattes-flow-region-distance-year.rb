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

@states_region = {}
@states_region["acre"] = "norte"
@states_region["roraima"] = "norte"
@states_region["rondonia"] = "norte"
@states_region["amapa"] = "norte"
@states_region["amazonas"] = "norte"
@states_region["para"] = "norte"
@states_region["tocantins"] = "norte"
@states_region["alagoas"] = "nordeste"
@states_region["bahia"] = "nordeste"
@states_region["ceara"] = "nordeste"
@states_region["maranhao"] = "nordeste"
@states_region["paraiba"] = "nordeste"
@states_region["pernambuco"] = "nordeste"
@states_region["rio grande do norte"] = "nordeste"
@states_region["sergipe"] = "nordeste"
@states_region["piaui"] = "nordeste"
@states_region["federal district"] = "centro-oeste"
@states_region["goias"] = "centro-oeste"
@states_region["mato grosso"] = "centro-oeste"
@states_region["mato grosso do sul"] = "centro-oeste"
@states_region["espirito santo"] = "sudeste"
@states_region["minas gerais"] = "sudeste"
@states_region["rio de janeiro"] = "sudeste"
@states_region["sao paulo"] = "sudeste"
@states_region["parana"] = "sul"
@states_region["rio grande do sul"] = "sul"
@states_region["santa catarina"] = "sul"

@latitude_region = {}
@latitude_region["norte"] = {latitude: 3.129167, longitude: -60.021389}
@latitude_region["nordeste"] = {latitude: -12.966667, longitude: -38.516667}
@latitude_region["centro-oeste"] = {latitude: -15.779722, longitude: -47.930556}
@latitude_region["sudeste"] = {latitude: -23.55, longitude: -46.633333}
@latitude_region["sul"] = {latitude: -25.433333, longitude: -49.266667}

def region(state)
	@states_region[state]
end

def latitude(region)
	@latitude_region[region]
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
	next if loc[12] != "brazil"
	id16 = loc[1]
	kind = loc[2]
	id = region(loc[10]) # region

	mod_class = if kind == "birth"
		"birth"
	else
		"instituition"
	end
	ids16[id16] ||= {}
	ids16[id16][kind] ||= [] 
	ids16[id16][kind] << loc 
	if places[id].nil?
		countNode += 1
		places[id] = {id: countNode, place: loc[4], class: mod_class,city: loc[9], state: loc[10], region: region(loc[10]), country: loc[12], latitude: latitude(region(loc[10]))[:latitude], longitude: latitude(region(loc[10]))[:longitude]} 
	end
}
# byebug

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

# byebug
edges_clean = {}
network = {}
countEdge = 0 
bar = ProgressBar.new(edges.size)
puts
edges.each{|edge|
	bar.increment!
	countEdge += 1

	source = edge[:source]
	target = edge[:target]
	
	next if target[2] != "doutorado"
	
	kind = ""
	if source[2] == "birth"
		kind = "birth"
	elsif target[2] == "work"
		kind = "work"
	else
		kind = "degree"
	end

	destination = region(edge[:target][10])
	from = region(edge[:source][10])

	start_year = edge[:target][6]
	end_year = edge[:target][7]
	year = nil
	if !end_year.nil?
		year = end_year.to_i
	elsif end_year.nil? and !start_year.nil?
		year = end_year.to_i+2	
	end

	source = edge[:source]
	source_kind = source[2]
	id = region(source[10])
	source = places[id][:id]

	target = edge[:target]
	target_kind = target[2]
	id = region(target[10])
	target = places[id][:id]
	
	# id = region(source[10])+"-"+region(target[10])+" "+kind
	id = "#{source}-#{target}-#{kind}-#{year}"

	if network[id].nil?
		network[id] = [source, target, kind, "Directed", countEdge, nil, 1, from, destination, year]
	else
		network[id][6] += 1
	end
}

csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["Source", "Target","Kind","Type", "Id", "Label", "Weight", "From", "Destination", "year"]
	network.each{|id, edge|
		csv << edge
	}
end
File.write("data/edges-flow-region-distance-year.csv", csv_string)

puts "fim"
