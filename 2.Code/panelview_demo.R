install.packages("mlbench")
install.packages("DataExplorer")


library(panelView)
data(panelView)
ls()

panelView(turnout ~ policy_edr + policy_mail_in + policy_motor, data = turnout, treat.type = "continuous",index = c("abb","year"), xlab = "Year", ylab = "State")


panelView(turnout ~ policy_edr + policy_mail_in + policy_motor, data = turnout, index = c("abb","year"), type = "outcome", main = "EDR Reform and Turnout", ylim = c(0,100),xlab = "Year", ylab = "Turnout")


panelView(Capacity ~ polity2 + lngdp, data = capacity, index = c("ccode", "year"), 
          main = "Measuring State Capacity", type = "outcome", legendOff = TRUE,treat.type = "continuous")

rm(turnout)


last_month <- Sys.Date() - 0:29
df <- data.frame(
  date = last_month,
  price = runif(30)
)
base <- ggplot(df, aes(date, price)) +
  geom_line()
base + scale_x_date(date_labels = "%b %d")
