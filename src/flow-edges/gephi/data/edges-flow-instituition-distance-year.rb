require 'csv'
require 'byebug'
require 'progress_bar'
require 'rinruby' 

# "Source", "Target","Kind","Type", "Id", "Label", "Weight", "Destination", "Distance", "id16", "year"
file = File.read('edges-flow-instituition-distance-year.csv')

distinct_rows = {}
rows = file.split("\n")
bar = ProgressBar.new(rows.size)
# rows[1..100].each{|row|
rows[1..-1].each{|row|
	bar.increment!
	splited = row.split(",")
	id = "#{splited[0]}-#{splited[1]}-#{splited[2]}"
	year = splited[-1]
	next if year.nil?
	distinct_rows[id] ||= {}
	if distinct_rows[id][year].nil?
		distinct_rows[id][year] = splited[0..-3]+[year]
		distinct_rows[id][year][6] = 1
	else
		distinct_rows[id][year][6] += 1
	end
}

instituitions = []
names = {}
bar = ProgressBar.new(distinct_rows.length)
distinct_rows.each{|id,year|
	bar.increment!
	year.each{|year,value|
		next if value[2] != 'degree'
		names[value[1]] = value[7]
		instituitions[year.to_i] ||= []
		instituitions[year.to_i][value[0].to_i] ||= []
		instituitions[year.to_i][value[0].to_i][value[1].to_i] = value[6]
	}
}

def create_chart(year)
R.eval <<END
	library(ggplot2)
	library(reshape2)
	library(scales)
	flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-instituition/edges-flow-instituition-distance-year-#{year}.csv", sep=",",header=T, check.names = FALSE)
	row.names(flow) <- flow$names
	flow <- flow[,2:length(flow[0,])]
	flow_matrix <- data.matrix(flow)
	dat <- melt(flow_matrix, id.var = "X1")
	p <- ggplot(dat, aes(as.factor(Var1), Var2, group=Var2)) +
	  geom_tile(aes(fill = value)) + 
	  scale_fill_gradient(low = "white", high = "red")+
	  # scale_fill_gradient(colours=c("white", "yellow", "orange", "red"),values=rescale(c(0,1,2,3)))+
	  theme(axis.text.x=element_text(angle=-90))+
	  xlab("origin")+ylab("destination")+ggtitle("Flow #{year}")
	ggsave(filename="~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-instituition/edges-flow-instituition-distance-year-#{year}.png", plot=p, width=12, height=10, dpi=300)
END
end

# years = (1950..2010)
years = (2008..2010)
bar = ProgressBar.new(years.size)
years.each{|year|
	bar.increment!
	csv_string = CSV.generate(:col_sep => ",") do |csv|
		# csv << [nil]+names.keys
		csv << ["names"]+names.values
		names.keys.each{|index1|
			# row = [index1]
			row = [names[index1]]
			names.keys.each{|index2|
				if instituitions[year].nil? or
					instituitions[year][index1.to_i].nil? or
					instituitions[year][index1.to_i][index2.to_i].nil?
					row += [0]
				else
					temp = instituitions[year][index1.to_i][index2.to_i]
					# temp = Math.log(temp) if temp != 0
					row += [temp]
				end
			}
			csv << row
		}
	end
	File.write("edges-flow-instituition/edges-flow-instituition-distance-year-#{year}.csv", csv_string)

	# csv_string.gsub!(",","\";\"")
	# csv_string.gsub!("\n","\"\n\"")
	# csv_string = "\"#{csv_string}\""
	# csv_string.gsub!(".",",")

	# File.write("edges-flow-instituition/edges-flow-instituition-distance-year3.csv", csv_string)
}
years.each{|year|
	create_chart(year)
}
# `convert -delay 300 -loop 0 edges-flow-instituition/edges-flow-instituition-distance-year-*.png edges-flow-instituition/animaion.gif`
