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
	brazilianFlows <- flows[1,2]

	flows[1,2] <- 0
	temp <- flows[1:(size-1),2:size]
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

	# select highest values input
	# sort(flows[1,2:size], decreasing=TRUE)[1:5]/sum(flows[1,2:size])
	# sort(flows[1:size-1,2], decreasing=TRUE)[1:5]/sum(flows[1:size-1,2])

	png(paste("img-chord-normal-br2/info-global-", year, ".png", sep=""), 500, 500, pointsize = 12)
	internal <- sum(flows[1:(size-1),2:size])/(brazilianFlows+sum(flows[1:(size-1),2:size]))
	df <- data.frame(
	  fluxo = c("externo", "interno"),
	  percentage = c(internal, 1-internal)
	)
	plot <- ggplot(df, aes(x = "", y = percentage, fill = fluxo)) +
	  geom_bar(width = 1, stat = "identity")+
	  # geom_text(aes(label=paste(round(percentage*100,0),"%",sep="")))+
	  scale_fill_manual(values = c("#f1c40f", "#cccccc"))+
	  coord_polar("y", start = 0)+
	  # ggtitle("Padrão do Movimento Global")+
	  theme(
	  	legend.position = "none",
	  	plot.title = element_text(size = rel(2)),
		  panel.background = element_blank(),
			panel.grid = element_blank(),
			panel.border = element_blank(),
			axis.ticks.x = element_blank(),
			axis.text = element_text(size = 14),
			axis.title.y = element_blank(),
			axis.title.x = element_blank(),
			plot.title = element_text(size = 16, face = "bold")
		)
	print(plot)
	dev.off()
	
	png(paste("img-chord-normal-br2/info-externo-", year, ".png", sep=""), 500, 500, pointsize = 12)
	outFlow = sum(flows[1,2:size])
	inFlow = sum(flows[1:size-1,2])
	# externalFlow = sum(diag(as.matrix(flows[1:(size-1),2:size])))
	externalFlow = sum(flows[2:(size-1),3:size])
	total = inFlow+outFlow+externalFlow
	df <- data.frame(
	  fluxo = c("entrada", "saída", "externo"),
	  percentage = c(inFlow/total, outFlow/total, externalFlow/total)
	)
	total = inFlow+outFlow
	# df <- data.frame(
	#   fluxo = c("entrada", "saída"),
	#   percentage = c(inFlow/total, outFlow/total)
	# )
	plot <- ggplot(df, aes(x = "", y = round(percentage*100), fill = fluxo)) +
	  geom_bar(width = 1, stat = "identity")+
	  # geom_text(aes(label=paste(round(percentage*100,0),"%",sep=""), hjust=1.05, color=lab), size=5)+
	  coord_polar("y", start = 0)+
	  # ggtitle("Padrão do Movimento Externo")+
	  theme(
	  	legend.position = "none",
	  	plot.title = element_text(size = rel(2)),
		  panel.background = element_blank(),
			panel.grid = element_blank(),
			panel.border = element_blank(),
			axis.ticks.x = element_blank(),
			axis.text = element_text(size = 14),
			axis.title.y = element_blank(),
			axis.title.x = element_blank(),
			plot.title = element_text(size = 16, face = "bold")
		)
	print(plot)
	dev.off()

	png(paste("img-chord-normal-br2/info-inputFlow-", year, ".png", sep=""), 500, 200, pointsize = 12)
	size <- length(colnames(flows))
	values <- flows[1:size-1,2]
	names(values) <- flows[1:size-1,1]
	highest1 <- sort(values, decreasing=TRUE)[1:5]/sum(values)
	df <- data.frame(percentage = ceiling(highest1*100), pais = names(highest1))
	print(df)
	colors1 <- NULL
	for(country in names(highest1)){
		colors1 <- cbind(colors1, grid.col[country])
	}
	colors1 <- as.vector(as.matrix(colors1))
	names(colors1) <- names(highest1)
	plot <- ggplot(df,aes(x= pais, y= percentage, fill=pais))+
		geom_bar(stat="identity")+
		geom_text(aes(label=pais, hjust= 0))+
		coord_flip()+
	  scale_x_discrete(limits=names(highest1))+
	  scale_fill_manual(values=colors1)+ 
	  ylim(0, 75)+
	  # ggtitle("Top 5 - Fluxo de Entrada no Brasil")+
	  theme(
	  	legend.position = "none",
	  	plot.title = element_text(size = rel(2)),
		  panel.background = element_blank(),
			panel.grid = element_blank(),
			panel.border = element_blank(),
			axis.ticks.x = element_blank(),
			axis.text = element_text(size = 14),
			axis.text.y = element_blank(),
			axis.title.y = element_blank(),
			axis.title.x = element_blank(),
			plot.title = element_text(size = 16, face = "bold")
	  )
	print(plot)
	dev.off()

	png(paste("img-chord-normal-br2/info-outputFlow-", year, ".png", sep=""), 500, 200, pointsize = 12)
  size <- length(colnames(flows))
  values <- flows[1,2:size]
	highest2 <- ceiling(sort(values, decreasing=TRUE)[1:5]/sum(values)*100)
	df <- data.frame(percentage = as.vector(as.matrix(highest2)[1, ]), pais = names(highest2))
	print(df)
	colors2 <- NULL
	for(country in names(highest2)){
		colors2 <- cbind(colors2, grid.col[country])
	}
	colors2 <- as.vector(as.matrix(colors2))
	names(colors2) <- names(highest2)
	plot <- ggplot(df,aes(x= pais, y= percentage, fill=pais))+
		geom_bar(stat="identity")+
		geom_text(aes(label=pais, hjust= 0))+
		coord_flip() +
	  scale_x_discrete(limits=names(highest2))+
	  scale_fill_manual(values = colors2)+ 
	  ylim(0, 75)+
	  # ggtitle("Top 5 - Fluxo de Saído do Brasil")+
	  theme(
	  	legend.position = "none",
	  	plot.title = element_text(size = rel(2)),
		  panel.background = element_blank(),
			panel.grid = element_blank(),
			panel.border = element_blank(),
			axis.ticks.x = element_blank(),
			axis.text = element_text(size = 14),
			axis.text.y = element_blank(),
			axis.title.y = element_blank(),
			axis.title.x = element_blank(),
			plot.title = element_text(size = 16, face = "bold")
	  )
	print(plot)
	dev.off()

	png(paste("img-chord-normal-br2/info-highestFlow-", year, ".png", sep=""), 500, 200, pointsize = 12)
	# TODO maiores fluxos excluindo o Brasil
 #  size <- length(colnames(flows))
 #  values <- flows[1,2:size]
	# highest2 <- ceiling(sort(values, decreasing=TRUE)[1:5]/sum(values)*100)
	# df <- data.frame(percentage = as.vector(as.matrix(highest2)[1, ]), pais = names(highest2))
	# colors2 <- NULL
	# for(country in names(highest2)){
	# 	colors2 <- cbind(colors2, grid.col[country])
	# }
	# colors2 <- as.vector(as.matrix(colors2))
	# names(colors2) <- names(highest2)
	# plot <- ggplot(df,aes(x= pais, y= percentage, fill=pais))+
	# 	geom_bar(stat="identity")+
	# 	geom_text(aes(label=pais, hjust= 0))+
	# 	coord_flip() +
	#   scale_x_discrete(limits=names(highest2))+
	#   scale_fill_manual(values = colors2)+ 
	#   ylim(0, 75)+
	#   # ggtitle("Top 5 - Fluxo de Saído do Brasil")+
	#   theme(
	#   	legend.position = "none",
	#   	plot.title = element_text(size = rel(2)),
	# 	  panel.background = element_blank(),
	# 		panel.grid = element_blank(),
	# 		panel.border = element_blank(),
	# 		axis.ticks.x = element_blank(),
	# 		axis.text = element_text(size = 14),
	# 		axis.text.y = element_blank(),
	# 		axis.title.y = element_blank(),
	# 		axis.title.x = element_blank(),
	# 		plot.title = element_text(size = 16, face = "bold")
	#   )
	# print(plot)
	dev.off()

 	# grid1 <- grid.arrange(plot01, plot02, plot1, plot2, nrow=2, ncol=2)
 	# print(grid1)
	# dev.off()

	png(paste("img-chord-normal-br2/chord-", year, "-inputBR.png", sep=""), 900, 900, pointsize = 12)
	circos.par(start.degree = 90)
	chordDiagram(
		mat, 
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