flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/distance/lattes-flow-distance-year.csv", sep=",",header=T, check.names = FALSE)

is.list(flow)
is.vector(flow$distances)
sumary(flow$distances)
sort(flow$distances)

hist(flow$distances)
hist(flow$distances, breaks = 20)
hist(flow$distances, breaks = 20, col = "gray", labels = TRUE)
hist(flow$distances[1:20000], breaks = 200, col = "gray")
hist(log(flow$distances+1), col = "gray")

plot(density(flow$distances))
plot(flow$distances, flow$years)
plot(flow$years, flow$distances, xlim=c(1940,2014))

# http://stackoverflow.com/questions/7714677/r-scatterplot-with-too-many-points
df <- data.frame(x = flow$years,y=flow$distances)

library(ggplot2) 
ggplot(df,aes(x=x,y=y)) + 
	geom_point(alpha = 0.3) + 
	# xlab("year") + ylab("distance")+ggtitle("Distance by Year")+
	xlab("ano") + ylab("distância")+
	theme(
    title=element_text(size=14,face="bold"), 
    axis.text=element_text(size=14,face="bold"), 
    axis.title=element_text(size=14,face="bold")#,
    # axis.text.x=element_text(angle=-90)
	)+
	xlim(1940,2014)

ggplot(df,aes(x=x,y=y)) + 
	geom_point(alpha = 0.3) + 
	xlim(1940,2014)+ 
	geom_density2d()

ggplot(df,aes(x=x,y=y))+ 
	stat_binhex()+ 
	xlim(1940,2014)

flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/distance/lattes-flow-distance-year.csv")

summary(flow$distances)
head(table(flow$distances))
length(flow$distances)
sort(flow$distances)[177229*0.7]
# 0 -> 114324 (114324/177229 - 64,5%)
# total -> 177229

ggplot(flow, aes(x = flow$distances, y = (..count..)/sum(..count..)))+ 
  geom_bar()

ggplot(flow, aes(x = flow$distances, y = (..count..)/sum(..count..)))+ 
	geom_bar()+
	# xlim(0, 12000000)+
	xlab("distância") + ylab("porcentagem (%)")+
	theme(
    title=element_text(size=14,face="bold"), 
    axis.text=element_text(size=14,face="bold"), 
    axis.title=element_text(size=14,face="bold")#,
    # axis.text.x=element_text(angle=-90)
	)

ggplot(flow, aes(x = flow$distances, y = (..count..)/sum(..count..)))+ 
	geom_bar()+xlim(-1000000, 12000000)+
	stat_bin(aes(label=paste((..count..)/sum(..count..))), vjust=1, geom="text")

ggplot(flow, aes(x = flow$distances, y = ..count..))+ 
	geom_bar()+xlim(-1000000, 12000000)+
	stat_bin(aes(label=paste(..count..)), vjust=1, geom="text")

