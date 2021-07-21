############
#title: "BLS"
#author: Leting Zhang
#date: 06/022021
#############

install.packages('blsAPI')

library(rjson)
library(blsAPI)
response <- blsAPI('CIU1010000000000A')
json <-fromJSON(response)

df <- data.frame(year=character(),
                 period=character(), 
                 periodName=character(),
                 value=character(),
                 stringsAsFactors=FALSE) 

i <- 0

for(d in json$Results$series[[1]]$data){
  i <- i + 1
  df[i,] <- unlist(d)
}