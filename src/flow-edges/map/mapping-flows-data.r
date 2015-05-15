library(plyr)
library(ggplot2)
library(maptools)

# edges <- "lattes-flows-country-2013.csv"
edges <- "lattes-flows-instituition-2013.csv"
# edges <- "lattes-flows-instituition-2013-br.csv"
input<-read.table(edges, sep=",", header=T)
names(input)<- c("id", "oY", "oX", "dY", "dX", "trips")

xquiet<- scale_x_continuous("", breaks=NULL)
yquiet<-scale_y_continuous("", breaks=NULL)
quiet<-list(xquiet, yquiet)

# png('mapping-flows-lattes-country-2013.png')
png('mapping-flows-lattes-instituition-2013.png', 1400, 800)
# png('mapping-flows-lattes-instituition-2013-br.png', 1400, 800)
ggplot(input[which(input$trips>0),], aes(oX, oY))+
# ggplot(input[which(input$trips>0 & input$trips<100),], aes(oX, oY))+
	geom_segment(aes(x=oX, y=oY,xend=dX, yend=dY, alpha=trips), col="white")+
	scale_alpha_continuous(range = c(0.0003, 0.03))+
	# scale_alpha_continuous(range = c(0.03, 0.3))+
	# scale_alpha_continuous(range = c(0.09, 0.5))+
	theme(panel.background = element_rect(fill='black',colour='black'))+
	quiet+
	coord_equal()
dev.off()
