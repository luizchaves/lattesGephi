require 'csv'
require 'byebug'
require 'progress_bar'
require_relative '../util_helper'

universities = CSV.read("universities-dump.csv", col_sep: ';')

result = {}
bar = ProgressBar.new(universities.size)
universities.each{|u|
	bar.increment!

	name = UtilHelper::Util.process_downcase(u[0])
	name_ascii = UtilHelper::Util.process_ascii(u[0])
	latitude = u[1]
	longitude = u[2]

	result[name_ascii] = {name: name, name_ascii: name, latitude: latitude, longitude: longitude} if result[name_ascii].nil?
}

# byebug

csv_string = CSV.generate(:col_sep => ";") do |csv|
	result.each{|index, value|
		csv << value.values
	}
end
File.write("universities.csv", csv_string)