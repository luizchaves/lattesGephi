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

file = File.read('edges-flow-city-distance-year-all.csv')

# kind_change = "cube_root"
kind_change = ""

kind_index = "code"
# kind_index = "name"

distinct_rows = {}
flow = []
flow_all = []
# names2 = {}
names = {"1"=>"florianopolis", "15"=>"curitiba", "116"=>"itajai", "13"=>"rio de janeiro", "5"=>"sao paulo", "121"=>"caxias do sul", "43"=>"sao leopoldo", "238"=>"leon", "20"=>"niteroi", "180"=>"resende", "52"=>"goiania", "168"=>"sao carlos", "54"=>"recife", "221"=>"evanston", "107"=>"london", "36"=>"campinas", "169"=>"reading", "213"=>"lages", "138"=>"chicago", "139"=>"erechim", "60"=>"porto alegre", "281"=>"birmingham", "101"=>"albany", "59"=>"guarulhos", "42"=>"pelotas", "202"=>"tubarao", "10"=>"londrina", "50"=>"belo horizonte", "25"=>"bauru", "70"=>"guarapuava", "51"=>"maringa", "9"=>"brasilia", "254"=>"paranavai", "211"=>"brusque", "111"=>"natal", "85"=>"madrid", "28"=>"santa maria", "115"=>"toronto", "258"=>"campos dos goytacazes", "80"=>"juiz de fora", "17"=>"manaus", "75"=>"joao pessoa", "90"=>"fortaleza", "320"=>"nanterre", "350"=>"pompeia", "144"=>"anapolis", "166"=>"ouro preto", "104"=>"porto", "49"=>"salvador", "257"=>"canoinhas", "16"=>"sao luis", "18"=>"uberlandia", "347"=>"joinville", "27"=>"belem", "225"=>"rio claro", "94"=>"cascavel", "71"=>"ribeirao preto", "109"=>"leuven", "23"=>"montevideo", "199"=>"sao goncalo", "2"=>"philadelphia", "39"=>"vitoria", "108"=>"maceio", "119"=>"chapeco", "228"=>"blumenau", "248"=>"santa cruz do sul", "3"=>"braga", "163"=>"ponta grossa", "14"=>"rio grande", "93"=>"cuiaba", "123"=>"sao jose dos campos", "33"=>"passo fundo", "184"=>"stuttgart", "284"=>"brisbane", "164"=>"vila velha", "148"=>"rio branco", "114"=>"manizales", "349"=>"sao jose", "125"=>"lisbon", "229"=>"leeds", "309"=>"san ignacio", "156"=>"sao cristovao", "129"=>"nottingham", "277"=>"stillwater", "193"=>"porto velho", "242"=>"criciuma", "342"=>"governador valadares", "355"=>"diamantina", "87"=>"santa fe de la vera cruz", "47"=>"tokyo", "237"=>"west lafayette", "7"=>"lavras", "29"=>"canoas", "30"=>"bage", "442"=>"bogota", "8"=>"alfenas", "162"=>"sao bernardo do campo", "102"=>"campo grande", "56"=>"vicosa", "393"=>"caruaru", "167"=>"marilia", "232"=>"ijui", "312"=>"sao miguel do oeste", "41"=>"umuarama", "117"=>"presidente prudente", "130"=>"gainesville", "4"=>"ottawa", "133"=>"sevilla", "132"=>"petropolis", "305"=>"alicante", "446"=>"saint andrews", "72"=>"paris", "106"=>"valparaiso", "63"=>"los angeles", "74"=>"barcelona", "190"=>"montpellier", "219"=>"vancouver", "359"=>"nancy", "189"=>"waterloo", "181"=>"brussels", "246"=>"delft", "165"=>"cedar rapids", "272"=>"corvallis", "205"=>"cadiz", "346"=>"lancaster", "151"=>"la jolla", "150"=>"uberaba", "172"=>"bloomington", "247"=>"college station", "21"=>"ilheus", "187"=>"munster", "197"=>"manchester", "124"=>"milano", "120"=>"novo hamburgo", "67"=>"berlin", "84"=>"seropedica", "45"=>"cambridge", "140"=>"compiegne", "182"=>"edinburgh", "311"=>"loughborough", "173"=>"mogi das cruzes", "152"=>"champaign", "92"=>"rome", "198"=>"varginha", "267"=>"norwich", "141"=>"edmonton", "78"=>"padova", "230"=>"coral gables", "297"=>"parkville", "118"=>"zaragoza", "154"=>"campo mourao", "253"=>"austin", "245"=>"toulouse", "294"=>"rennes", "275"=>"palmas", "48"=>"vitoria da conquista", "183"=>"raleigh", "375"=>"santa rita do sapucai", "143"=>"teresina", "325"=>"cachoeira do sul", "79"=>"macapa", "66"=>"baltimore", "286"=>"quebec", "6"=>"ithaca", "251"=>"auburn", "276"=>"berkeley", "159"=>"franca", "218"=>"jaboticabal", "179"=>"campina grande", "95"=>"aveiro", "161"=>"itajuba", "261"=>"sobral", "19"=>"caceres", "68"=>"tres coracoes", "289"=>"dourados", "153"=>"coronel fabriciano", "390"=>"cruz das almas", "46"=>"minneapolis", "287"=>"lexington", "134"=>"madison", "217"=>"montes claros", "208"=>"sao joao del rei", "137"=>"piracicaba", "328"=>"inconfidentes", "304"=>"tallahassee", "22"=>"santos", "73"=>"lorena", "158"=>"santo andre", "131"=>"araraquara", "105"=>"davis", "128"=>"denver", "209"=>"braganca paulista", "145"=>"sao jose do rio preto", "91"=>"buenos aires", "343"=>"batatais", "371"=>"guelph", "296"=>"boa vista", "368"=>"koeln", "57"=>"araras", "195"=>"skokie", "362"=>"valence", "65"=>"riverside", "339"=>"colmar", "171"=>"washington d c", "191"=>"turin", "357"=>"caceres", "244"=>"new brunswick", "44"=>"taubate", "293"=>"calgary", "210"=>"pittsburgh", "233"=>"saint denis", "77"=>"santiago", "429"=>"london", "235"=>"bordeaux", "308"=>"araguaina", "61"=>"oxford", "365"=>"suzano", "127"=>"boston", "31"=>"atlanta", "178"=>"seattle", "12"=>"cambridge", "177"=>"santa cruz", "204"=>"charlottesville", "64"=>"new york city", "334"=>"catanduva", "280"=>"cerdanyola del valles", "278"=>"liverpool", "146"=>"ann arbor", "38"=>"garching bei munchen", "216"=>"providence", "122"=>"iowa city", "113"=>"sheffield", "367"=>"medianeira", "26"=>"new haven", "271"=>"hannover", "252"=>"princeton", "32"=>"fort collins", "226"=>"ames", "192"=>"glasgow", "444"=>"houston", "206"=>"strasbourg", "338"=>"brighton", "176"=>"botucatu", "98"=>"joliet", "292"=>"valencia", "408"=>"amsterdam", "170"=>"bologna", "332"=>"heidelberg", "76"=>"palo alto", "353"=>"lyon", "155"=>"pamplona", "264"=>"garca", "448"=>"trujillo", "413"=>"araripina", "435"=>"colchester", "243"=>"geneva", "318"=>"varzea grande", "185"=>"east lansing", "405"=>"belo jardim", "234"=>"florence", "327"=>"copenhagen", "354"=>"leiden", "240"=>"cachoeiro de itapemirim", "455"=>"assis chateaubriand", "316"=>"olinda", "425"=>"sao jose do rio pardo", "265"=>"tucson", "302"=>"sao caetano do sul", "96"=>"barretos", "83"=>"chatenay malabry", "263"=>"lima", "256"=>"sydney", "136"=>"duque de caxias", "341"=>"cali", "186"=>"state college", "11"=>"feira de santana", "398"=>"osasco", "358"=>"sete lagoas", "200"=>"santiago de compostela", "37"=>"apucarana", "279"=>"logan", "313"=>"bethesda", "315"=>"boulder", "241"=>"south bend", "249"=>"caratinga", "255"=>"nashville", "386"=>"bucaramanga", "433"=>"sao luis de montes belos", "35"=>"valladolid", "220"=>"granada", "323"=>"sorocaba", "201"=>"cordoba", "69"=>"medellin", "110"=>"wageningen", "403"=>"cachoeira", "203"=>"jundiai", "274"=>"coventry", "291"=>"creteil", "437"=>"pirassununga", "370"=>"vassouras", "326"=>"votuporanga", "383"=>"ituverava", "335"=>"villeurbanne", "126"=>"bento goncalves", "395"=>"golden", "34"=>"salamanca", "374"=>"santa rita", "319"=>"montreal", "282"=>"salt lake city", "86"=>"la plata", "388"=>"sapporo", "212"=>"pullman", "135"=>"rochester", "336"=>"karlsruhe", "231"=>"columbus", "81"=>"utrecht", "306"=>"guildford", "322"=>"syracuse", "303"=>"kyoto", "58"=>"medford", "389"=>"lausanne", "99"=>"rottenburg", "340"=>"murcia", "301"=>"poitiers", "366"=>"guaratingueta", "406"=>"santa fe do sul", "269"=>"mossoro", "268"=>"aberdeen", "337"=>"cuenca", "352"=>"pisa", "24"=>"breves", "299"=>"nova iguacu", "411"=>"mairipora", "387"=>"andradina", "396"=>"catalao", "381"=>"itaperuna", "295"=>"lund", "431"=>"york", "356"=>"orlando", "40"=>"evora", "456"=>"arcoverde", "324"=>"tempe", "402"=>"college park", "314"=>"tours", "363"=>"rio verde", "400"=>"arapiraca", "89"=>"centro habana", "439"=>"itaborai", "351"=>"leicester", "160"=>"erlangen", "214"=>"freiburg", "361"=>"nilopolis", "283"=>"frankfurt am main", "194"=>"guanambi", "344"=>"leioa", "399"=>"southampton", "298"=>"newcastle upon tyne", "147"=>"aracaju", "427"=>"bonn", "239"=>"blacksburg", "175"=>"athens", "453"=>"amherst", "321"=>"crato", "222"=>"ivry sur seine", "224"=>"barbacena", "345"=>"bahia blanca", "100"=>"caracas", "418"=>"ituiutaba", "430"=>"cataguases", "404"=>"nova friburgo", "372"=>"espirito santo do pinhal", "196"=>"avare", "426"=>"sao gotardo", "377"=>"lawrence", "407"=>"cornelio procopio", "227"=>"concepcion", "188"=>"fort washington", "436"=>"assis", "273"=>"bristol", "382"=>"mogi guacu", "329"=>"penapolis", "250"=>"palmas", "460"=>"mirassol", "454"=>"olimpia", "440"=>"pereira barreto", "266"=>"cordoba", "450"=>"manhattan", "378"=>"limeira", "236"=>"lins", "288"=>"aracatuba", "364"=>"sao joao de meriti", "384"=>"epinal", "412"=>"jacarezinho", "459"=>"rio pomba", "310"=>"faro", "260"=>"nazare paulista", "369"=>"santa clara", "414"=>"nova venecia", "215"=>"cruz alta", "452"=>"melbourne", "461"=>"mineiros", "331"=>"starkville", "445"=>"bondy", "207"=>"charqueadas", "223"=>"volta redonda", "259"=>"lajeado", "423"=>"lauro de freitas", "285"=>"kiel", "142"=>"new orleans", "458"=>"vespasiano", "103"=>"almenara", "457"=>"formiga", "434"=>"conselheiro lafaiete", "416"=>"bedford", "391"=>"canterbury", "307"=>"sceaux", "424"=>"grenoble", "421"=>"nova lima", "270"=>"ananindeua", "401"=>"salto", "449"=>"jaboatao dos guararapes", "376"=>"patos", "149"=>"gent", "447"=>"petrolina", "330"=>"pouso alegre", "157"=>"hamburg", "317"=>"osorio", "443"=>"santo angelo", "290"=>"oviedo", "428"=>"campanha", "422"=>"maturin", "348"=>"barra mansa", "385"=>"teresopolis", "88"=>"covilha", "379"=>"rondonopolis", "451"=>"sao mateus", "360"=>"salinas", "420"=>"valenca", "419"=>"bandeirantes", "392"=>"jandaia do sul", "415"=>"ariquemes", "333"=>"vigo", "262"=>"itatiba", "380"=>"balneario camboriu", "373"=>"muriae", "410"=>"agua branca", "300"=>"santiago de cuba", "417"=>"maranguape", "394"=>"paranagua", "3129"=>"goiana", "2499"=>"restinga seca", "4410"=>"albuquerque", "496"=>"mandaguari", "441"=>"coroata", "477"=>"guaruja", "112"=>"cleveland", "5983"=>"blagnac", "484"=>"goias", "760"=>"contagem", "491"=>"amparo", "486"=>"adamantina", "502"=>"victoria", "694"=>"tupa", "893"=>"colatina", "1943"=>"wenceslau braz", "1808"=>"rubiataba", "1060"=>"imperatriz", "1042"=>"macae", "472"=>"barreiras", "1774"=>"luz", "1335"=>"paranaiba", "499"=>"patos de minas", "1233"=>"pato branco", "2455"=>"dois vizinhos", "1452"=>"igarassu", "983"=>"alegre", "999"=>"paracatu", "2309"=>"uppsala", "482"=>"carapicuiba", "506"=>"colorado do oeste", "1986"=>"camaqua", "438"=>"bilbao", "1605"=>"congonhas", "475"=>"santarem", "664"=>"itapetininga", "55"=>"americana", "409"=>"garanhuns", "1459"=>"ivaipora", "1070"=>"penedo", "470"=>"diadema", "489"=>"maua", "468"=>"campo limpo paulista", "2589"=>"sumare", "1109"=>"sao jose dos pinhais", "621"=>"jales", "1054"=>"barra bonita", "1554"=>"valinhos", "488"=>"cotia", "174"=>"ourinhos", "590"=>"ponte nova", "1513"=>"macaiba", "1115"=>"piraju", "501"=>"vitoria de santo antao", "1742"=>"jaguariuna", "97"=>"araxa", "1621"=>"paripiranga", "2673"=>"valenca", "1105"=>"divinopolis", "1080"=>"para de minas", "761"=>"ipatinga", "1548"=>"sao joaquim da barra", "883"=>"itabira", "1093"=>"curvelo", "467"=>"foz do iguacu", "500"=>"belford roxo", "1286"=>"cabo frio", "3921"=>"serra", "1396"=>"cariacica", "624"=>"sao manuel", "3603"=>"pinhais", "471"=>"pindamonhangaba", "481"=>"itapecerica da serra", "1483"=>"porto nacional", "505"=>"barra do garcas", "1491"=>"auriflama", "2519"=>"gurupi", "478"=>"indaiatuba", "1253"=>"itu", "1416"=>"taquara", "1319"=>"palmeira dos indios", "479"=>"eldorado do sul", "4206"=>"capanema", "1873"=>"lapa", "1816"=>"dracena", "465"=>"toledo", "1645"=>"cruzeiro do oeste", "1026"=>"passos", "2390"=>"telemaco borba", "1347"=>"taquaritinga", "826"=>"concordia", "1634"=>"palmares", "397"=>"santo antonio do descoberto", "3696"=>"aparecida de goiania", "1125"=>"jatai", "2049"=>"joao pinheiro", "483"=>"caraguatatuba", "1541"=>"nanuque", "709"=>"santa teresa", "473"=>"taboao da serra", "495"=>"redencao", "1837"=>"machado", "1821"=>"maraba", "571"=>"santa barbara d oeste", "782"=>"cajazeiras", "2407"=>"ji parana", "3029"=>"capanema", "3083"=>"ibiuna", "2115"=>"navirai", "2619"=>"ibicarai", "5984"=>"capivari de baixo", "611"=>"parnaiba", "614"=>"sao joao da boa vista", "2611"=>"timon", "476"=>"teixeira de freitas", "464"=>"jau", "1994"=>"lucelia", "1148"=>"sao roque", "2423"=>"luziania", "2012"=>"pimenta bueno", "3620"=>"tangara da serra", "3237"=>"santa maria de jetiba", "498"=>"itapeva", "490"=>"juazeiro do norte", "728"=>"monte aprazivel", "1775"=>"canela", "1627"=>"guarai", "1504"=>"jose bonifacio", "1130"=>"tres de maio", "3573"=>"sarandi", "1411"=>"registro", "1013"=>"uba", "872"=>"patrocinio", "1308"=>"cacador", "1330"=>"paulista", "1139"=>"itapiranga", "878"=>"alem paraiba", "2659"=>"iguatama", "1441"=>"aracruz", "62"=>"castanhal", "972"=>"januaria", "981"=>"itarare", "2092"=>"aguai", "503"=>"cacoal", "1099"=>"alagoinhas", "3723"=>"diamantino", "2811"=>"presidente epitacio", "1162"=>"aracati", "1142"=>"ponta pora", "773"=>"quixada", "1840"=>"guaxupe", "1426"=>"sao bento do sul", "871"=>"fatima do sul", "4555"=>"porto belo", "1692"=>"serra talhada", "1571"=>"coromandel", "1709"=>"itumbiara", "3731"=>"chapadinha", "2605"=>"guanhaes", "4019"=>"caldas novas", "2474"=>"camacari", "763"=>"mococa", "2066"=>"araucaria", "2278"=>"santo antonio de padua", "2251"=>"cassilandia", "1255"=>"casa branca", "3030"=>"santa cruz do capibaribe", "2792"=>"venda nova do imigrante", "1285"=>"ampere", "1996"=>"janauba", "4327"=>"extrema", "1111"=>"agudos", "4014"=>"paco do lumiar", "2479"=>"cristalina", "4959"=>"colider", "796"=>"goiatuba", "2208"=>"tucurui", "1084"=>"manhuacu", "3673"=>"matipo", "5989"=>"augustinopolis", "1025"=>"caxias", "494"=>"hortolandia"}
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
		File.write("edges-flow-city-all/data-code/edges-flow-city-distance-year-#{year}-code.csv", csv_string)
	else
		File.write("edges-flow-city-all/data-name/edges-flow-city-distance-year-#{year}-names.csv", csv_string)
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
	File.write("edges-flow-city-all/data-code/edges-flow-city-distance-year-all-code.csv", csv_string_all)
else
	File.write("edges-flow-city-all/data-name/edges-flow-city-distance-year-all-names.csv", csv_string_all)
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
	File.write("edges-flow-city-all/data-code/edges-flow-city-distance-years-code.csv", csv_string)
else
	File.write("edges-flow-city-all/data-name/edges-flow-city-distance-years-names.csv", csv_string)
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