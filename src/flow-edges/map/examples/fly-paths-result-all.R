# http://flowingdata.com/2011/05/11/how-to-map-connections-with-great-circles/

# RESULT
library(maps)
library(geosphere)

# Load flight data
# "iata","airport","city","state","country","lat","long"
airports <- read.csv("http://datasets.flowingdata.com/tuts/maparcs/airports.csv", header=TRUE) 
# airline,airport1,airport2,cnt
flights <- read.csv("http://datasets.flowingdata.com/tuts/maparcs/flights.csv", header=TRUE, as.is=TRUE)

# xlim <- c(-171.738281, -56.601563)
# ylim <- c(12.039321, 71.856229)

# Unique carriers
carriers <- unique(flights$airline)
 
# Color
pal <- colorRampPalette(c("#333333", "white", "#1292db"))
colors <- pal(100)
 
map("world", col="#191919", fill=TRUE, bg="#000000", lwd=0.05)
for (i in 1:length(carriers)) {
# for (i in 1:1) {
     
    # pdf(paste("carrier", carriers[i], ".pdf", sep=""), width=11, height=7)
    # map("world", col="#191919", fill=TRUE, bg="#000000", lwd=0.05, xlim=xlim, ylim=ylim)
    fsub <- flights[flights$airline == carriers[i],]
    fsub <- fsub[order(fsub$cnt),]
    maxcnt <- max(fsub$cnt)
    for (j in 1:length(fsub$airline)) {
        air1 <- airports[airports$iata == fsub[j,]$airport1,]
        air2 <- airports[airports$iata == fsub[j,]$airport2,]
         
        inter <- gcIntermediate(c(air1[1,]$long, air1[1,]$lat), c(air2[1,]$long, air2[1,]$lat), n=100, addStartEnd=TRUE)
        colindex <- round( (fsub[j,]$cnt / maxcnt) * length(colors) )
                 
        lines(inter, col=colors[colindex], lwd=0.6)
    }
     
    # dev.off()
}
