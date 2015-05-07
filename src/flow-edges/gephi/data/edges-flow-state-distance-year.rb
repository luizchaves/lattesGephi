require 'csv'
require 'byebug'
require 'progress_bar'
require 'rinruby' 

def create_chart(year, max_value, with_value=false, sufix="")
unless with_value
R.eval <<END
	library(ggplot2)
	library(reshape2)
	library(scales)
	flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-state/edges-flow-state-distance-year-#{year}.csv", sep=",",header=T, check.names = FALSE)
	row.names(flow) <- flow$names
	flow <- flow[,2:length(flow[0,])]
	flow_matrix <- data.matrix(flow)
	dat <- melt(flow_matrix, id.var = "X1")
	p <- ggplot(dat, aes(as.factor(Var1), Var2, group=Var2)) +
	  geom_tile(aes(fill = value)) + 
	  scale_fill_continuous(low = "white", high = "red",limits=c(0, #{max_value}), breaks=seq(1,#{max_value},by=#{max_value/6}))+
	  theme(axis.text.x=element_text(angle=-90))+
	  xlab("origin")+ylab("destination")+ggtitle("Flow #{year}")
	ggsave(filename="~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-state/edges-flow-state-distance-year-#{year}#{sufix}.png", plot=p, width=14, height=10, dpi=300)
END
else
R.eval <<END
	library(ggplot2)
	library(reshape2)
	library(scales)
	flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-state/edges-flow-state-distance-year-#{year}.csv", sep=",",header=T, check.names = FALSE)
	row.names(flow) <- flow$names
	flow <- flow[,2:length(flow[0,])]
	flow_matrix <- data.matrix(flow)
	dat <- melt(flow_matrix, id.var = "X1")
	p <- ggplot(dat, aes(as.factor(Var1), Var2, group=Var2)) +
	  geom_tile(aes(fill = value)) + 
	  # geom_text(aes(fill = dat$value, label = round(dat$value, 1)))+
	  geom_text(aes(fill = dat$value, label = dat$value))+
	  # scale_fill_gradient(low = "white", high = "red")+
	  scale_fill_continuous(low = "white", high = "red",limits=c(0, #{max_value}), breaks=seq(1,#{max_value},by=#{max_value/6}))+
	  theme(axis.text.x=element_text(angle=-90))+
	  xlab("origin")+ylab("destination")+ggtitle("Flow #{year}")
	ggsave(filename="~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-state/edges-flow-state-distance-year-#{year}#{sufix}.png", plot=p, width=14, height=10, dpi=300)
END
end
end

def change_value(temp, kind=nil)
	if kind == "log"
		temp = Math.log(temp) 
		temp = 0 if temp == -1.0/0.0
	elsif kind == "cube_root"
		temp = (temp**(1/3.0)).round 
	elsif kind == "square_root"
		temp = (temp**(1/2.0)).round 
	end
	temp
end

file = File.read('edges-flow-state-distance-year.csv')

kind_change = "cube_root"
kind_change = nil

distinct_rows = {}
rows = file.split("\n")

flow = []
# names2 = {}
names = {"5"=>"parana", "1"=>"santa catarina", "2"=>"sao paulo", "7"=>"rio de janeiro", "14"=>"goias", "15"=>"pernambuco", "8"=>"rio grande do sul", "3"=>"minas gerais", "21"=>"rio grande do norte", "9"=>"maranhao", "16"=>"paraiba", "10"=>"amazonas", "4"=>"federal district", "11"=>"mato grosso", "6"=>"bahia", "18"=>"ceara", "13"=>"espirito santo", "12"=>"para", "19"=>"mato grosso do sul", "26"=>"tocantins", "22"=>"piaui", "24"=>"acre", "20"=>"alagoas", "23"=>"sergipe", "25"=>"rondonia", "27"=>"roraima", "17"=>"amapa"}
bar = ProgressBar.new(rows.length)
max_value = 0
rows[1..-1].each{|row|
	row = row.split(",")
	bar.increment!
	next if row[2] != 'degree'
	source = row[0].to_i
	target = row[1].to_i
	year = row[-1].to_i
	# names2[row[0]] = row[-3] if names2[row[0]].nil?
	# names2[row[1]] = row[-2] if names2[row[1]].nil?
	flow[year] ||= []
	flow[year][source] ||= []
	flow[year][source][target] = row[6].to_i
	max_value = row[6].to_i if row[6].to_i > max_value
}
# byebug

years = (1950..2013)
# years = (2008..2010)
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
				if flow[year].nil? or
					flow[year][index1.to_i].nil? or
					flow[year][index1.to_i][index2.to_i].nil?
					row += [0]
				else
					temp = flow[year][index1.to_i][index2.to_i].to_i
					temp = change_value(temp,kind_change)
					row += [temp.to_i]
				end
			}
			csv << row
		}
	end
	File.write("edges-flow-state/edges-flow-state-distance-year-#{year}.csv", csv_string)

	csv_string.gsub!(",","\";\"")
	csv_string.gsub!("\n","\"\n\"")
	csv_string = "\"#{csv_string}\""
	csv_string.gsub!(".",",")

	File.write("edges-flow-state/edges-flow-state-distance-year-#{year}2.csv", csv_string)
}
years.each{|year|
	# if kind_change == nil
	# 	create_chart(year, change_value(max_value,kind_change), true, "-normal")
	# elsif kind_change == "cube_root"
	# 	create_chart(year, change_value(max_value,kind_change), true, "-cbrt")
	# elsif kind_change == "square_root"
	# 	create_chart(year, change_value(max_value,kind_change), true, "-sqrt")
	# end
}

counts_flow = []
counts_flow << ["source","target"]+years.to_a
names.keys.each{|index1|
	names.keys.each{|index2|
		row = [names[index1],names[index2]]
		years.each{|year|
			if flow[year].nil? or
				flow[year][index1.to_i].nil? or
				flow[year][index1.to_i][index2.to_i].nil?
				row += [0]
			else
				temp = flow[year][index1.to_i][index2.to_i].to_i
				temp = change_value(temp,kind_change)
				row += [temp.to_i]
			end
		}
		counts_flow << row
	}
}
csv_string = CSV.generate(:col_sep => ",") do |csv|
	counts_flow.each{|row|
		csv << row
	}
end
File.write("edges-flow-state/edges-flow-state-distance-years.csv", csv_string)
csv_string.gsub!(",","\";\"")
csv_string.gsub!("\n","\"\n\"")
csv_string = "\"#{csv_string}\""
csv_string.gsub!(".",",")
File.write("edges-flow-state/edges-flow-state-distance-years2.csv", csv_string)

puts "######## Create animation"
# `convert -delay 300 -loop 0 edges-flow-state/edges-flow-state-distance-year-*.png edges-flow-state/animaion.gif`
puts "fim"