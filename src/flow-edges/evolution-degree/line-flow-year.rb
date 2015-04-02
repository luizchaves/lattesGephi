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

edges_file = File.read('edges-flow-year2.csv')

edges = Hash.new(0)
edges_file.split("\n").each{|row|
	row = row.split(",")
	year = row[-3].to_i
	# only phd
	edges[year] += 1 if row[4] == 'doutorado'
	# only phd and last 10 year
	# edges << row if row[4] == 'doutorado' and year >= 2005 
}

result = []
(1930..2014).each{|year|
	if edges[year] == 0
		result[year] = 0
	else
		result[year] = edges[year]
	end
}

result_group = {}
(1930...2010).step(10){|year| 
	end_value = year+9
	result_group[year] = result[year..end_value].inject(:+)
}

string = "year, count\n"
result_group.each{|year, count|
	string += "#{year}, #{count}\n"
}
File.write("line-flow-year-phd.csv", string)