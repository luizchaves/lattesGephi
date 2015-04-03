# SELECT DISTINCT nome, nome_ascii, uf, id_uf latitude, 
#        longitude
#   FROM munic;

require 'csv'
require 'byebug'
require 'progress_bar'

class Util
	@states = {
		"ac" => "acre",
		"al" => "alagoas",
		"ap" => "amapa",
		"am" => "amazonas",
		"ba" => "bahia",
		"ce" => "ceara",
		"df" => "federal district",
		"es" => "espirito Santo",
		"go" => "goias",
		"ma" => "maranhao",
		"mt" => "mato grosso",
		"ms" => "mato grosso do sul",
		"mg" => "minas gerais",
		"pa" => "para",
		"pb" => "paraiba",
		"pr" => "parana",
		"pe" => "pernambuco",
		"pi" => "piaui",
		"rj" => "rio de janeiro",
		"rn" => "rio grande do norte",
		"rs" => "rio grande do sul",
		"ro" => "rondonia",
		"rr" => "roraima",
		"sc" => "santa catarina",
		"sp" => "sao paulo",
		"se" => "sergipe",
		"to" => "tocantins"
	}

	class << self

		def process_downcase(text)
			return nil if text.nil?
			text = text.tr(
				"ÀÁÂÃÄÅĀĂĄÇĆĈĊČÐĎĐÈÉÊËĒĔĖĘĚĜĞĠĢĤĦÌÍÎÏĨĪĬĮİĴĵĶĹĻĽĿŁÑŃŅŇŊÒÓÔÕÖØŌŎŐŔŖŘŚŜŞŠŢŤŦÙÚÛÜŨŪŬŮŰŲŴÝŶŸŹŻŽ",
				"àáâãäåāăąçćĉċčðďđèéêëēĕėęěĝğġģĥħìíîïĩīĭįıJjķĺļľŀłñńņňŋòóôõöøōŏőŕŗřśŝşšţťŧùúûüũūŭůűųŵýŷYźżž"
			)
			text = text.downcase
			text
		end

		def process_ascii(text)
			return nil if text.nil?
			text = text.tr(
				"ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
				"AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz"
			)
			text = text.downcase
			text
		end

		def state_br(state)
			return @states[state]
		end

	end
end	

geonames = CSV.read("app/helpers/data/geo-result.csv", col_sep: ';')
geonames.shift 
munic = CSV.read("app/helpers/data/munic.csv", col_sep: ';')
munic.shift
bar = ProgressBar.new(geonames.size+munic.size)
place = []

geonames.each{|g| 
	bar.increment!
	next if g[5] == "BR"
	place << {
		city: g[0],
		city_ascii: g[1].downcase,
		city_alt: g[2],
		state: g[8],
		state_ascii: Util.process_ascii(g[8]),
		state_code: nil,
		state_alt: g[9],
		country: g[4],
		country_ascii: Util.process_ascii(g[4]),
		country_code1: g[5],
		country_code2: nil,
		country_alt: nil,
		latitude: g[6],
		longitude: g[7]
	}
}

munic.each{|m| 
	bar.increment!
	place << {
		city: m[0],
		city_ascii: m[1],
		city_alt: nil,
		state: Util.state_br(m[2].downcase),
		state_ascii: Util.state_br(m[2].downcase),
		state_code: m[2].downcase,
		state_alt: nil,
		country: "brasil",
		country_ascii: "brasil",
		country_code1: "BR",
		country_code2: "BRA",
		country_alt: "brazil",
		latitude: m[3],
		longitude: m[4]
	}
}

# byebug

csv_string = CSV.generate(:col_sep => ";") do |csv|
	csv << ["city", "city_ascii", "city_alt", "state", "state_ascii", "state_code", "state_alt", "country", "country_ascii", "country_code1", "country_code2", "country_alt", "latitude", "longitude"]
	place.each{|g|
		csv << g.values
	}
end
File.write("app/helpers/data/place-result.csv", csv_string)


