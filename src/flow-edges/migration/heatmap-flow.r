
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


#### heatmap
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

#### heatmap continents
library(ggplot2)
library(reshape2)
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/migration/heatmap-flow-year-degree.csv")
row.names(flow) <- flow$continents
flow <- flow[,2:8]
flow_matrix <- data.matrix(flow)
dat2 <- melt(flow_matrix, id.var = "X1")
# dat2 <- melt(log(flow_matrix), id.var = "X1")
dat2$value <- replace(dat2$value, dat2$value==-Inf, 0)
ggplot(dat2, aes(as.factor(Var1), Var2, group=Var2)) +
  geom_tile(aes(fill = value)) + 
  geom_text(aes(fill = dat2$value, label = round(dat2$value, 1)))+
  scale_fill_gradient(low = "white", high = "red")+
  scale_x_discrete(limits=c("south america","central america","north america","europe","africa","asia","oceania"))+
  scale_y_discrete(limits=c("south.america","central.america","north.america","europe","africa","asia","oceania"))

#### heatmap countries
library(ggplot2)
library(reshape2)
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/migration/heatmap-flow-country-degree.csv")
row.names(flow) <- flow$country
flow <- flow[,2:135]
flow_matrix <- data.matrix(flow)
dat <- melt(flow_matrix, id.var = "X1")
# dat <- melt(log(flow_matrix), id.var = "X1")
dat$value <- replace(dat$value, dat$value==-Inf, 0)
ggplot(dat, aes(as.factor(Var1), Var2, group=Var2)) +
  geom_tile(aes(fill = value)) + 
  # geom_text(aes(fill = dat$value, label = round(dat$value, 1)))+
  scale_fill_gradient(low = "white", high = "red")+
  theme(axis.text.x=element_text(angle=-90))

#### heatmap regions
library(ggplot2)
library(reshape2)
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/migration/heatmap-flow-region-degree.csv")
row.names(flow) <- flow$regioes
flow <- flow[,2:6]
flow_matrix <- data.matrix(flow)
# dat <- melt(flow_matrix, id.var = "X1")
dat <- melt(log(flow_matrix), id.var = "X1")
ggplot(dat, aes(as.factor(Var1), Var2, group=Var2)) +
  geom_tile(aes(fill = value)) + 
  geom_text(aes(fill = dat$value, label = round(dat$value, 1)))+
  scale_fill_gradient(low = "white", high = "red")+
  scale_x_discrete(limits=c("sul","sudeste","centro-oeste","nordeste","norte"))+
  scale_y_discrete(limits=c("sul","sudeste","centro.oeste","nordeste","norte"))

#### heatmap states
library(ggplot2)
library(reshape2)
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/migration/heatmap-flow-state-degree.csv")
row.names(flow) <- flow$state
flow <- flow[,2:28]
flow_matrix <- data.matrix(flow)
# dat <- melt(flow_matrix, id.var = "X1")
dat <- melt(log(flow_matrix), id.var = "X1")
dat$value <- replace(dat$value, dat$value==-Inf, 0)
ggplot(dat, aes(as.factor(Var1), Var2, group=Var2)) +
  geom_tile(aes(fill = value)) + 
  # geom_text(aes(fill = dat$value, label = round(dat$value, 1)))+
  scale_fill_gradient(low = "white", high = "red")+
  theme(axis.text.x=element_text(angle=-90))

#### heatmap city
# library(ggplot2)
# library(reshape2)
# flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/migration/heatmap-flow-city-degree.csv")
# row.names(flow) <- flow$city
# flow <- flow[,2:5989]
# flow_matrix <- data.matrix(flow)
# # dat <- melt(flow_matrix, id.var = "X1")
# dat <- melt(log(flow_matrix), id.var = "X1")
# dat$value <- replace(dat$value, dat$value==-Inf, 0)
# ggplot(dat, aes(as.factor(Var1), Var2, group=Var2)) +
#   geom_tile(aes(fill = value)) + 
#   # geom_text(aes(fill = dat$value, label = round(dat$value, 1)))+
#   scale_fill_gradient(low = "white", high = "red")+
#   theme(axis.text.x=element_text(angle=-90))

#### heatmap instituition
# library(ggplot2)
# library(reshape2)
# flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/migration/heatmap-flow-instituition-degree.csv")
# row.names(flow) <- flow$state
# flow <- flow[,2:28]
# flow_matrix <- data.matrix(flow)
# # dat <- melt(flow_matrix, id.var = "X1")
# dat <- melt(log(flow_matrix), id.var = "X1")
# dat$value <- replace(dat$value, dat$value==-Inf, 0)
# ggplot(dat, aes(as.factor(Var1), Var2, group=Var2)) +
#   geom_tile(aes(fill = value)) + 
#   # geom_text(aes(fill = dat$value, label = round(dat$value, 1)))+
#   scale_fill_gradient(low = "white", high = "red")+
#   theme(axis.text.x=element_text(angle=-90))

#### heatmap
# http://stackoverflow.com/questions/14290364/heatmap-with-values-ggplot2
library(reshape2)
library(ggplot2)
dat <- matrix(rnorm(100, 3, 1), ncol=10)
names(dat) <- paste("X", 1:10)
dat2 <- melt(dat, id.var = "X1")
ggplot(dat2, aes(as.factor(Var1), Var2, group=Var2)) +
    geom_tile(aes(fill = value)) + 
    geom_text(aes(fill = dat2$value, label = round(dat2$value, 1))) +
    scale_fill_gradient(low = "white", high = "red")



# distinct flow
# http://stackoverflow.com/questions/4787332/how-to-remove-outliers-from-a-dataset
remove_outliers <- function(x, na.rm = TRUE, ...) {
  qnt <- quantile(x, probs=c(.25, .75), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}

subset(flow, count >= 20)

library(ggplot2)
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/data/count-flow.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/data/count-flow2.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/data/count-flow3.csv")

str(flow)
table(flow$count_distinct)
summary(flow)
hist(flow$count_distinct, xlim=c(0,20))

write.table(data.frame(count_distinct=remove_outliers(flow$count_distinct), count=remove_outliers(flow$count)), file = "~/Documents/code/github/lucachaves/lattesGephi/data/count-flow3.csv", sep = ",", col.names = NA)

ggplot(flow)+ 
  geom_bar(aes(x = count_distinct, y = (..count..)/sum(..count..)))+ 
  xlim(0, 20)

ggplot(flow)+ 
  geom_bar(aes(x = count, y = (..count..)/sum(..count..)))+ 
  xlim(0, 20)

ggplot(flow, aes(x=count, y=count_distinct))+
  geom_point(size=4, alpha=.2)+
  geom_smooth(method=lm,se=FALSE)

flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/data/count-flow2.1.csv")
ggplot(flow, aes(x=count, , y = (..count..)/sum(..count..), fill=kind))+
  geom_bar(position="dodge")+
  facet_grid(. ~ count)+
  xlim(0,10)


flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/data/count-flow-city.csv")
ggplot(flow)+ 
  geom_bar(aes(x = count_distinct, y = (..count..)/sum(..count..)))
