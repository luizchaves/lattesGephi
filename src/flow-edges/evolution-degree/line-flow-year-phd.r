library(ggplot2) 

phd <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/src/flow-edges/evolution-degree/line-flow-year-phd-1940-2012.csv")
people <- read.csv("~/Documents/code/github/lucachaves/lattesGephi/data/populacao-ipeadata-1872-2012.csv")

# 72 years
# df <- data.frame(years=1940:2012, phd=phd$count, population=people$Populacao[-(1:68)])
# 68 years
population = people$Populacao[-(1:78)]
phd = phd$count
df <- data.frame(years=1950:2008, phd=phd[11:69], population=population[1:59])

ggplot(df, aes(x = years, y = value, colour=variable)) + 
	geom_line(aes(y = log(phd), colour = "doutores")) + 
	geom_line(aes(y = log(population), colour = "população"))

ggplot(df, aes(x = years, y = value, colour = 'variable log(n)')) + 
	geom_line(aes(y = log(phd), colour = "doutores")) + 
	geom_line(aes(y = log(population), colour = "população"))

ggplot(df, aes(years)) + 
	geom_line(aes(y = log(phd), colour = "doutores")) + 
	geom_line(aes(y = log(population), colour = "população"))

ggplot(df, aes(x = years, y = phd, col = 'blue')) + 
	geom_line()

ggplot(df, aes(x = phd$year, y = phd$count, col = 'blue')) + 
	geom_point()

ggplot(df, aes(x = phd$year, y = phd$count, col = 'blue')) + 
	geom_line() + 
	geom_point()

ggplot(data=df, aes(x = phd$year, y = phd$count)) + 
	geom_bar(stat="identity")
