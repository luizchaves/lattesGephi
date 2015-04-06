# name_file = "edges-flow-instituition"
name_file = "edges-flow-city"
# name_file = "edges-flow-country"
# name_file = "edges-flow-state"
# name_file = "edges-flow-region"

scale = true
# @scale_name = "log"
@scale_name = "sqrt"

def change_scale(value)
	if @scale_name == "sqrt"
		# Math.sqrt(value)
		value ** (1/2.0)
	elsif @scale_name == "log"
		Math.log(value)
	end
end

edges = File.read("#{name_file}.csv")

birth = "Source,Target,Kind,Type,Id,Label,Weight\n"
work = "Source,Target,Kind,Type,Id,Label,Weight\n"
degree = "Source,Target,Kind,Type,Id,Label,Weight\n"
all = "Source,Target,Kind,Type,Id,Label,Weight\n"

b = Hash.new(0)
b_nodes = []
w = Hash.new(0)
w_nodes = []
d = Hash.new(0)
d_nodes = []
total = Hash.new(0)
total_nodes = []

edges.split("\n")[1..-1].each{|row|
	row = row.split(",")
	id = row[0]+"-"+row[1]

	if row[2] == "birth"
		# system( "erro" ) or exit if !b[id].nil?
		puts "Erro #{id}" if b[id] > 0
		b[id] += row[-1].to_i
		b_nodes << row[0] 
		b_nodes << row[1] 
		total[id] += row[-1].to_i 
	elsif row[2] == "work"
		# system( "erro" ) or exit if !w[id].nil?
		puts "Erro #{id}"  if w[id] > 0
		w[id] += row[-1].to_i 
		w_nodes << row[0] 
		w_nodes << row[1]
		total[id] += row[-1].to_i 
	else row[2] == "degree"
		# system( "erro" ) or exit if !d[id].nil?
		puts "Erro #{id}" if d[id] > 0
		d[id] += row[-1].to_i 
		d_nodes << row[0] 
		d_nodes << row[1]
		total[id] += row[-1].to_i 
	end
}

total_nodes = b_nodes + w_nodes + d_nodes
flag = 0

b.each{|id, count|
	count = scale ? change_scale(count) : count
	birth += "#{id.split('-')[0]},#{id.split('-')[1]},birth,Directed,#{flag},,#{count}\n"
	flag += 1
}
puts "####Birth"
puts "Nós #{b_nodes.uniq.length}"
puts "Arestas #{b.length}"
puts "Fluxos #{b.values.inject(:+)}"
if scale
	File.write("#{name_file}-birth-#{@scale_name}.csv", birth)
else
	File.write("#{name_file}-birth.csv", birth)
end

w.each{|id, count|
	count = scale ? change_scale(count) : count
	work += "#{id.split('-')[0]},#{id.split('-')[1]},work,Directed,#{flag},,#{count}\n"
	flag += 1
}
puts "####Work"
puts "Nós #{w_nodes.uniq.length}"
puts "Arestas #{w.length}"
puts "Fluxos #{w.values.inject(:+)}"

if scale
	File.write("#{name_file}-work-#{@scale_name}.csv", work)
else
	File.write("#{name_file}-work.csv", work)
end

d.each{|id, count|
	count = scale ? change_scale(count) : count
	degree += "#{id.split('-')[0]},#{id.split('-')[1]},degree,Directed,#{flag},,#{count}\n"
	flag += 1
}
puts "####Degree"
puts "Nós #{d_nodes.uniq.length}"
puts "Arestas #{d.length}"
puts "Fluxos #{d.values.inject(:+)}"

if scale
	File.write("#{name_file}-degree-#{@scale_name}.csv", degree)
else
	File.write("#{name_file}-degree.csv", degree)
end

total.each{|id, count|
	count = scale ? change_scale(count) : count
	all += "#{id.split('-')[0]},#{id.split('-')[1]},all,Directed,#{flag},,#{count}\n"
	flag += 1
}
puts "####Total"
puts "Nós #{total_nodes.uniq.length}"
puts "Arestas #{total.length}"
puts "Fluxos #{total.values.inject(:+)}"

if scale
	File.write("#{name_file}-all-#{@scale_name}.csv", all)
else
	File.write("#{name_file}-all.csv", all)
end

