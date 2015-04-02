
normalize <- function(x) { 
    for(j in 1:length(x[1,])){
        #print(j)
        min <- min(x[,j])
        max <- max(x[,j])
        if(j>6 && max == 0){
        	for(i in 1:length(x[,j])){
            x[i,j] <- -1.0
        	}	
        }else{
        	for(i in 1:length(x[,j])){
            x[i,j] <- 2 * (x[i,j] - min)/( max - min) - 1
        	}
        }
    }
    return(x)
}


flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/heatmap-flow.csv")
row.names(flow) <- flow$continents
flow <- flow[,2:8]
flow_matrix <- data.matrix(flow)
flow_heatmap <- heatmap(flow_matrix, Rowv=NA, Colv=NA, col = cm.colors(256))

my_palette <- colorRampPalette(c("white", "red"))(n = 299)
flow_heatmap <- heatmap(flow_matrix, Rowv=NA, Colv=NA, col = my_palette, margins=c(10,10))



library(reshape2)
library(ggplot2)
library(plyr)
library(scales)
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/heatmap-flow.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/heatmap-flow-year.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/heatmap-flow-year-2005.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/heatmap-flow-year-degree.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/heatmap-flow-year-degree-2005.csv")
row.names(flow) <- flow$continents
flow <- flow[,2:8]
flow_matrix <- data.matrix(flow)
#flow_matrix <- normalize(flow_matrix)
dat2 <- melt(flow_matrix, id.var = "X1")
# dat2 <- melt(log(flow_matrix+1), id.var = "X1")
# dat2 <- melt(scale(flow_matrix), id.var = "X1")
# dat2 <- melt(rescale(scale(flow_matrix)), id.var = "X1")
dat2$value[43:49] = 0
p <- ggplot(dat2, aes(as.factor(Var1), Var2, group=Var2)) +
    geom_tile(aes(fill = value)) + 
    geom_text(aes(fill = dat2$value, label = round(dat2$value, 1))) +
    ggtitle("Mobilidade entre os continentes")+
    scale_fill_gradient(low = "white", high = "steelblue")
print(p)
#http://puriney.github.io/visay/2012/12/19/heatmap-with-ggplot2/
#dat2<-ddply(dat2,.(value),transform,rescale=scale(value))
#ggplot(dat2, aes(as.factor(Var1), Var2, group=Var2)) +
#    geom_tile(aes(fill = rescale)) + 
#    geom_text(aes(fill = dat2$rescale, label = round(dat2$rescale, 1))) +
#    ggtitle("None scale")+     
#    scale_fill_gradient(low = "white", high = "red")



http://stackoverflow.com/questions/14290364/heatmap-with-values-ggplot2
library(reshape2)
library(ggplot2)
dat <- matrix(rnorm(100, 3, 1), ncol=10)
names(dat) <- paste("X", 1:10)
dat2 <- melt(dat, id.var = "X1")
ggplot(dat2, aes(as.factor(Var1), Var2, group=Var2)) +
    geom_tile(aes(fill = value)) + 
    geom_text(aes(fill = dat2$value, label = round(dat2$value, 1))) +
    scale_fill_gradient(low = "white", high = "red") 
