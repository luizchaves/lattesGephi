require 'csv'

loc = CSV.read("countlocations.csv", col_sep: ';')
loclatlon = CSV.read("countlocationslatlon.csv", col_sep: ';')

loch = {}
loc.each{|l|
	loch[l[0]] = l[1]
}

loclatlonh = {}
loclatlon.each{|l|
	loclatlonh[l[0]] = l[1]
}

ids = []
loch.each{|index, value|
	if loch[index] == loclatlonh[index]
		ids << index
	end
}

File.write("ids.csv", ids.join(", "))