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
	flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-country/edges-flow-country-distance-year-#{year}.csv", sep=",",header=T, check.names = FALSE)
	row.names(flow) <- flow$names
	flow <- flow[,2:length(flow[0,])]
	flow_matrix <- data.matrix(flow)
	dat <- melt(flow_matrix, id.var = "X1")
	p <- ggplot(dat, aes(as.factor(Var1), Var2, group=Var2)) +
	  geom_tile(aes(fill = value)) + 
	  scale_fill_continuous(low = "white", high = "red",limits=c(0, #{max_value}), breaks=seq(1,#{max_value},by=#{max_value/6}))+
	  theme(axis.text.x=element_text(angle=-90))+
	  xlab("origin")+ylab("destination")+ggtitle("Flow #{year}")
	ggsave(filename="~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-country/edges-flow-country-distance-year-#{year}#{sufix}.png", plot=p, width=14, height=10, dpi=300)
END
else
R.eval <<END
	library(ggplot2)
	library(reshape2)
	library(scales)
	flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-country/edges-flow-country-distance-year-#{year}.csv", sep=",",header=T, check.names = FALSE)
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
	ggsave(filename="~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-country/edges-flow-country-distance-year-#{year}#{sufix}.png", plot=p, width=14, height=10, dpi=300)
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

sample = "phd"
sample = "birth"
file = File.read('edges-flow-country-distance-year-#{sample}.csv')

# kind_change = "cube_root"
kind_change = ""

kind_index = "code"
# kind_index = "name"

distinct_rows = {}
flow = []
flow_all = []
# names2 = {}
names = {"1"=>"brazil", "7"=>"spain", "2"=>"united states", "5"=>"united kingdom", "4"=>"canada", "11"=>"france", "3"=>"portugal", "19"=>"belgium", "6"=>"uruguay", "8"=>"germany", "20"=>"australia", "10"=>"colombia", "22"=>"belize", "16"=>"argentina", "9"=>"japan", "12"=>"chile", "14"=>"netherlands", "13"=>"italy", "15"=>"peru", "23"=>"denmark", "24"=>"switzerland", "21"=>"sweden", "17"=>"cuba", "18"=>"venezuela"}
rows = file.split("\n")
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
	flow_all[source] ||= []
	flow_all[source][target] ||= 0
	flow_all[source][target] += row[6].to_i
	max_value = row[6].to_i if row[6].to_i > max_value
}
# byebug

## CREATE RECORDS BY EACH YEARS
years = (1950..2013)
# years = (2008..2010)
bar = ProgressBar.new(years.size)
years.each{|year|
	bar.increment!
	csv_string = CSV.generate(:col_sep => ",") do |csv|
		if kind_index == "code"
			csv << ["codes"]+names.keys
		else
			csv << ["names"]+names.values
		end
		names.keys.each{|index1|
			if kind_index == "code"
				row = [index1]
			else
				row = [names[index1]]
			end
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
	if kind_index == "code"
		File.write("edges-flow-country-#{sample}/data-code/edges-flow-country-distance-year-#{year}-code.csv", csv_string)
	else
		File.write("edges-flow-country-#{sample}/data-name/edges-flow-country-distance-year-#{year}-names.csv", csv_string)
	end

	# csv_string.gsub!(",","\";\"")
	# csv_string.gsub!("\n","\"\n\"")
	# csv_string = "\"#{csv_string}\""
	# csv_string.gsub!(".",",")

	# File.write("edges-flow-country-#{sample}/edges-flow-country-distance-year-#{year}2.csv", csv_string)
}


## CREATE ALL RECORDS BY ALL YEARS
csv_string_all = CSV.generate(:col_sep => ",") do |csv|
	if kind_index == "code"
		csv << ["codes"]+names.keys
	else
		csv << ["names"]+names.values
	end
	names.keys.each{|index1|
		if kind_index == "code"
			row = [index1]
		else
			row = [names[index1]]
		end
		names.keys.each{|index2|
			if flow_all[index1.to_i].nil? or
				flow_all[index1.to_i][index2.to_i].nil?
				row += [0]
			else
				temp = flow_all[index1.to_i][index2.to_i].to_i
				temp = change_value(temp,kind_change)
				row += [temp.to_i]
			end
		}
		csv << row
	}
end
if kind_index == "code"
	File.write("edges-flow-country-#{sample}/data-code/edges-flow-country-distance-year-all-code.csv", csv_string_all)
else
	File.write("edges-flow-country-#{sample}/data-name/edges-flow-country-distance-year-all-names.csv", csv_string_all)
end


## CREATE CHART
# years.each{|year|
# 	if kind_change == nil
# 		create_chart(year, change_value(max_value,kind_change), true, "-normal")
# 	elsif kind_change == "cube_root"
# 		create_chart(year, change_value(max_value,kind_change), true, "-cbrt")
# 	elsif kind_change == "square_root"
# 		create_chart(year, change_value(max_value,kind_change), true, "-sqrt")
# 	end
# }



## CREATE ALL RECORDS BY EACH YEARS
counts_flow = []
counts_flow << ["source","target"]+years.to_a+["all"]
names.keys.each{|index1|
	all_years = 0
	names.keys.each{|index2|
		if kind_index == "code"
			row = [index1,index2]
		else
			row = [names[index1],names[index2]]
		end
		years.each{|year|
			if flow[year].nil? or
				flow[year][index1.to_i].nil? or
				flow[year][index1.to_i][index2.to_i].nil?
				row += [0]
			else
				temp = flow[year][index1.to_i][index2.to_i].to_i
				temp = change_value(temp,kind_change)
				row += [temp.to_i]
				all_years += temp.to_i
			end
		}
		row += [all_years.to_i]
		counts_flow << row
	}
}
csv_string = CSV.generate(:col_sep => ",") do |csv|
	counts_flow.each{|row|
		csv << row
	}
end
if kind_index == "code"
	File.write("edges-flow-country-#{sample}/data-code/edges-flow-country-distance-years-code.csv", csv_string)
else
	File.write("edges-flow-country-#{sample}/data-name/edges-flow-country-distance-years-names.csv", csv_string)
end
# csv_string.gsub!(",","\";\"")
# csv_string.gsub!("\n","\"\n\"")
# csv_string = "\"#{csv_string}\""
# csv_string.gsub!(".",",")
# File.write("edges-flow-country-#{sample}/edges-flow-country-distance-years2.csv", csv_string)



## CREATE ANIMATION GIF
# puts "######## Create animation"
# `convert -delay 300 -loop 0 edges-flow-country-#{sample}/edges-flow-country-distance-year-*.png edges-flow-country-#{sample}/animaion.gif`


puts "fim"