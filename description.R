
#### Import data and pull out descriptive analysis ####

husa<-read.csv("./data/household/psam_husa.csv", stringsAsFactors = FALSE)

sub_husa<-subset(husa,select = c(RT, SERIALNO, DIVISION,PUMA,REGION,ST,ACCESS, BROADBND,COMPOTHX,DIALUP, HISPEED, LAPTOP,
                            OTHSVCEX, SATELLITE, SMARTPHONE, TABLET, TEL, FES, FINCP, FPARC, NOC))

colSums(is.na(sub_husa))


husb<-read.csv("./data/household/psam_husb.csv", stringsAsFactors = FALSE)



sub_husb<-subset(husb,select = c(RT, SERIALNO, DIVISION,PUMA,REGION,ST,ACCESS, BROADBND,COMPOTHX,DIALUP, HISPEED, LAPTOP,
                                 OTHSVCEX, SATELLITE, SMARTPHONE, TABLET, TEL, FES, FINCP, FPARC, NOC))
colSums(is.na(sub_husa))

table(sub_husa$ACCESS)
table(sub_husa$BROADBND)
table(sub_husa$COMPOTHX)
table(sub_husa$HISPEED)
table(sub_husa$LAPTOP)

table(sub_husb$ACCESS)
table(sub_husb$BROADBND)
table(sub_husb$COMPOTHX)
table(sub_husb$HISPEED)
table(sub_husb$LAPTOP)

hus<-rbind(sub_husa,sub_husb)

table(hus$HISPEED)

#### Connect to geographical units
