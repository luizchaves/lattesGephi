library(circlize)
library(gridExtra)
library(ggplot2)

# for (year in 1960:1960) {
# for (year in 2013:2013) {
for (year in 2015:2015) {
# for (year in 1960:2013) {
# for (year in 1970:2013) {
# for (year in c(1973, 1983, 1993, 2003, 2013)) {
	print(paste("year-", year, "!", sep=""))

	flows  <- read.csv(paste("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-continent/data-name/edges-flow-continent-distance-years-", year, "-names.csv", sep=""), sep=",",header=T, check.names = FALSE)
	size <- length(colnames(flows))
	temp <- flows[1:(size-1),2:size]
	# temp <- flows[2:(size-1),3:size] # Without BR
	mat <- data.matrix(temp)
	rownames(mat) = colnames(mat) = c("AMS", "AMC", "AMN", "AS", "EU", "AF", "OC")

	grid.col = NULL # just create the variable
	grid.col["AMS"] = "#00FF00"
	grid.col["AMC"] = "#00FFFF"
	grid.col["AMN"] = "#FF0000"
	grid.col["AF"] = "#FF00FF"
	grid.col["EU"] = "#FFFF00"
	grid.col["AS"] = "#CCCCCC"
	grid.col["OC"] = "#0000AA"

	png(paste("img-chord-normal-br/chordGraph-", year, ".png", sep=""), 1000, 1000, pointsize = 12) 
	# png(paste("img-chord-normal/chordGraph-", year, ".png", sep=""), 1000, 1000, pointsize = 12) # Without BR
	# png(paste("img-chord-normal-br/chordGraph-", year, "-BR2.png", sep=""), 2000, 2000, res=2000, pointsize = 0.5) # Without BR

	# order <- c("brazil","spain","united states","united kingdom","canada","france","portugal","belgium","uruguay","germany","australia","colombia","belize","argentina","japan","chile","netherlands","italy","peru","denmark","switzerland","sweden","cuba","venezuela")
	
	circos.par(start.degree = 90)

	chordDiagram(
		mat, 
		# order = order,
		grid.col = grid.col,
		annotationTrack = "grid", 
		# preAllocateTracks = list(track.height = 0.1)
		preAllocateTracks = list(track.height = 0.3)
	)

	circos.trackPlotRegion(
		track.index = 1, 
		panel.fun = function(x, y) {
			xlim = get.cell.meta.data("xlim")
			ylim = get.cell.meta.data("ylim")
			sector.name = get.cell.meta.data("sector.index")
			# http://www.rdocumentation.org/packages/circlize/functions/circos.text
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

print("END")