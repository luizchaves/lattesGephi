library(circlize)
library(gridExtra)
library(ggplot2)

# for (year in 1960:1960) {
# for (year in 2013:2013) {
# for (year in 1960:2013) {
# for (year in 1970:2013) {
for (year in c(1973, 1983, 1993, 2003, 2013)) {
	print(paste("year-", year, "!", sep=""))

	flows  <- read.csv(paste("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/gephi/data/edges-flow-country/data-name/edges-flow-country-distance-year-", year, "-names.csv", sep=""), sep=",",header=T, check.names = FALSE)
	size <- length(colnames(flows))
	temp <- flows[1:(size-1),2:size]
	# temp <- flows[2:(size-1),3:size] # Without BR
	mat <- data.matrix(temp)
	rownames(mat) = colnames(mat)

	grid.col = NULL # just create the variable
	grid.col["brazil"] = "#00FF00"
	grid.col["spain"] = "#00FFFF"
	grid.col["united states"] = "#FF0000"
	grid.col["united kingdom"] = "#FF00FF"
	grid.col["canada"] = "#FFFF00"
	grid.col["france"] = "#CCCCCC"
	grid.col["portugal"] = "#0000AA"
	grid.col["belgium"] = "#00FFAA"
	grid.col["uruguay"] = "#00AA00"
	grid.col["germany"] = "#00AAFF"
	grid.col["australia"] = "#00AAAA"
	grid.col["colombia"] = "#FF00AA"
	grid.col["belize"] = "#FFFFAA"
	grid.col["argentina"] = "#FFAA00"
	grid.col["japan"] = "#FFAAFF"
	grid.col["chile"] = "#FFAAAA"
	grid.col["netherlands"] = "#AA0000"
	grid.col["italy"] = "#AA00FF"
	grid.col["peru"] = "#AA00AA"
	grid.col["denmark"] = "#AAFF00"
	grid.col["switzerland"] = "#AAFFFF"
	grid.col["sweden"] = "#AAFFAA"
	grid.col["cuba"] = "#AAAA00"
	grid.col["venezuela"] = "#AAAAFF"

	png(paste("img-chord-normal-br/chordGraph-", year, "-BR.png", sep=""), 1000, 1000, pointsize = 12) 
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