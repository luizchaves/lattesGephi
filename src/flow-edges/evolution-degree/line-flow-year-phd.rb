require 'byebug'

def normalise(x)
	xmin = 0.0
	xmax = 52324.0
	ymin = 0.0
	ymax = 1.0
  xrange = xmax - xmin
  yrange = ymax - ymin
  ymin + (x - xmin) * (yrange.to_f / xrange) 
end

edges_file = File.read('../gephi/data/edges-flow-year2.csv')

edges = Hash.new(0)
edges_file.split("\n").each{|row|
	row = row.split(",")
	year = row[-3].to_i
	# only phd
	edges[year] += 1 if row[4] == 'doutorado'
	# only phd and last 10 year
	# edges << row if row[4] == 'doutorado' and year >= 2005 
}

string = "year, count\n"
(1940..2012).each{|year|
	string += "#{year}, #{edges[year]}\n"
}
File.write("line-flow-year-phd-1940-2012.csv", string)