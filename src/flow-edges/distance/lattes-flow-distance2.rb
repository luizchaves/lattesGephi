require 'byebug'
require 'progress_bar'

edges_file = File.read("../gephi/data/edges-flow-city-distance-year-country.csv")

result = "distances, years\n"
rows = edges_file.split("\n")
bar = ProgressBar.new(rows.size)
rows.each{|row|
	bar.increment!
	
	row = row.split(",")

	result += "#{row[-3].to_i}, #{row[-4].to_i}\n" #if row[-1] == 'brazil' and row[-2] == 'brazil' # and row[4] == 'doutorado'
}

# File.write("lattes-flow-distance-year-all-br.csv", result)
File.write("lattes-flow-distance-year-all.csv", result)