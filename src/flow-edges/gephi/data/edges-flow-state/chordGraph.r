library(circlize)

# for (year in 1950:2013) {
for (year in 2013:2013) {
	print(paste("year-", year, "!", sep=""))

	flows  <- read.csv(paste("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-state/data-name/edges-flow-state-distance-year-", year, ".csv", sep=""), sep=",",header=T, check.names = FALSE)
	size <- length(colnames(flows))
	temp <- flows[1:(size-1),2:size]
	mat <- data.matrix(temp)
	rownames(mat) = colnames(mat)

	# rownames(mat) = c("PR", "SC", "SP", "RJ", "GO", "PE", "RS", "MG", "RN", "MA", "PB", "AM", "DF", "MT", "BA", "CE", "ES", "PA", "MS", "TO", "PI", "AC", "AL", "SE", "RO", "RR", "AP")
	# colnames(mat) = rownames(mat)

	png(paste("img-chord-normal/chordGraph-", year, "-BR.png", sep=""), 1000, 1000)
	
	# http://colorbrewer2.org/
	# #a6cee3, #1f78b4, #b2df8a, #33a02c, #fb9a99, #e31a1c, #fdbf6f, #ff7f00, #cab2d6, #6a3d9a, #ffff99, #b15928

	grid.col = NULL # just create the variable
	grid.col["parana"] = "#00FF00"
	grid.col["santa catarina"] = "#00FFFF"
	grid.col["sao paulo"] = "#FF0000"
	grid.col["rio de janeiro"] = "#FF00FF"
	grid.col["goias"] = "#FFFF00"
	grid.col["pernambuco"] = "#CCCCCC"
	grid.col["rio grande do sul"] = "#0000AA"
	grid.col["minas gerais"] = "#00FFAA"
	grid.col["rio grande do norte"] = "#00AA00"
	grid.col["maranhao"] = "#00AAFF"
	grid.col["paraiba"] = "#00AAAA"
	grid.col["amazonas"] = "#FF00AA"
	grid.col["federal district"] = "#FFFFAA"
	grid.col["mato grosso"] = "#FFAA00"
	grid.col["bahia"] = "#FFAAFF"
	grid.col["ceara"] = "#FFAAAA"
	grid.col["espirito santo"] = "#AA0000"
	grid.col["para"] = "#AA00FF"
	grid.col["mato grosso do sul"] = "#AA00AA"
	grid.col["tocantins"] = "#AAFF00"
	grid.col["piaui"] = "#AAFFFF"
	grid.col["acre"] = "#AAFFAA"
	grid.col["alagoas"] = "#AAAA00"
	grid.col["sergipe"] = "#AAAAFF"
	grid.col["rondonia"] = "#AAAAAA"
	grid.col["roraima"] = "#000055"
	grid.col["amapa"] = "#00FF55"
	# grid.col["PR"] = "#00FF00"
	# grid.col["SC"] = "#00FFFF"
	# grid.col["SP"] = "#FF0000"
	# grid.col["RJ"] = "#FF00FF"
	# grid.col["GO"] = "#FFFF00"
	# grid.col["PE"] = "#CCCCCC"
	# grid.col["RS"] = "#0000AA"
	# grid.col["MG"] = "#00FFAA"
	# grid.col["RN"] = "#00AA00"
	# grid.col["MA"] = "#00AAFF"
	# grid.col["PB"] = "#00AAAA"
	# grid.col["AM"] = "#FF00AA"
	# grid.col["DF"] = "#FFFFAA"
	# grid.col["MT"] = "#FFAA00"
	# grid.col["BA"] = "#FFAAFF"
	# grid.col["CE"] = "#FFAAAA"
	# grid.col["ES"] = "#AA0000"
	# grid.col["PA"] = "#AA00FF"
	# grid.col["MS"] = "#AA00AA"
	# grid.col["TO"] = "#AAFF00"
	# grid.col["PI"] = "#AAFFFF"
	# grid.col["AC"] = "#AAFFAA"
	# grid.col["AL"] = "#AAAA00"
	# grid.col["SE"] = "#AAAAFF"
	# grid.col["RO"] = "#AAAAAA"
	# grid.col["RR"] = "#000055"
	# grid.col["AP"] = "#00FF55"

	# order <- c("parana", "santa catarina", "sao paulo", "rio de janeiro", "goias", "pernambuco", "rio grande do sul", "minas gerais", "rio grande do norte", "maranhao", "paraiba", "amazonas", "federal district", "mato grosso", "bahia", "ceara", "espirito santo", "para", "mato grosso do sul", "tocantins", "piaui", "acre", "alagoas", "sergipe", "rondonia", "roraima", "amapa")
	
	circos.par(start.degree = 90)

	# par(mar = c(1, 1, 1, 1))
	# chordDiagram(mat, directional = TRUE, transparency = 0.5)

	chordDiagram(mat, 
		# order = order,
		# order = union(rownames(mat), colnames(mat)),
		grid.col = grid.col,
		annotationTrack = "grid", 
		preAllocateTracks = list(track.height = 0.3)
		# preAllocateTracks = list(
  #       list(track.height = 0.02),
  #       list(track.height = 0.02)
		# )
	)
	# we go back to the first track and customize sector labels
	circos.trackPlotRegion(
		track.index = 1, 
		# bg.col = c("red", "green", "blue", rep("grey", 25)), 
		panel.fun = function(x, y) {
			xlim = get.cell.meta.data("xlim")
			ylim = get.cell.meta.data("ylim")
			sector.name = get.cell.meta.data("sector.index")
			circos.text(
				mean(xlim), 
				ylim[1], 
				sector.name, 
				facing = "clockwise",
				niceFacing = TRUE, 
				adj = c(0, 0.5),
				cex = 1.5
			)
		}, 
		bg.border = NA
	)

	circos.clear()

	dev.off()
}