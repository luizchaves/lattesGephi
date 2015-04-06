require 'byebug'
require 'progress_bar'

edges = File.read('data/edges-flow-instituition.csv')
change = 0
not_change = 0
edges.split("\n")[1..-1].each{|row|
	row = row.split(",")
	# byebug
	if row[0] == row[1]
		change += row[-1].to_i
	else
		not_change += row[-1].to_i
	end
}
puts change
puts not_change
puts not_change+change

# 136.938 (17%)
# 660.548 (83%)
# 797.486