require 'csv'
require 'byebug'
require 'progress_bar'

puts "Iniciar"
locations = CSV.read("../../../data/locationslatlon.csv", col_sep: ';')
locations.shift
bar = ProgressBar.new(locations.size)
result = "kind, years\n"
locations.each{|location|
	bar.increment!
	start_year = if location[6].to_i == 0 and location[7].to_i != 0
		location[7].to_i
	elsif location[6].to_i != 0
		location[6].to_i
	elsif location[6].to_i == 0 and location[7].to_i == 0
		nil
	end

	end_year = if location[6].to_i != 0 and location[7].to_i == 0
		location[6].to_i
	elsif location[7].to_i != 0
		location[7].to_i
	elsif location[6].to_i == 0 and location[7].to_i == 0
		nil
	end
	# byebug
	next if end_year.nil? or start_year.nil?
	interval = end_year - start_year + 1
	next if interval <= 0 or interval > 40
	result += "#{location[2]}, #{interval}\n"
}
File.write("lattes-flow-interval2.csv", result)

puts "fim"
