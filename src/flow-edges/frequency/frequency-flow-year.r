library(ggplot2) 
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-degree.csv")
df <- data.frame(flow$cities, flow$count)
# ggplot(df, aes(x = flow$cities, y = flow$count, col = 'blue')) + geom_line()
# ggplot(df, aes(x = flow$cities, y = flow$count, col = 'blue')) + geom_point()
# ggplot(df, aes(x = flow$cities, y = flow$count, col = 'blue')) + geom_line() + geom_point()
ggplot(data=df, aes(x = flow$cities, y = flow$count)) + geom_bar(stat="identity")

flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-degree-histogram.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-phd-histogram.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-phd-histogram-1995.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-phd-histogram-1985.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-phd-histogram-1975.csv")
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-phd-histogram-2005.csv")
df <- data.frame(log(flow$count), flow$freq)
ggplot(df, aes(x = flow$freq, y = log(flow$count), col = 'blue')) + geom_point()
ggplot(df, aes(x = flow$freq, y = log(flow$count), col = 'blue')) + geom_line() + geom_point()
ggplot(df, aes(x = flow$count, y = flow$freq, col = 'blue')) + geom_line() + geom_point()
ggplot(data=df, aes(x = flow$count, y = flow$freq)) + geom_bar(stat="identity")

flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-degree-histogram-pos.csv")
df <- data.frame(flow$count, flow$freq)
ggplot(df, aes(x = flow$count, y = flow$freq, col = 'blue')) + geom_line() + geom_point()
ggplot(data=df, aes(x = flow$count, y = flow$freq)) + geom_bar(stat="identity")



library(reshape2)
library(ggplot2)
library(plyr)
library(scales)
flow <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow/frequency-flow-year-phd-top-city.csv")
row.names(flow) <- flow$cities
# flow <- flow[,2:84]
flow <- flow[,2:80]
flow_matrix <- data.matrix(flow)
# dat2 <- melt(flow_matrix, id.var = "X1")
dat2 <- melt(log(flow_matrix+1), id.var = "X1")
# https://gist.github.com/dsparks/3710171
dat2$Var1 <- factor(dat2$Var1, names(sort(with(dat2, by(value, Var1, sum)))))
# dat2$Var1 <- factor(dat2$Var1, levels(dat2$Var1))
# dat2 <- melt(scale(flow_matrix), id.var = "X1")
# dat2 <- melt(rescale(scale(flow_matrix)), id.var = "X1")
# dat2$value[43:49] = 0
p <- ggplot(dat2, aes(as.factor(Var2), Var1, group=Var1)) +
    geom_tile(aes(fill = value)) + 
    scale_fill_gradient(low = "white", high = "steelblue")
print(p)
p <- ggplot(dat2, aes(as.factor(Var1), Var2, group=Var2)) +
    geom_tile(aes(fill = value)) + 
    geom_text(aes(fill = dat2$value, label = round(dat2$value, 1))) +
    ggtitle("Mobilidade entre os continentes")+
    scale_fill_gradient(low = "white", high = "steelblue")
print(p)