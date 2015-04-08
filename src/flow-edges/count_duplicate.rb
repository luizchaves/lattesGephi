edges = File.read("/Users/lucachaves/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-city-birth.csv")
edges = File.read("/Users/lucachaves/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-city-work.csv")
edges = File.read("/Users/lucachaves/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-instituition-work.csv")

total = 0
total_count = 0
equal = 0
equal_count = 0

edges.split("\n")[1..-1].each{|row|
	row = row.split(",")
	if row[0] == row[1]
		equal += 1
		equal_count += row[-1].to_i
		total += 1
		total_count += row[-1].to_i
	else
		total += row[-1].to_i
		total_count += row[-1].to_i
	end
} 


puts equal
puts equal_count
puts total
puts total_count

#### CITY-BIRTH
# equal
# 76463/311685 = 24%
# total
# 152260/387482 = 40%

#### CITY-WORK
# equal
# 353/89640 = 0%
# total
# 56088/145375 = 39%

#### INSTITUITION-WORK
# equal
# 353/89640 = 0%
# total
# 56088/145375 = 39%

