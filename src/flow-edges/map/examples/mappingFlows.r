# https://gist.github.com/oscarperpinan/7cc0d51de63cfefb80e8

### DATA SECTION

library(data.table)

## Read data with 'data.table::fread'
input <- fread("wu03ew_v1.csv", select = 1:3)
setnames(input, 1:3, new = c("origin", "destination","total"))
## Coordinates
centroids <- fread("msoa_popweightedcentroids.csv")
## 'Code' is the key to be used in the joins
setkey(centroids, Code)
## Key of centroids matches `origin` in `input`
origin <- centroids[input[,.(origin, total)]]
setnames(origin, c('East', 'North'), c('xstart', 'ystart'))
## Key of centroids matches `destination` in `input`
destination <- centroids[input[,.(destination)]]
setnames(destination, c('East', 'North'), c('xend', 'yend'))
## Bind both results
trajects <- cbind(origin, destination)

### GRAPHICS SECTION

library(lattice)
library(classInt)
## Background set to black
myTheme <- simpleTheme()
myTheme$background$col <- 'black'
## Palette and classes
nClasses <- 5
pal <- colorRampPalette(c('gray70', 'white'))(nClasses)
classes <- classIntervals(trajects[total > 10, total],
                          n = nClasses, style = 'quantile')
classes <- findCols(classes)

png('mappingFlows.png')
xyplot(North ~ East, data = centroids,
       pch = '.', col = 'lightgray',
       aspect = 'iso',
       par.settings = myTheme,
       panel = function(...){
           ## panel.xyplot displays the 'centroids'
           panel.xyplot(...)
           ## panel.segments displays the lines using a `data.table`
           ## query.
           trajects[total > 10,
                    panel.segments(xstart, ystart, xend, yend,
                                   col = pal[classes],
                                   alpha = 0.05, lwd = 0.3)
                    ]
       })
dev.off()
