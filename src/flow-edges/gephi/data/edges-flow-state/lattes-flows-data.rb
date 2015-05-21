require 'csv'
require 'byebug'
require 'progress_bar'
require 'rinruby' 

# def generate_map(file, year)
# R.eval <<END
# 	flows <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-country/#{file}") 
#   flows <- flows[which(flows$trips>0),]

#   name <- "~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-country/img-map-normal/map-#{year}.png"
#   # png(name, 1800, 1000)
#   gg <- NULL
#   gg <- draw.map(c(-90,90))
#   for (i in 1:length(flows$trips)) {  
#     p1 <- c(flows[i,]$oY, flows[i,]$oX)
#     p2 <- c(flows[i,]$dY, flows[i,]$dX)
#     arc <- bezier.uv.merc.arc(p1, p2)
#     size <- (flows[i,]$trips/50)+0.1
#     # colour <- "green"
#     # colour <- "#1292db"
#     colour <- "#EE0000"
#     # colour <- "#6a6262"
#     # gg <- gg + geom_path(data=as.data.frame(arc), size=0.6, aes(x=lon, y=lat, group=NULL))
#     gg <- gg + geom_path(data=as.data.frame(arc), size=size, colour=colour, aes(x=lon, y=lat, group=NULL))
#     # gg <- gg + geom_line(data=as.data.frame(arc), size=size, colour=colour, aes(x=lon, y=lat, group=NULL), arrow = arrow(type = "closed", length = unit(0.06, "inches")))
#   }
#   gg
#   # dev.off()
#   ggsave(filename=name, plot=gg, width=1800, height=1000, dpi=500)
# END
# end

kind_data = "state"

edges = "data-name/edges-flow-#{kind_data}-distance-years.csv"
edges = File.read(edges).split("\n")

nodes = "../nodes-flow-#{kind_data}.csv"
nodes = File.read(nodes).split("\n")

states = {}
flows = []

year_column = {}
(1950..2013).each_with_index{|year,index|
	# year_column[year] = -65+index
	year_column[year] = -64+index
}
# year_column["all"] = -1
# byebug

# years = (2013..2013)
years = (1950..2013)
bar = ProgressBar.new(years.size)
years.each{|year|
	bar.increment!

	nodes[1..-1].each{|row|
		row = row.split(",")
		# id, lat, long
		states[row[1]] = [row[-2],row[-1]]
	}

	# byebug
	flows = []
	edges[1..-1].each_with_index{|row,index|
		row = row.split(",")
		# source, target, year
		trips = row[year_column[year]]
		next if trips == "0"
		next if row[0] == row[1]
		flows << [index]+states[row[0]]+states[row[1]]+[trips]
	}

	result = CSV.generate(:col_sep => ",") do |csv|  
		csv << ["id", "oX", "oY","dX","dY","trips"]
		flows.each{|row|
			csv << row
		}
	end

	file_result = "data-latlon/lattes-flows-#{kind_data}-#{year}.csv"
	File.write(file_result, result)
	# generate_map(file_result, year)
	# File.write("data-latlon/lattes-flows-#{kind_data}-#{year}-br.csv", result)
}

