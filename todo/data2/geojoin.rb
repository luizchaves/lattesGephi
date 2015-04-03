# admin1
# SELECT code, countrycode, admin1_code, name, alt_name_english, geonameid
# FROM admin1codes;

# geonames
# SELECT 
#   geoname.name, 
#   geoname.asciiname, 
#   geoname.alternatenames, 
#   admin1, 
#   countryinfo.name, 
#   geoname.country,
#   geoname.latitude, 
#   geoname.longitude
# FROM 
#   public.geoname, 
#   public.countryinfo
# WHERE 
#   geoname.country = countryinfo.iso_alpha2


require 'csv'
require 'byebug'
require 'progress_bar'

geonames = CSV.read("geonames.csv", col_sep: ';')
admin1 = CSV.read("geonames-admin1.csv", col_sep: ';')
bar = ProgressBar.new(geonames.size)
geo = geonames.map{|g| 
	bar.increment!
	admin1.each{|a| 
		if(g[5] == a[1] and g[3] == a[2])
			g[8] = a[3]
			g[9] = a[4]
			break
		else
			g[8] = nil
			g[9] = nil
		end
	}
	g
}

# byebug

csv_string = CSV.generate(:col_sep => ";") do |csv|
	geo.each{|g|
		csv << g
	}
end
File.write("geo-result.csv", csv_string)