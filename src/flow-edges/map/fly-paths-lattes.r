# http://flowingdata.com/2011/05/11/how-to-map-connections-with-great-circles/

# RESULT
library(maps)
library(geosphere)

# oX,oY,dX,dY,trips
flows <- read.csv("lattes-flows-country-2013.csv") 

 
# Color
pal <- colorRampPalette(c("#333333", "white", "#1292db"))
colors <- pal(100)
 

flows <- flows[which(flows$trips<100),]
flows <- flows[order(flows$trips),]
maxcnt <- max(flows$trips)

# png('fly-paths-lattes-2013.png', 640, 370)
png('fly-paths-lattes-2013.png', 1800, 1000)
xlim <- c(-150,150)
ylim <- c(-70, 70)
# map("world", col="#191919", fill=TRUE, bg="#000000", lwd=0.05)
map("world", col="#191919", fill=TRUE, bg="#000000", lwd=0.05, xlim=xlim, ylim=ylim)
# map("world", fill=FALSE, boundary=TRUE,bg="white", lwd=1.5, col="lightslategrey")
# map.axes()
# map.scale(120,-70,ratio=FALSE, relwidth=0.10, cex.main=2)
for (i in 1:length(flows$trips)) {
    inter <- gcIntermediate(c(flows[i,]$oY, flows[i,]$oX), c(flows[i,]$dY, flows[i,]$dX), n=100, addStartEnd=TRUE)
    colindex <- round( (flows[i,]$trips / maxcnt) * length(colors) )
    lines(inter, col=colors[colindex], lwd=0.6)
}
dev.off()

