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

# require "geocoder"
# countries = ["montenegro", "united kingdom", "greece", "israel", "ecuador", "denmark", "madagascar", "china", "slovakia", "switzerland", "tunisia", "united states", "south korea", "armenia", "italy", "nicaragua", "croatia", "guinea bissau", "brazil", "senegal", "yemen", "iraq", "bolivia", "azerbaijan", "bulgaria", "palestinian territory", "lithuania", "democratic republic of the congo", "portugal", "dominican republic", "egypt", "taiwan", "romania", "indonesia", "liberia", "norway", "togo", "zambia", "panama", "uzbekistan", "martinique", "lebanon", "finland", "honduras", "japan", "nigeria", "chile", "belarus", "ivory coast", "slovenia", "south africa", "moldova", "estonia", "ukraine", "turkey", "paraguay", "serbia", "ethiopia", "australia", "kazakhstan", "cameroon", "tanzania", "sudan", "suriname", "angola", "bangladesh", "samoa", "peru", "monaco", "netherlands", "latvia", "trinidad and tobago", "niger", "morocco", "gabon", "mexico", "guyana", "sao tome and principe", "colombia", "bosnia and herzegovina", "poland", "philippines", "zimbabwe", "macao", "hong kong", "ghana", "costa rica", "syria", "belgium", "czech republic", "republic of the congo", "liechtenstein", "pakistan", "new zealand", "sweden", "uruguay", "kenya", "malaysia", "mozambique", "albania", "ireland", "cape verde", "georgia", "rwanda", "iran", "puerto rico", "burkina faso", "mauritius", "papua new guinea", "russia", "germany", "thailand", "india", "gibraltar", "hungary", "jamaica", "mauritania", "cuba", "east timor", "vietnam", "france", "spain", "argentina", "austria", "jordan", "canada", "guatemala", "belize", "guadeloupe", "macedonia", "algeria", "venezuela", "benin", "el salvador"]
# countries.each{|country|
# 	r = Geocoder.coordinates(country)
# 	puts "@latitude_region[\"#{country}\"] = {latitude: #{r[0]}, longitude: #{r[1]}}"
# }

@latitude_region = {}
@latitude_region["montenegro"] = {latitude: 42.708678, longitude: 19.37439}
@latitude_region["united kingdom"] = {latitude: 55.378051, longitude: -3.435973}
@latitude_region["greece"] = {latitude: 39.074208, longitude: 21.824312}
@latitude_region["israel"] = {latitude: 31.046051, longitude: 34.851612}
@latitude_region["ecuador"] = {latitude: -1.831239, longitude: -78.18340599999999}
@latitude_region["denmark"] = {latitude: 56.26392, longitude: 9.501785}
@latitude_region["madagascar"] = {latitude: -18.766947, longitude: 46.869107}
@latitude_region["china"] = {latitude: 35.86166, longitude: 104.195397}
@latitude_region["slovakia"] = {latitude: 48.669026, longitude: 19.699024}
@latitude_region["switzerland"] = {latitude: 46.818188, longitude: 8.227511999999999}
@latitude_region["tunisia"] = {latitude: 33.886917, longitude: 9.537499}
@latitude_region["united states"] = {latitude: 37.09024, longitude: -95.712891}
@latitude_region["south korea"] = {latitude: 35.907757, longitude: 127.766922}
@latitude_region["armenia"] = {latitude: 40.069099, longitude: 45.038189}
@latitude_region["italy"] = {latitude: 41.87194, longitude: 12.56738}
@latitude_region["nicaragua"] = {latitude: 12.865416, longitude: -85.207229}
@latitude_region["croatia"] = {latitude: 45.1, longitude: 15.2}
@latitude_region["guinea bissau"] = {latitude: 11.803749, longitude: -15.180413}
@latitude_region["brazil"] = {latitude: -14.235004, longitude: -51.92528}
@latitude_region["senegal"] = {latitude: 14.497401, longitude: -14.452362}
@latitude_region["yemen"] = {latitude: 15.552727, longitude: 48.516388}
@latitude_region["iraq"] = {latitude: 33.223191, longitude: 43.679291}
@latitude_region["bolivia"] = {latitude: -16.290154, longitude: -63.58865299999999}
@latitude_region["azerbaijan"] = {latitude: 40.143105, longitude: 47.576927}
@latitude_region["bulgaria"] = {latitude: 42.733883, longitude: 25.48583}
@latitude_region["palestinian territory"] = {latitude: 31.9465703, longitude: 35.3027226}
@latitude_region["lithuania"] = {latitude: 55.169438, longitude: 23.881275}
@latitude_region["democratic republic of the congo"] = {latitude: -4.038333, longitude: 21.758664}
@latitude_region["portugal"] = {latitude: 39.39987199999999, longitude: -8.224454}
@latitude_region["dominican republic"] = {latitude: 18.735693, longitude: -70.162651}
@latitude_region["egypt"] = {latitude: 26.820553, longitude: 30.802498}
@latitude_region["taiwan"] = {latitude: 23.69781, longitude: 120.960515}
@latitude_region["romania"] = {latitude: 45.943161, longitude: 24.96676}
@latitude_region["indonesia"] = {latitude: -0.789275, longitude: 113.921327}
@latitude_region["liberia"] = {latitude: 6.428055, longitude: -9.429499000000002}
@latitude_region["norway"] = {latitude: 60.47202399999999, longitude: 8.468945999999999}
@latitude_region["togo"] = {latitude: 8.619543, longitude: 0.824782}
@latitude_region["zambia"] = {latitude: -13.133897, longitude: 27.849332}
@latitude_region["panama"] = {latitude: 8.537981, longitude: -80.782127}
@latitude_region["uzbekistan"] = {latitude: 41.377491, longitude: 64.585262}
@latitude_region["martinique"] = {latitude: 14.641528, longitude: -61.024174}
@latitude_region["lebanon"] = {latitude: 33.854721, longitude: 35.862285}
@latitude_region["finland"] = {latitude: 61.92410999999999, longitude: 25.748151}
@latitude_region["honduras"] = {latitude: 15.199999, longitude: -86.241905}
@latitude_region["japan"] = {latitude: 36.204824, longitude: 138.252924}
@latitude_region["nigeria"] = {latitude: 9.081999, longitude: 8.675277}
@latitude_region["chile"] = {latitude: -35.675147, longitude: -71.542969}
@latitude_region["belarus"] = {latitude: 53.709807, longitude: 27.953389}
@latitude_region["ivory coast"] = {latitude: 7.539988999999999, longitude: -5.547079999999999}
@latitude_region["slovenia"] = {latitude: 46.151241, longitude: 14.995463}
@latitude_region["south africa"] = {latitude: -30.559482, longitude: 22.937506}
@latitude_region["moldova"] = {latitude: 47.411631, longitude: 28.369885}
@latitude_region["estonia"] = {latitude: 58.595272, longitude: 25.013607}
@latitude_region["ukraine"] = {latitude: 48.379433, longitude: 31.16558}
@latitude_region["turkey"] = {latitude: 38.963745, longitude: 35.243322}
@latitude_region["paraguay"] = {latitude: -23.442503, longitude: -58.443832}
@latitude_region["serbia"] = {latitude: 44.016521, longitude: 21.005859}
@latitude_region["ethiopia"] = {latitude: 9.145000000000001, longitude: 40.489673}
@latitude_region["australia"] = {latitude: -25.274398, longitude: 133.775136}
@latitude_region["kazakhstan"] = {latitude: 48.019573, longitude: 66.923684}
@latitude_region["cameroon"] = {latitude: 7.369721999999999, longitude: 12.354722}
@latitude_region["tanzania"] = {latitude: -6.369028, longitude: 34.888822}
@latitude_region["sudan"] = {latitude: 12.862807, longitude: 30.217636}
@latitude_region["suriname"] = {latitude: 3.919305, longitude: -56.027783}
@latitude_region["angola"] = {latitude: -11.202692, longitude: 17.873887}
@latitude_region["bangladesh"] = {latitude: 23.684994, longitude: 90.356331}
@latitude_region["samoa"] = {latitude: -13.759029, longitude: -172.104629}
@latitude_region["peru"] = {latitude: -9.189967, longitude: -75.015152}
@latitude_region["monaco"] = {latitude: 43.73841760000001, longitude: 7.424615799999999}
@latitude_region["netherlands"] = {latitude: 52.132633, longitude: 5.291265999999999}
@latitude_region["latvia"] = {latitude: 56.879635, longitude: 24.603189}
@latitude_region["trinidad and tobago"] = {latitude: 10.691803, longitude: -61.222503}
@latitude_region["niger"] = {latitude: 17.607789, longitude: 8.081666}
@latitude_region["morocco"] = {latitude: 31.791702, longitude: -7.092619999999999}
@latitude_region["gabon"] = {latitude: -0.803689, longitude: 11.609444}
@latitude_region["mexico"] = {latitude: 23.634501, longitude: -102.552784}
@latitude_region["guyana"] = {latitude: 4.860416, longitude: -58.93018}
@latitude_region["sao tome and principe"] = {latitude: 0.18636, longitude: 6.613080999999999}
@latitude_region["colombia"] = {latitude: 4.570868, longitude: -74.297333}
@latitude_region["bosnia and herzegovina"] = {latitude: 43.915886, longitude: 17.679076}
@latitude_region["poland"] = {latitude: 51.919438, longitude: 19.145136}
@latitude_region["philippines"] = {latitude: 12.879721, longitude: 121.774017}
@latitude_region["zimbabwe"] = {latitude: -19.015438, longitude: 29.154857}
@latitude_region["macao"] = {latitude: 22.198745, longitude: 113.543873}
@latitude_region["hong kong"] = {latitude: 22.396428, longitude: 114.109497}
@latitude_region["ghana"] = {latitude: 7.946527, longitude: -1.023194}
@latitude_region["costa rica"] = {latitude: 9.748916999999999, longitude: -83.753428}
@latitude_region["syria"] = {latitude: 34.80207499999999, longitude: 38.996815}
@latitude_region["belgium"] = {latitude: 50.503887, longitude: 4.469936}
@latitude_region["czech republic"] = {latitude: 49.81749199999999, longitude: 15.472962}
@latitude_region["republic of the congo"] = {latitude: -0.228021, longitude: 15.827659}
@latitude_region["liechtenstein"] = {latitude: 47.166, longitude: 9.555373}
@latitude_region["pakistan"] = {latitude: 30.375321, longitude: 69.34511599999999}
@latitude_region["new zealand"] = {latitude: -40.900557, longitude: 174.885971}
@latitude_region["sweden"] = {latitude: 60.12816100000001, longitude: 18.643501}
@latitude_region["uruguay"] = {latitude: -32.522779, longitude: -55.765835}
@latitude_region["kenya"] = {latitude: -0.023559, longitude: 37.906193}
@latitude_region["malaysia"] = {latitude: 4.210484, longitude: 101.975766}
@latitude_region["mozambique"] = {latitude: -18.665695, longitude: 35.529562}
@latitude_region["albania"] = {latitude: 41.153332, longitude: 20.168331}
@latitude_region["ireland"] = {latitude: 53.41291, longitude: -8.24389}
@latitude_region["cape verde"] = {latitude: 15.120142, longitude: -23.6051721}
@latitude_region["georgia"] = {latitude: 32.1656221, longitude: -82.9000751}
@latitude_region["rwanda"] = {latitude: -1.940278, longitude: 29.873888}
@latitude_region["iran"] = {latitude: 32.427908, longitude: 53.688046}
@latitude_region["puerto rico"] = {latitude: 18.220833, longitude: -66.590149}
@latitude_region["burkina faso"] = {latitude: 12.238333, longitude: -1.561593}
@latitude_region["mauritius"] = {latitude: -20.348404, longitude: 57.55215200000001}
@latitude_region["papua new guinea"] = {latitude: -6.314992999999999, longitude: 143.95555}
@latitude_region["russia"] = {latitude: 61.52401, longitude: 105.318756}
@latitude_region["germany"] = {latitude: 51.165691, longitude: 10.451526}
@latitude_region["thailand"] = {latitude: 15.870032, longitude: 100.992541}
@latitude_region["india"] = {latitude: 20.593684, longitude: 78.96288}
@latitude_region["gibraltar"] = {latitude: 36.140751, longitude: -5.353585}
@latitude_region["hungary"] = {latitude: 47.162494, longitude: 19.503304}
@latitude_region["jamaica"] = {latitude: 18.109581, longitude: -77.297508}
@latitude_region["mauritania"] = {latitude: 21.00789, longitude: -10.940835}
@latitude_region["cuba"] = {latitude: 21.521757, longitude: -77.781167}
@latitude_region["east timor"] = {latitude: -8.874217, longitude: 125.727539}
@latitude_region["vietnam"] = {latitude: 14.058324, longitude: 108.277199}
@latitude_region["france"] = {latitude: 46.227638, longitude: 2.213749}
@latitude_region["spain"] = {latitude: 40.46366700000001, longitude: -3.74922}
@latitude_region["argentina"] = {latitude: -38.416097, longitude: -63.61667199999999}
@latitude_region["austria"] = {latitude: 47.516231, longitude: 14.550072}
@latitude_region["jordan"] = {latitude: 30.585164, longitude: 36.238414}
@latitude_region["canada"] = {latitude: 56.130366, longitude: -106.346771}
@latitude_region["guatemala"] = {latitude: 15.783471, longitude: -90.23075899999999}
@latitude_region["belize"] = {latitude: 17.189877, longitude: -88.49765}
@latitude_region["guadeloupe"] = {latitude: 16.265, longitude: -61.55099999999999}
@latitude_region["macedonia"] = {latitude: 41.608635, longitude: 21.745275}
@latitude_region["algeria"] = {latitude: 28.033886, longitude: 1.659626}
@latitude_region["venezuela"] = {latitude: 6.42375, longitude: -66.58973}
@latitude_region["benin"] = {latitude: 9.30769, longitude: 2.315834}
@latitude_region["el salvador"] = {latitude: 13.794185, longitude: -88.89653}
def latitude(country)
	@latitude_region[country]
end

# @latitude_region.each{|index, pos|
# 	puts "open http://www.google.com/maps/place/#{pos[:latitude]},#{pos[:longitude]}"
# }

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
	country = latitude(loc[12]).to_s
	ids16[id16] ||= {}
	ids16[id16][kind] ||= [] 
	ids16[id16][kind] << loc 
	if places[country].nil?
		countNode += 1
		places[country] = {id: countNode, country: loc[12], latitude: loc[14], longitude: loc[15]} 
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

	id = latitude(source[12]).to_s+"-"+latitude(target[12]).to_s+"-"+kind
	
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
	next if edge[:source][12] == edge[:target][12]
	source = edge[:source]
	source_kind = source[2]
	source = places[latitude(source[12]).to_s][:id]
	target = edge[:target]
	target_kind = target[2]
	target = places[latitude(target[12]).to_s][:id]
	
	kind = ""
	if source_kind == "birth"
		kind = "birth"
	elsif target_kind == "work"
		kind = "work"
	else
		kind = "degree"
	end
	
	countEdge += 1
	network << [source, target, kind, "Directed", countEdge, nil, edge[:weight]]
}

csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["Id", "Label", "Modularity Class", "Country", "Latitude", "Longitude"]
	places.each{|index,place|
		# csv << [place[:id],place[:country],nil,place[:country],place[:latitude],place[:longitude]]
		csv << [place[:id],place[:country],nil,place[:country],latitude(place[:country])[:latitude],latitude(place[:country])[:longitude]]
	}
end
File.write("data/nodes-flow-country.csv", csv_string)


csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["Source", "Target","Kind","Type", "Id", "Label", "Weight"]
	network.each{|edge|
		csv << edge
	}
end
File.write("data/edges-flow-country.csv", csv_string)

puts "fim"
