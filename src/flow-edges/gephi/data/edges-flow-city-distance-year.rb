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
	flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-city/edges-flow-city-distance-year-#{year}.csv", sep=",",header=T, check.names = FALSE)
	row.names(flow) <- flow$names
	flow <- flow[,2:length(flow[0,])]
	flow_matrix <- data.matrix(flow)
	dat <- melt(flow_matrix, id.var = "X1")
	p <- ggplot(dat, aes(as.factor(Var1), Var2, group=Var2)) +
	  geom_tile(aes(fill = value)) + 
	  scale_fill_continuous(low = "white", high = "red",limits=c(0, #{max_value}), breaks=seq(1,#{max_value},by=#{max_value/6}))+
	  theme(axis.text.x=element_text(angle=-90))+
	  xlab("origin")+ylab("destination")+ggtitle("Flow #{year}")
	ggsave(filename="~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-city/edges-flow-city-distance-year-#{year}#{sufix}.png", plot=p, width=14, height=10, dpi=300)
END
else
R.eval <<END
	library(ggplot2)
	library(reshape2)
	library(scales)
	flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-city/edges-flow-city-distance-year-#{year}.csv", sep=",",header=T, check.names = FALSE)
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
	ggsave(filename="~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-city/edges-flow-city-distance-year-#{year}#{sufix}.png", plot=p, width=14, height=10, dpi=300)
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

file = File.read('edges-flow-city-distance-year.csv')

# kind_change = "cube_root"
kind_change = ""

kind_index = "code"
# kind_index = "name"

distinct_rows = {}
flow = []
flow_all = []
# names2 = {}
names = {"15"=>"curitiba", "116"=>"itajai", "5"=>"sao paulo", "43"=>"sao leopoldo", "238"=>"leon", "20"=>"niteroi", "13"=>"rio de janeiro", "52"=>"goiania", "168"=>"sao carlos", "54"=>"recife", "36"=>"campinas", "169"=>"reading", "1"=>"florianopolis", "138"=>"chicago", "101"=>"albany", "59"=>"guarulhos", "60"=>"porto alegre", "50"=>"belo horizonte", "25"=>"bauru", "70"=>"guarapuava", "51"=>"maringa", "42"=>"pelotas", "111"=>"natal", "85"=>"madrid", "80"=>"juiz de fora", "320"=>"nanterre", "16"=>"sao luis", "18"=>"uberlandia", "71"=>"ribeirao preto", "75"=>"joao pessoa", "17"=>"manaus", "347"=>"joinville", "10"=>"londrina", "49"=>"salvador", "9"=>"brasilia", "163"=>"ponta grossa", "93"=>"cuiaba", "139"=>"erechim", "28"=>"santa maria", "33"=>"passo fundo", "184"=>"stuttgart", "284"=>"brisbane", "248"=>"santa cruz do sul", "277"=>"stillwater", "242"=>"criciuma", "107"=>"london", "237"=>"west lafayette", "90"=>"fortaleza", "229"=>"leeds", "117"=>"presidente prudente", "39"=>"vitoria", "4"=>"ottawa", "56"=>"vicosa", "232"=>"ijui", "305"=>"alicante", "27"=>"belem", "72"=>"paris", "106"=>"valparaiso", "14"=>"rio grande", "63"=>"los angeles", "190"=>"montpellier", "359"=>"nancy", "189"=>"waterloo", "181"=>"brussels", "246"=>"delft", "165"=>"cedar rapids", "272"=>"corvallis", "205"=>"cadiz", "74"=>"barcelona", "3"=>"braga", "7"=>"lavras", "125"=>"lisbon", "150"=>"uberaba", "247"=>"college station", "197"=>"manchester", "67"=>"berlin", "84"=>"seropedica", "140"=>"compiegne", "311"=>"loughborough", "123"=>"sao jose dos campos", "152"=>"champaign", "92"=>"rome", "267"=>"norwich", "141"=>"edmonton", "78"=>"padova", "230"=>"coral gables", "297"=>"parkville", "109"=>"leuven", "245"=>"toulouse", "133"=>"sevilla", "294"=>"rennes", "183"=>"raleigh", "130"=>"gainesville", "228"=>"blumenau", "102"=>"campo grande", "66"=>"baltimore", "286"=>"quebec", "6"=>"ithaca", "276"=>"berkeley", "159"=>"franca", "218"=>"jaboticabal", "166"=>"ouro preto", "258"=>"campos dos goytacazes", "95"=>"aveiro", "161"=>"itajuba", "179"=>"campina grande", "68"=>"tres coracoes", "8"=>"alfenas", "46"=>"minneapolis", "134"=>"madison", "158"=>"santo andre", "105"=>"davis", "137"=>"piracicaba", "2"=>"philadelphia", "91"=>"buenos aires", "371"=>"guelph", "171"=>"washington d c", "124"=>"milano", "357"=>"caceres", "145"=>"sao jose do rio preto", "210"=>"pittsburgh", "281"=>"birmingham", "77"=>"santiago", "308"=>"araguaina", "162"=>"sao bernardo do campo", "65"=>"riverside", "146"=>"ann arbor", "128"=>"denver", "32"=>"fort collins", "38"=>"garching bei munchen", "332"=>"heidelberg", "45"=>"cambridge", "176"=>"botucatu", "264"=>"garca", "448"=>"trujillo", "435"=>"colchester", "22"=>"santos", "209"=>"braganca paulista", "202"=>"tubarao", "143"=>"teresina", "148"=>"rio branco", "261"=>"sobral", "115"=>"toronto", "185"=>"east lansing", "292"=>"valencia", "21"=>"ilheus", "167"=>"marilia", "358"=>"sete lagoas", "173"=>"mogi das cruzes", "244"=>"new brunswick", "195"=>"skokie", "398"=>"osasco", "249"=>"caratinga", "341"=>"cali", "31"=>"atlanta", "253"=>"austin", "129"=>"nottingham", "199"=>"sao goncalo", "69"=>"medellin", "98"=>"joliet", "203"=>"jundiai", "44"=>"taubate", "12"=>"cambridge", "233"=>"saint denis", "437"=>"pirassununga", "234"=>"florence", "282"=>"salt lake city", "263"=>"lima", "108"=>"maceio", "370"=>"vassouras", "231"=>"columbus", "304"=>"tallahassee", "81"=>"utrecht", "306"=>"guildford", "64"=>"new york city", "127"=>"boston", "177"=>"santa cruz", "47"=>"tokyo", "444"=>"houston", "172"=>"bloomington", "303"=>"kyoto", "122"=>"iowa city", "83"=>"chatenay malabry", "251"=>"auburn", "76"=>"palo alto", "113"=>"sheffield", "178"=>"seattle", "327"=>"copenhagen", "216"=>"providence", "99"=>"rottenburg", "34"=>"salamanca", "61"=>"oxford", "301"=>"poitiers", "156"=>"sao cristovao", "256"=>"sydney", "94"=>"cascavel", "192"=>"glasgow", "220"=>"granada", "131"=>"araraquara", "204"=>"charlottesville", "337"=>"cuenca", "302"=>"sao caetano do sul", "135"=>"rochester", "240"=>"cachoeiro de itapemirim", "274"=>"coventry", "356"=>"orlando", "309"=>"san ignacio", "151"=>"la jolla", "11"=>"feira de santana", "89"=>"centro habana", "29"=>"canoas", "187"=>"munster", "132"=>"petropolis", "214"=>"freiburg", "206"=>"strasbourg", "86"=>"la plata", "57"=>"araras", "136"=>"duque de caxias", "344"=>"leioa", "87"=>"santa fe de la vera cruz", "362"=>"valence", "338"=>"brighton", "283"=>"frankfurt am main", "26"=>"new haven", "252"=>"princeton", "235"=>"bordeaux", "278"=>"liverpool", "295"=>"lund", "200"=>"santiago de compostela", "351"=>"leicester", "399"=>"southampton", "271"=>"hannover", "336"=>"karlsruhe", "268"=>"aberdeen", "298"=>"newcastle upon tyne", "299"=>"nova iguacu", "427"=>"bonn", "104"=>"porto", "255"=>"nashville", "175"=>"athens", "186"=>"state college", "346"=>"lancaster", "191"=>"turin", "319"=>"montreal", "402"=>"college park", "100"=>"caracas", "121"=>"caxias do sul", "217"=>"montes claros", "73"=>"lorena", "323"=>"sorocaba", "23"=>"montevideo", "227"=>"concepcion", "188"=>"fort washington", "280"=>"cerdanyola del valles", "289"=>"dourados", "225"=>"rio claro", "250"=>"palmas", "193"=>"porto velho", "340"=>"murcia", "450"=>"manhattan", "377"=>"lawrence", "355"=>"diamantina", "147"=>"aracaju", "35"=>"valladolid", "384"=>"epinal", "412"=>"jacarezinho", "310"=>"faro", "369"=>"santa clara", "331"=>"starkville", "339"=>"colmar", "291"=>"creteil", "353"=>"lyon", "389"=>"lausanne", "446"=>"saint andrews", "287"=>"lexington", "296"=>"boa vista", "48"=>"vitoria da conquista", "390"=>"cruz das almas", "429"=>"london", "170"=>"bologna", "182"=>"edinburgh", "142"=>"new orleans", "208"=>"sao joao del rei", "273"=>"bristol", "416"=>"bedford", "314"=>"tours", "307"=>"sceaux", "424"=>"grenoble", "226"=>"ames", "285"=>"kiel", "265"=>"tucson", "149"=>"gent", "201"=>"cordoba", "408"=>"amsterdam", "422"=>"maturin", "368"=>"koeln", "269"=>"mossoro", "88"=>"covilha", "315"=>"boulder", "144"=>"anapolis", "388"=>"sapporo", "395"=>"golden", "219"=>"vancouver", "239"=>"blacksburg", "345"=>"bahia blanca", "403"=>"cachoeira", "41"=>"umuarama", "222"=>"ivry sur seine", "157"=>"hamburg", "354"=>"leiden", "266"=>"cordoba", "19"=>"caceres", "333"=>"vigo", "262"=>"itatiba", "300"=>"santiago de cuba", "324"=>"tempe", "160"=>"erlangen", "257"=>"canoinhas", "431"=>"york", "275"=>"palmas", "110"=>"wageningen", "381"=>"itaperuna", "330"=>"pouso alegre", "243"=>"geneva", "442"=>"bogota", "288"=>"aracatuba", "40"=>"evora", "96"=>"barretos", "5983"=>"blagnac", "120"=>"novo hamburgo", "366"=>"guaratingueta", "484"=>"goias", "293"=>"calgary", "335"=>"villeurbanne", "386"=>"bucaramanga", "155"=>"pamplona", "198"=>"varginha", "241"=>"south bend", "322"=>"syracuse", "114"=>"manizales", "352"=>"pisa", "290"=>"oviedo", "983"=>"alegre", "2309"=>"uppsala", "221"=>"evanston", "79"=>"macapa", "207"=>"charqueadas", "438"=>"bilbao", "391"=>"canterbury", "499"=>"patos de minas", "375"=>"santa rita do sapucai", "453"=>"amherst", "409"=>"garanhuns", "350"=>"pompeia", "164"=>"vila velha", "213"=>"lages", "321"=>"crato", "342"=>"governador valadares", "30"=>"bage", "470"=>"diadema", "343"=>"batatais", "468"=>"campo limpo paulista", "118"=>"zaragoza", "2589"=>"sumare", "279"=>"logan", "334"=>"catanduva", "365"=>"suzano", "24"=>"breves", "486"=>"adamantina", "488"=>"cotia", "367"=>"medianeira", "4410"=>"albuquerque", "452"=>"melbourne", "374"=>"santa rita", "112"=>"cleveland", "1621"=>"paripiranga", "224"=>"barbacena", "761"=>"ipatinga", "103"=>"almenara", "1548"=>"sao joaquim da barra", "502"=>"victoria", "212"=>"pullman", "58"=>"medford", "445"=>"bondy", "392"=>"jandaia do sul", "196"=>"avare", "1742"=>"jaguariuna", "1483"=>"porto nacional", "694"=>"tupa", "478"=>"indaiatuba", "316"=>"olinda", "312"=>"sao miguel do oeste", "465"=>"toledo", "154"=>"campo mourao", "1286"=>"cabo frio", "419"=>"bandeirantes", "376"=>"patos", "180"=>"resende", "254"=>"paranavai", "126"=>"bento goncalves", "372"=>"espirito santo do pinhal", "259"=>"lajeado", "236"=>"lins", "473"=>"taboao da serra", "55"=>"americana", "495"=>"redencao", "326"=>"votuporanga", "215"=>"cruz alta", "270"=>"ananindeua", "394"=>"paranagua", "425"=>"sao jose do rio pardo", "119"=>"chapeco", "421"=>"nova lima", "313"=>"bethesda", "464"=>"jau", "400"=>"arapiraca", "3620"=>"tangara da serra", "482"=>"carapicuiba", "393"=>"caruaru", "382"=>"mogi guacu", "153"=>"coronel fabriciano", "457"=>"formiga", "782"=>"cajazeiras", "490"=>"juazeiro do norte", "404"=>"nova friburgo", "2659"=>"iguatama", "363"=>"rio verde", "981"=>"itarare", "223"=>"volta redonda", "325"=>"cachoeira do sul", "503"=>"cacoal", "447"=>"petrolina", "436"=>"assis", "496"=>"mandaguari", "1233"=>"pato branco", "1411"=>"registro", "211"=>"brusque", "434"=>"conselheiro lafaiete", "194"=>"guanambi", "1709"=>"itumbiara", "621"=>"jales", "1105"=>"divinopolis", "2407"=>"ji parana", "417"=>"maranguape", "1148"=>"sao roque", "1026"=>"passos", "796"=>"goiatuba", "37"=>"apucarana", "260"=>"nazare paulista"}
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
		File.write("edges-flow-city/data-code/edges-flow-city-distance-year-#{year}-code.csv", csv_string)
	else
		File.write("edges-flow-city/data-name/edges-flow-city-distance-year-#{year}-names.csv", csv_string)
	end

	# csv_string.gsub!(",","\";\"")
	# csv_string.gsub!("\n","\"\n\"")
	# csv_string = "\"#{csv_string}\""
	# csv_string.gsub!(".",",")

	# File.write("edges-flow-city/edges-flow-city-distance-year-#{year}2.csv", csv_string)
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
	File.write("edges-flow-city/data-code/edges-flow-city-distance-year-all-code.csv", csv_string_all)
else
	File.write("edges-flow-city/data-name/edges-flow-city-distance-year-all-names.csv", csv_string_all)
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
	File.write("edges-flow-city/data-code/edges-flow-city-distance-years-code.csv", csv_string)
else
	File.write("edges-flow-city/data-name/edges-flow-city-distance-years-names.csv", csv_string)
end
# csv_string.gsub!(",","\";\"")
# csv_string.gsub!("\n","\"\n\"")
# csv_string = "\"#{csv_string}\""
# csv_string.gsub!(".",",")
# File.write("edges-flow-city/edges-flow-city-distance-years2.csv", csv_string)



## CREATE ANIMATION GIF
# puts "######## Create animation"
# `convert -delay 300 -loop 0 edges-flow-city/edges-flow-city-distance-year-*.png edges-flow-city/animaion.gif`


puts "fim"