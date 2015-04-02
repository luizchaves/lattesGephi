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
	next if kind == 'birth' or kind == 'work'
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
result = "id16, interval\n"
ids16flow.each{|id16, locations|
	bar.increment!
	if locations.size > 1
		start_year = []
		end_year = []

		locations.each{|location|
			start_year << if location[6].to_i == 0 and location[7].to_i != 0
				location[7].to_i
			elsif location[6].to_i != 0
				location[6].to_i
			elsif location[6].to_i == 0 and location[7].to_i == 0
				nil
			end

			end_year << if location[6].to_i == 0 and location[7].to_i != 0
				location[7].to_i
			elsif location[6].to_i != 0
				location[6].to_i
			elsif location[6].to_i == 0 and location[7].to_i == 0
				nil
			end
		}

		# puts id16
		# puts "#START #{start_year.join(', ')} #END #{end_year.join(', ')}"
		# puts "#{start_year.select{ |x| x.is_a?(Fixnum) }.sort.first} #{end_year.select{ |x| x.is_a?(Fixnum) }.sort.last}"
		# puts "#{end_year.select{ |x| x.is_a?(Fixnum) }.sort.last - start_year.select{ |x| x.is_a?(Fixnum) }.sort.first}"
		# byebug if id16 == "7717849671434712"
		start_year = start_year.select{|x| x.is_a?(Fixnum)}.sort.first
		end_year = end_year.select{|x| x.is_a?(Fixnum)}.sort.last

		next if end_year.nil? or start_year.nil?
		interval = end_year - start_year
		# puts interval
		# byebug
		result += "#{id16}, #{interval}\n"
	end
}
File.write("lattes-flow-interval.csv", result)

puts "fim"
