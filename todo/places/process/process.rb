require 'sequel'
require 'progress_bar'
require 'byebug'
require 'csv'
require 'geocoder'


def clean_text(text)
	# TODO remover caracteres espciais ($;-&)
	# remover de, da(s), do(s) 
	text.gsub!(/[\~\`\'\´\"\.\-\/\,\(\)]/, " ")
	text.gsub!(/\s+/, " ")
	text.gsub!(/^\s/, "")
	text.gsub!(/\s$/, "")
	text
end

def process_downcase(text)
	text = text.tr(
		"ÀÁÂÃÄÅĀĂĄÇĆĈĊČÐĎĐÈÉÊËĒĔĖĘĚĜĞĠĢĤĦÌÍÎÏĨĪĬĮİĴĵĶĹĻĽĿŁÑŃŅŇŊÒÓÔÕÖØŌŎŐŔŖŘŚŜŞŠŢŤŦÙÚÛÜŨŪŬŮŰŲŴÝŶŸŹŻŽ",
		"àáâãäåāăąçćĉċčðďđèéêëēĕėęěĝğġģĥħìíîïĩīĭįıJjķĺļľŀłñńņňŋòóôõöøōŏőŕŗřśŝşšţťŧùúûüũūŭůűųŵýŷYźżž"
	)
	text.downcase
end

def process_ascii(text)
	text = clean_text(text)
	text = text.tr(
		"ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
		"AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz"
	)
	text.downcase
end

def get_abbr(name)
	uni = CSV.read("sucupira2.csv", col_sep: ';')
	uni.each{|u|
		# byebug if u[1] == 'universidade de sao paulo'
		return u[2] if u[1] == name
	}
	nil
end

def get_city_by_place(name)
	r = Geocoder.search(name)
	return nil if r == [] or r.nil?
	data = r[0].data
	place = {}
	data["address_components"].each{|a|
		place[:city] = a["long_name"] if a["types"].include? "locality"
	}
	data["address_components"].each{|a|
		place[:country] = a["long_name"] if a["types"].include? "country"
	}
	place
end

def get_city_by_latlon(latitude, longitude)
	@location_dump[:cities].where(latitude: latitude, longitude: longitude).all[0]
end

def get_city(city)
	@location_dump[:cities].where(city_ascii: city).all
end

def get_city_by_country(city, country)
	country2 = @location_dump[:countries].where(name_ascii_pt: country).or(name_en: country).all[0]
	return nil if country2.nil?
	# byebug if country2.nil?
	@location_dump[:cities].where(city_ascii: city, country_ascii: country2[:name_en]).all
end

def get_position(city, country)
	return nil if city.nil? or city == ''
	result_city = get_city(city)
	if(result_city.size == 1)
		return result_city[0]
	end

	return nil if country.nil? or country == ''
	result_country = get_city_by_country(city, country)
	if(result_city.size > 1 and result_country.size == 1)
		return result_country[0]
	end

	nil
end

ip = "192.168.56.101"
@location_dump = Sequel.connect("postgres://postgres:postgres@#{ip}/latteslocationdumpdoutorado")
# result = @location_dump[:instituitions].all
# bar = ProgressBar.new(result.size)
# result.each{|i|
# 	next unless i[:city].nil? or i[:city] = ''
# 	bar.increment!
# 	p = @location_dump[:cities].where(latitude: i[:latitude], longitude: i[:longitude]).all
# 	if p != []
# 		# byebug
# 		p = p[0]
# 		city = (p[:city_ascii].nil?)? "" : p[:city_ascii]
# 		state = (p[:state].nil?)? "" : p[:state]
# 		country = (p[:country].nil?)? "" : p[:country]
# 		# puts "#{p[:city]} #{p[:state]} #{p[:country]}"
# 		@location_dump[:instituitions].where("id = ?", i[:id]).update(city: city, state: state, country: country)
# 		# @location_dump[:instituitions].where("id = ?", i[:id]).update(city: '', state: '', country: '')
# 	end
# }

# result.each{|i|
# 	bar.increment!
# 	if i[:abbr] == '' or i[:abbr].nil?
# 		abbr = get_abbr(i[:name_ascii])
# 		# byebug
# 		unless abbr.nil?
# 			@location_dump[:instituitions].where("id = ?", i[:id]).update(abbr: abbr)
# 		end
# 	end
# }

# uni = CSV.read("sucupira.csv", col_sep: ';')

# uni.each_with_index{|u,i|
# 	uni[i][2] = uni[i][1] 
# 	uni[i][1] = process_ascii(uni[i][0])
# }

# csv_string = CSV.generate(:col_sep => ";") do |csv|
# 	csv << ["name", "name_ascii", "abbr"]
# 	uni.each_with_index{|g, i|
# 		csv << g
# 	}
# end
# File.write("sucupira2.csv", csv_string)

# suc0 = CSV.read("sucupiraUniversities.csv", col_sep: ',')
# suc1 = CSV.read("sucupira2.csv", col_sep: ';')
# suc3 = File.read("sucupira3.txt").split("\n")

# results = []
# suc3.each{|uni|
# 	result = {}
# 	suc1.each{|s|
# 		if s[1] == uni
# 			result[:name] = s[0]
# 			result[:name_assi] = s[1]
# 			result[:abbr] = s[2]
# 		end
# 	}
# 	suc0.each{|s|
# 		if process_ascii(s[1]).include? uni
# 			result[:latitude] = s[4]
# 			result[:longitude] = s[5]
# 			break
# 		end
# 	}
# 	results << result
# }
# byebug

# csv_string = CSV.generate(:col_sep => ";") do |csv|
# 	csv << ["name", "name_ascii", "abbr", "latitude", "longitude"]
# 	results.each{|r|
# 		csv << r.values
# 	}
# end
# File.write("sucupira-result.csv", csv_string)

# uni = CSV.read("places5.csv", col_sep: ';')
# bar = ProgressBar.new(uni.size)
# uni.each_with_index{|u,i|
# 	bar.increment!
# 	# uni[i][2] = uni[i][1] 
# 	# uni[i][0] = process_downcase(uni[i][0])
# 	# uni[i][1] = process_ascii(uni[i][0])
# 	r = @location_dump[:instituitions].where(name_ascii: uni[i][1]).all
# 	unless r == [] or r.nil?
# 		uni[i] = [nil, nil, nil, nil, nil]
# 	else
# 		uni[i][3] = nil
# 		uni[i][4] = nil
# 	end
# }

# csv_string = CSV.generate(:col_sep => ";") do |csv|
# 	csv << ["name", "name_ascii", "abbr","latitude","longitude"]
# 	uni.each_with_index{|g, i|
# 		csv << g
# 	}
# end
# File.write("places4.csv", csv_string)

# uni = CSV.read("places5.csv", col_sep: ';')
# bar = ProgressBar.new(uni.size)
# uni.each_with_index{|u,i|
# 	bar.increment!
# 	result = get_city(uni[i][1])
# 	# byebug
# 	unless result == {} or result.nil?
# 		uni[i][3] = result[:city]
# 		uni[i][4] = result[:country]
# 	else
# 		uni[i][3] = nil
# 		uni[i][4] = nil
# 	end
# }

# csv_string = CSV.generate(:col_sep => ";") do |csv|
# 	csv << ["name", "name_ascii", "abbr","latitude","longitude"]
# 	uni.each_with_index{|g, i|
# 		csv << g
# 	}
# end
# File.write("places6.csv", csv_string)

uni = CSV.read("places9.csv", col_sep: ';')
uni.shift
bar = ProgressBar.new(uni.size)
uni.each_with_index{|u,i|
	bar.increment!
	
	# uni[i][2] = process_ascii(uni[i][2])
	# uni[i][3] = process_ascii(uni[i][3])

	result = get_position(uni[i][3], uni[i][5])
	unless result == [] or result.nil?
		uni[i][6] = result[:latitude]
		uni[i][7] = result[:longitude]
	end
}

csv_string = CSV.generate(:col_sep => ";") do |csv|
	csv << ["name", "name_ascii","abbr","city","state","country","latitude","longitude"]
	uni.each_with_index{|g, i|
		csv << g
	}
end
File.write("places10.csv", csv_string)



# uni = CSV.read("places7.csv", col_sep: ';')
# uni.shift
# bar = ProgressBar.new(uni.size)
# uni.each_with_index{|u,i|
# 	bar.increment!
	
# 	uni[i][6] = uni[i][5]
# 	uni[i][5] = uni[i][4]

# 	result = get_city_by_latlon(uni[i][5].to_f, uni[i][6].to_f)

# 	unless result == [] or result.nil?
# 		uni[i][2] = result[:city_ascii]
# 		uni[i][3] = result[:state_ascii]
# 		uni[i][4] = result[:country_ascii]
# 	end

# }
# # byebug
# csv_string = CSV.generate(:col_sep => ";") do |csv|
# 	csv << ["name", "name_ascii", "city","state","country","latitude","longitude"]
# 	uni.each_with_index{|g, i|
# 		csv << g
# 	}
# end
# File.write("places8.csv", csv_string)

# uni = CSV.read("places4.csv", col_sep: ';')
# uni.shift
# bar = ProgressBar.new(uni.size)
# uni.each_with_index{|u,i|
# 	bar.increment!
	
# 	next if uni[i][1].nil?
# 	uni[i][1] = process_ascii(uni[i][1])

# 	result = get_city_by_place(uni[i][1])
# 	unless result.nil? or result == {} or result[:city].nil?
# 		city = process_ascii(result[:city])
# 		country = process_ascii(result[:country])
# 		country = "brasil" if country == "brazil"
# 		result = get_position(city, country)
# 	end

# 	unless result == [] or result.nil?
# 		uni[i][3] = result[:city_ascii]
# 		uni[i][4] = result[:state_ascii]
# 		uni[i][5] = result[:country_ascii]
# 		uni[i][6] = result[:latitude]
# 		uni[i][7] = result[:longitude]
# 	end

# }
# # byebug
# csv_string = CSV.generate(:col_sep => ";") do |csv|
# 	csv << ["name", "name_ascii", "abbr", "city","state","country","latitude","longitude"]
# 	uni.each_with_index{|g, i|
# 		csv << g
# 	}
# end
# File.write("places9.csv", csv_string)


