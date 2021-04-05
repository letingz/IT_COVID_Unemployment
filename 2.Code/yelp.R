install.packages("rjson")
library(jsonlite)

dframe <- jsonlite::fromJSON(txt = "data/yelp_academic_dataset_covid_features.json")
raw_data <- "data/yelp_academic_dataset_covid_features.json"

data <- fromJSON(sprintf("[%s]", paste(readLines(raw_data),collapse=",")))

paste(readLines(raw_data),collapse="")
json_data_frame <- as.data.frame(data)


