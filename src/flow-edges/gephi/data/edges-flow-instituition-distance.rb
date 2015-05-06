require 'csv'
require 'byebug'
require 'progress_bar'

# Source,Target,Kind,Type,Id,Label,Weight,Distance,id16
file = File.read('edges-flow-instituition-distance.csv')

people_distance = Hash.new(0)
people_destination = {}
rows = file.split("\n")
bar = ProgressBar.new(rows.size)
rows.each{|row|
	bar.increment!
	splited = row.split(",")
	people_distance[splited[-1]] += splited[-2].to_f
	if splited[2] == 'work'
		people_destination[splited[-3]] ||= []
		people_destination[splited[-3]] << splited[-1]
	end
}

destinations = {}
people_destination.each{|destination, people|
	# byebug
	distance_sum = 0
	people.each{|person|
		distance_sum += people_distance[person]
	}
	distance_count = people.size

	destinations[destination] ||= []
	destinations[destination] << [destination, distance_count, distance_sum, distance_sum/distance_count]
}

csv_string = CSV.generate(:col_sep => ",") do |csv|
	csv << ["Destination", "Count","Sum","Avg"]
	destinations.values.each{|value|
		# byebug
		csv << value.first
	}
end
File.write("instituition-distance.csv", csv_string)

csv_string.gsub!(",","\";\"")
csv_string.gsub!("\n","\"\n\"")
csv_string = "\"#{csv_string}\""
csv_string.gsub!(".",",")

File.write("instituition-distance2.csv", csv_string)
