# title: "IT and Future of Working from Home"
# stage: Plots for presentations
# author: "LetingZhang"
# date: "05/21/2021"
# input: Stored data
# output: Plots
# status: 
# note: codes are from "visualization_work.Rmd"



pdf(file=here('3.Report', 'plot.pdf'))

# ToDo  1. IT budget maps; 2. the association between the IT budget & IT labors; 3. redraw the map

library(ggplot2)
library(tidyverse)

# plot stay at home orders ----------------------------------------------------------------

us_states <- map_data("state")

# Stay@home policy

# state_home <- state_policy %>% 
#   select(state, statefips, stayathome_start,statewide_stayathome_end  ) %>% 
#   mutate(stayathome = ifelse( (stayathome_start==""), 0 ,1) )
# 
# state_home$region <- tolower(state_home$state)
# 
# map_state_home <- left_join(us_states, state_home)

# map_state_home

p <- ggplot(data = map_state_home,
            aes(x = long, y = lat,
                group = group, fill = factor(stayathome)) )

p +  scale_fill_manual(values = c("gray", "#e76f51")  , labels=   c("NO", "YES")) +
  geom_polygon(color = "gray90", size = 0.1) +
  coord_map(projection = "albers", lat0 = 39, lat1 =45)  +  
  theme_map() +guides(fill=guide_legend(title="Stay-At-Home Order")) +
  labs( title = "Stay-At-Home States 2020") + 
  theme(plot.title = element_text(size = rel(1.8), hjust = 0.5),
        #legend.title = element_text(size = rel(0.8)),
        #legend.key.width= unit(1.5, 'cm'),
        #plot.caption = element_text(size = rel(0.8)),
        legend.position = c(0.82, 0.40)) 


#scale_fill_manual(values = alpha(c("white", "blue"), 0.6), labels=   c("NO", "YES"))


# plot UI claim trends  -------------------------------------------------------------------

#ui_state_policy

 ggplot(data = ui_state_policy ,
       mapping = aes(x = month, y = initclaims_rate_regular,
                     group = state, color = factor(stayathome)) ) +
  geom_line() +
  geom_smooth(mapping = aes(group = stayathome), size= 1.5, se = TRUE) +
  coord_cartesian(c(min(ui_state_policy$month), max(ui_state_policy$month))) +  scale_x_continuous(breaks = seq(1,10,1), labels = function(x)month.abb[x])+
  scale_color_manual(name = "Stay at Home Order Enforcement", labels = c("No", "YES"),values=c( "#264653", "#e76f51"))+
  labs(x = "", y = " % Rate", title = "State Unemployment Insurance (UI) Claim Rate - 2020") +  
  theme_minimal() + 
  theme(plot.title = element_text(size = rel(1.8), hjust = 0.5),
        axis.text=element_text(size=20),
        axis.title.y = element_text(size = rel(1.8), angle = 90),
        legend.title = element_text(size = rel(1.5)),
        plot.caption = element_text(size = rel(1.5)),
        legend.position = "top") +
  labs(caption = "Note: UI claim rates =  Number of initial claims per 100 people in the 2019 labor force.") +
  geom_vline(xintercept = 3, linetype="dotted", 
             color =  "#191970", size=1.5) + 
  geom_vline(xintercept = 4, linetype="dotted", 
             color =  "#191970", size=1.5) +
  annotate(geom = "text", x=3.5, y=5, label="Stay-at-home Orders \n Enforcement", color = "#191970", size = 5)


ui_state_policy %>% 
  group_by(month, stayathome) %>% 
  summarise(rate = mean(initclaims_rate_regular)) %>% 
  ggplot(mapping = aes(x = month, y = rate,  color = factor(stayathome)))+
  geom_line(size = 1) + 
  coord_cartesian(c(min(ui_state_policy$month), max(ui_state_policy$month))) +
  scale_x_continuous(breaks = seq(1,10,1), labels = function(x)month.abb[x])+
  scale_color_manual(name = "Stay at Home Order Enforcement", 
                     labels = c("No", "YES"),values=c( "red", "blue"))+
  labs(x = "", y = " % Rate", title = "Initial Unemployment Insurance (UI) Claim Rate \n  State-level 2020") +
  theme_minimal() + 
  theme(plot.title = element_text(size = rel(1.8), hjust = 0.5),
        axis.text=element_text(size=20),
        axis.title.y = element_text(size = rel(1.8), angle = 90),
        legend.title = element_text(size = rel(1.5)),
        plot.caption = element_text(size = rel(1.5)),
        legend.position = "top") +
  labs(caption = "Note: UI claim rates =  Number of initial claims per 100 people in the 2019 labor force.") 
  

ggplot(data = ui_state_policy ,
       mapping = aes(x = month, y = initclaims_rate_regular,
                     group = state, color = factor(stayathome)) ) +
  geom_line() +
  geom_smooth(mapping = aes(group = stayathome), size= 1.5, se = TRUE) +
  coord_cartesian(c(min(ui_state_policy$month), max(ui_state_policy$month))) +  scale_x_continuous(breaks = seq(1,10,1), labels = function(x)month.abb[x])+
  scale_color_manual(name = "Stay at Home Order Enforcement", labels = c("No", "YES"),values=c( "#264653", "#e76f51"))+
  labs(x = "", y = " % Rate", title = "Initial Unemployment Insurance (UI) Claim Rate - State-level 2020") +  
  theme_minimal() + 
  theme(plot.title = element_text(size = rel(1.8), hjust = 0.5),
        axis.text=element_text(size=20),
        axis.title.y = element_text(size = rel(1.8), angle = 90),
        legend.title = element_text(size = rel(1.5)),
        plot.caption = element_text(size = rel(1.5)),
        legend.position = "top") +
  labs(caption = "Note: UI claim rates =  Number of initial claims per 100 people in the 2019 labor force.") +
  geom_vline(xintercept = 3, linetype="dotted", 
             color =  "#191970", size=1.5) + 
  geom_vline(xintercept = 4, linetype="dotted", 
             color =  "#191970", size=1.5) +
  annotate(geom = "text", x=3.5, y=5, label="Stay-at-home Orders \n Enforcement", color = "#191970", size = 5)



# plot Employment -------------------------------------------------------------------

#panel_use1

 panel_use1 %>% 
  group_by(month, stateabbrev) %>% 
  summarise(emp = mean(emp_combined, na.rm = TRUE),
            # high = sum(emp_combined_inchigh, na.rm = TRUE),
            # middle = sum(emp_combined_incmiddle, na.rm = TRUE),
            # low = sum(emp_combined_inclow, na.rm = TRUE),
            stayathome = ifelse(is.na(OrderDay), 0,1))  %>% distinct() %>%
  ggplot(aes(x = month, y = emp, group = stateabbrev, color = factor(stayathome))) +
  scale_x_continuous(breaks = seq(1,10,1), labels = function(x)month.abb[x])+
  geom_line() +
  geom_smooth(aes(group = stayathome), size= 1.5, se = TRUE) +
  scale_color_manual(name = "Stay at Home Order Enforcement", labels = c("No", "YES"),values=c( "#264653", "#e76f51"))+
  labs(x = "", y = "Relative Change %", title = "State Employment Level - 2020") +
  theme_minimal() +
  theme(plot.title = element_text(size = rel(1.6), hjust = 0.5),
        legend.title = element_text(size = rel(0.8)),
        plot.caption = element_text(size = rel(1)),
        legend.position = "top") +
  labs(caption = "Note: Employment levels relative to Jan 4-31 2020 from Paychex, Intuit, Earnin and Kronos.")



# plot IT county intensity ------------------------------------------------

ci_summarise_all %>% select(COUNTY, IT_BUDGET_medium, it_budget_per_emp_medium,count) %>%
  mutate(it = log(it_budget_per_emp_medium) ) %>% 
  right_join(county_map, by = c("COUNTY"  = "county") ) %>% 
  ggplot(mapping = aes(x = long, y = lat, 
                       fill = it, group = group)) +
  geom_polygon(color = "gray90", size = 0.05) +
  coord_equal() + scale_fill_gradient2(high = "blue", mid = "white", low= "red", 
                                       midpoint = 8.35, breaks = c(8.7, 8.35, 8), 
                                       labels = paste("$", c('6,002', '4,230', '2,980')),
                                       limits = c(8, 8.7),
                                       oob = scales::squish ) + 
  labs(fill = "") + theme_map() + theme(legend.position = "right")+  
  labs(x = "", y = "", title = "  IT Budget per Employee \nCounty Level") +  
  theme(plot.title = element_text(size = rel(2.5), hjust = 0.5),
        plot.caption = element_text(size = rel(2), hjust = 0),
        #legend.title = element_text(size = rel(1.5)),
        legend.text = element_text(size=15),
        legend.position = c(0.98, 0.40)) + labs(caption = "Source: CiTDB 2019"  )

 ci_summarise_all %>% select(COUNTY, IT_BUDGET_medium,,count) %>%
  mutate(it = log(IT_BUDGET_medium) ) %>% 
  right_join(county_map, by = c("COUNTY"  = "county") ) %>%
   ggplot(mapping = aes(x = long, y = lat,
                        fill = it, group = group)) +
   geom_polygon(color = "gray90", size = 0.05) +
   coord_equal() + scale_fill_gradient2(high = "blue", mid = "white", low= "red",
                                        midpoint = 10.65,
                                       labels = paste("$", c('54,176', '42,192', '32,859')),
                                       breaks = c(10.9, 10.65, 10.4),
                                       limits = c(10.4, 10.9),
                                       oob = scales::squish) +
   labs(fill = "") + theme_map() + theme(legend.position = "right")+
   labs(x = "", y = "", title = "  IT Budget Median \nCounty Level") +
   theme(plot.title = element_text(size = rel(2.5), hjust = 0.5),
         plot.caption = element_text(size = rel(2), hjust = 0),
         #legend.title = element_text(size = rel(1.5)),
         legend.text = element_text(size=15),
         legend.position = c(0.98, 0.40)) + labs(caption = "Source: CiTDB 2019"  )
 
 
 # ci_summarise_all %>% select(COUNTY, IT_BUDGET_medium,,count) %>%
 #   filter(count>5) %>% 
 #   mutate(it = IT_BUDGET_medium ) %>% 
 #   right_join(county_map, by = c("COUNTY"  = "county") ) %>%
 #   ggplot(mapping = aes(x = long, y = lat,
 #                        fill = it, group = group)) +
 #   geom_polygon(color = "gray90", size = 0.05) +
 #   coord_equal() + scale_fill_gradient2(high = "blue", mid = "white", low= "red",
 #                                        midpoint = 42158, 
 #                                        # breaks = c(9,8.5,8), labels = paste("$", c('8,103', '4,915', '2,980'))
 #                                        breaks = c(45227, 42158, 39115) ,
 #                                        #limits = c(39115, 45227),
 #                                        limits = c(39115, 45227),
 #                                        oob = scales::squish) +
 #   labs(fill = "") + theme_map() + theme(legend.position = "right")+
 #   labs(x = "", y = "", title = "  IT Budget Median \nCounty Level") +
 #   theme(plot.title = element_text(size = rel(2.5), hjust = 0.5),
 #         plot.caption = element_text(size = rel(2), hjust = 0),
 #         #legend.title = element_text(size = rel(1.5)),
 #         legend.text = element_text(size=15),
 #         legend.position = c(0.98, 0.40)) + labs(caption = "Source: CiTDB 2019"  )

# plot ITxStayAtHome-------------------------------------------------------------------


labels <- c("No Stay-At-Home * Low IT", "Stay-At-Home * Low IT", "No Stay-At-Home * High IT" , "Stay-At-Home * High IT" )

 county_panel %>% 
  select(month, county, aftersh, avg_initclaims_rate,  home, its_emps_high) %>% 
  group_by(month, home, its_emps_high) %>% 
  summarise_at(c("avg_initclaims_rate"), mean, na.rm = TRUE ) %>% 
  ggplot(aes(x = month, y = avg_initclaims_rate, linetype = interaction(factor(home), factor(its_emps_high)) , color = interaction(factor(home), factor(its_emps_high)) ))+  
  geom_line(size = 1.3) +   
  scale_color_manual(  name = "Conditions", values =  c( "#264653","#f4a261",  "#264653", "#f4a261"), label = labels) +
  scale_linetype_manual(name = "Conditions", values =  c("dashed", "dashed", "solid", "solid"), label = labels) +
  scale_x_continuous(breaks = seq(1,10,1), labels = function(x)month.abb[x])+
  labs(x = "", y = "Rate %", 
       title = "State-level Unemployment Insurance (UI) Claim Rate - 2020 \n Stay at Home x IT Intensity") +  
  guides(color = guide_legend(nrow=2,byrow=TRUE))+
  theme_minimal() + 
  theme(plot.title = element_text(size = rel(1.6), hjust = 0.5, ),
        legend.title = element_text(size = rel(1.2)),
        legend.key.width= unit(1.5, 'cm'),
        legend.text = element_text(size=15, color = "#696969"),
        axis.text=element_text(size=20),
        axis.title.y = element_text(size = rel(1.8), angle = 90),
        plot.caption = element_text(size = rel(1.2)),
        legend.position = "top") +
  labs(caption = "Note: UI claim rates =  Number of initial claims per 100 people in the 2019 labor force.") +
   geom_vline(xintercept = 3, linetype="dotted", 
              color =  "#191970", size=1.5)

 county_panel <-  county_panel %>% mutate(beforetreated = ifelse(month<3, 1, 0))
 
county_panel %>% 
  select(month, county, aftersh, avg_initclaims_rate,  home, its_emps_high, beforetreated) %>% 
  filter(home == 1) %>% 
  group_by(month, its_emps_high) %>% 
  summarise_at(c("avg_initclaims_rate"), mean, na.rm = TRUE ) %>% 
  ggplot(aes(x = month, y = avg_initclaims_rate,
             color =  factor(its_emps_high)) ) +  
              geom_line(size = 1.3) + 
             scale_x_continuous(breaks = seq(1,10,1), 
                                labels = function(x)month.abb[x])+
             labs(x = "", y = "Rate %", 
       title = "State-level Unemployment Insurance (UI) Claim Rate - 2020 \n Stay at Home x IT Intensity")+
  scale_color_manual(name = "IT intensity", 
                     labels = c("Low", "Hight"),values=c( "red", "blue"))+
  theme_minimal() + 
  theme(plot.title = element_text(size = rel(1.6), hjust = 0.5, ),
        legend.title = element_text(size = rel(1.2)),
        legend.key.width= unit(1.5, 'cm'),
        legend.text = element_text(size=15, color = "#696969"),
        axis.text=element_text(size=20),
        axis.title.y = element_text(size = rel(1.8), angle = 90),
        plot.caption = element_text(size = rel(1.2)),
        legend.position = "top") +
  labs(caption = "Note: UI claim rates =  Number of initial claims per 100 people in the 2019 labor force.") +
  geom_vline(xintercept = 3,
             color =  "#191970", size=1.5) + 
  annotate("text", x = 1.8, y = 2.8, label = "Before", size = 8)+
  annotate("text", x = 6, y = 2.8, label = "After", size = 8) +
  annotate("text", x = 1.8, y = 1.5, label = "Stay-at-home \n enforcement", size = 5) +
  annotate("segment", x = 1, xend = 2.8, y = 3, yend = 3,
           arrow = arrow(ends = "both", angle = 90, length = unit(0.5,"cm")), size = 1) + 
  annotate("segment", x = 3.2, xend = 11, y = 3, yend = 3,
           arrow = arrow(ends = "both", angle = 90, length = unit(0.5,"cm")), size = 1) + 
  annotate("segment", x = 2, xend = 2.8, y = 1.8, yend =2.3 ,
           colour = "black", size = 2, arrow = arrow())
  