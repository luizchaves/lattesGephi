require 'byebug'
require 'progress_bar'

def normalise(x)
	xmin = 0.0
	xmax = 52324.0
	ymin = 0.0
	ymax = 1.0
  xrange = xmax - xmin
  yrange = ymax - ymin
  ymin + (x - xmin) * (yrange.to_f / xrange) 
end

edges_file = File.read("../gephi/data/edges-flow-year2.csv")

result = "distances, years\n"
rows = edges_file.split("\n")
bar = ProgressBar.new(rows.size)
rows.each{|row|
	bar.increment!
	row = row.split(",")
	end_year = if row[-4].to_i == 0 and row[-3].to_i != 0
		row[-3].to_i
	elsif row[-4].to_i != 0
		row[-4].to_i
	elsif row[-4].to_i == 0 and row[-3].to_i == 0
		nil
	end

	result += "#{row[-5].to_i}, #{end_year}\n" if row[4] == 'doutorado' and !end_year.nil?
}

File.write("lattes-flow-distance-year.csv", result)