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

@latitude_region = {}
@latitude_region["acre"] = {latitude: -9.11, longitude: -70.52}
@latitude_region["roraima"] = {latitude: 2.05, longitude: -61.4}
@latitude_region["rondonia"] = {latitude: -10.9, longitude: -62.76}
@latitude_region["amapa"] = {latitude: 1, longitude: -52}
@latitude_region["amazonas"] = {latitude: -5, longitude: -63}
@latitude_region["para"] = {latitude: -5.666667, longitude: -52.733333}
@latitude_region["tocantins"] = {latitude: -10.183333, longitude: -48.333333}
@latitude_region["alagoas"] = {latitude: -9.57, longitude: -36.55}
@latitude_region["bahia"] = {latitude: -12.52, longitude: -41.69}
@latitude_region["ceara"] = {latitude: -5.08, longitude: -39.65}
@latitude_region["maranhao"] = {latitude: -6.183333, longitude: -45.616667}
@latitude_region["paraiba"] = {latitude: -7.166667, longitude: -36.833333}
@latitude_region["pernambuco"] = {latitude: -8.34, longitude: -37.81}
@latitude_region["rio grande do norte"] = {latitude: -5.74, longitude: -36.55}
@latitude_region["sergipe"] = {latitude: -10.59, longitude: -37.38}
@latitude_region["piaui"] = {latitude: -8.233333, longitude: -43.1}
@latitude_region["federal district"] = {latitude: -15.795, longitude: -47.757778}
@latitude_region["goias"] = {latitude: -15.933333, longitude: -50.133333}
@latitude_region["mato grosso"] = {latitude: -15.566667, longitude: -56.066667}
@latitude_region["mato grosso do sul"] = {latitude: -20.442778, longitude: -54.645833}
@latitude_region["espirito santo"] = {latitude: -20.318889, longitude: -40.337778}
@latitude_region["minas gerais"] = {latitude: -19.816667, longitude: -43.95}
@latitude_region["rio de janeiro"] = {latitude: -22.9, longitude: -43.2}
@latitude_region["sao paulo"] = {latitude: -23.533333, longitude: -46.633333}
@latitude_region["parana"] = {latitude: -24, longitude: -51}
@latitude_region["rio grande do sul"] = {latitude: -30, longitude: -53}
@latitude_region["santa catarina"] = {latitude: -27.25, longitude: -50.333333}


def latitude(state)
	@latitude_region[state]
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
	id = loc[10] #state

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
		places[id] = {id: countNode, place: loc[4], class: mod_class,city: loc[9], state: loc[10], country: loc[12], latitude: latitude(loc[10])[:latitude], longitude: latitude(loc[10])[:longitude]} 
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

	destination = edge[:target][10]
	from = edge[:source][10]

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
	id = source[10]
	source = places[id][:id]

	target = edge[:target]
	target_kind = target[2]
	id = target[10]
	target = places[id][:id]

	# id = source[10]+"-"+target[10]+"-"+kind
	id = "#{source}-#{target}-#{kind}-#{year}"

	# network << [source, target, kind, "Directed", countEdge, nil, edge[:weight]]
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
File.write("data/edges-flow-state-distance-year.csv", csv_string)

puts "fim"
