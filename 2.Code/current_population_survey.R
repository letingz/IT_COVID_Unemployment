
install.packages("ipumsr")

#detailed documents
#https://www.bls.gov/cps/documentation.htm#oi



library(ipumsr)
library(dplyr, warn.conflicts = FALSE)

vignette("ipums-cps", package = "ipumsr")


cps_ddi_file <- "cps_00003.xml"
cps_data_file <- "cps_00003.dat"

cps_ddi <- read_ipums_ddi(cps_ddi_file) # Contains metadata, nice to have as separate object
cps_data <- read_ipums_micro(cps_ddi_file, data_file = cps_data_file)

str(cps_data)

#Date
table(cps_data$YEAR)
table(cps_data$MONTH)
table(cps_data$YEAR,cps_data$MONTH)

#County
table(cps_data$COUNTY)

# Employement status
table(cps_data$EMPSTAT)
ipums_val_labels(cps_ddi, EMPSTAT)

# Laborforce 
table(cps_data$LABFORCE)
ipums_val_labels(cps_ddi, LABFORCE)

# Occupation (?)
table(cps_data$OCC)
ipums_val_labels(cps_ddi, OCC)

# Industry (?)
table(cps_data$IND)
ipums_val_labels(cps_ddi, IND)

# Class of worker
table(cps_data$CLASSWKR)
ipums_val_labels(cps_ddi, CLASSWKR)

# UHRSWORKT - Hours usually worked per week at all jobs
summary(cps_data$UHRSWORKT)

# WHYUNEMP
table(cps_data$CLASSWKR)

#
