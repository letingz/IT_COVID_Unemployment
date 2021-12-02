# title: "IT and Future of Working from Home"
# stage: Stage 2
# author: "Leting Zhang"
# date: "12/01/2021"
# input: Processed data
# output: Plot outputs


# The original file is Plot.Rmd

#output <- here("3.Report")



# Plot: Unemployment Insurance (UI) Claim Rate ----------------------------


ggplot(data = ui_state_policy ,
       mapping = aes(x = month, y = initclaims_rate_regular,
                     group = state, color = factor(stayathome)) ) +
  geom_line() +
  geom_smooth(mapping = aes(group = stayathome), size= 1.5, se = TRUE) +
  coord_cartesian(c(min(ui_state_policy$month), max(ui_state_policy$month))) +  scale_x_continuous(breaks = seq(1,10,1), labels = function(x)month.abb[x])+
  scale_color_manual(name = "Stay at Home Order Enforcement", labels = c("No", "YES"),values=c( "#264653", "#e76f51"))+
  labs(x = "", y = " % Rate", title = "2020 State Unemployment Insurance (UI) Claim Rate") +  
  theme_minimal() + 
  theme(plot.title = element_text(size = rel(1.3), hjust = 0.5),
        legend.title = element_text(size = rel(0.8)),
        plot.caption = element_text(size = rel(1)),
        legend.position = "top") +
  labs(caption = "Note: UI claim rates =  Number of initial claims per 100 people in the 2019 labor force.")

ggsave(here("3.Report","unemployment_stayathome.png"), width = 7, height = 4, dpi = 300, units = "in", device='png')



# Plot: Unemployement Data Sources: County-level Characteristics ----------


data_summary %>%  ggplot( aes(y = indicator , x = value_use)) +
  geom_bar_pattern(aes(pattern = benchmark ), width = 0.4, stat="identity", fill = "gray")  +
  scale_y_discrete(labels = c("pop" = "All Counties",
                              "ui" = "Unemployment Insurance", 
                              "pay" = "Payroll", 
                              "cps" = "Current Population Survey"))+
  scale_pattern_manual(values = c(Benchmark = "stripe", `Other Data Sources` = "none"))+ 
  scale_alpha_manual(values = c(0.6,1)) +
  facet_wrap(~facet, scales = "free_x") + 
  theme_minimal()+  
  labs(x = "", y = "", title = "Unemployement Data Sources: County-level Characteristics" ) +
  theme(legend.position = "top", 
        axis.title.y = element_blank(),
        plot.title = element_text(size = rel(1.3), hjust = 0.5)) +
  guides(pattern =guide_legend(title=""))


ggsave(here("3.Report","data_representatives.png"), width = 7, height = 4, dpi = 300, units = "in", device='png')





#  Plot: 2019 County-level Business Access to IT- Map ----

mid_data %>%
  right_join(county_map, by = c("COUNTY"  = "county") ) %>% 
  ggplot(mapping = aes(x = long, y = lat, 
                       fill = it2, group = group)) +
  geom_polygon(color = "gray90", size = 0.05) +
  coord_equal() + 
  scale_fill_gradient2(high = "blue", mid = "white", low= "red", 
                       limits=c(10.37,10.93),
                       breaks = c(10.37, 10.65, 10.92), 
                       midpoint = 10.65,
                       labels = paste("$", c('32,208', '42,192', '54,176')),
                       guide = "colorbar") +
  labs(fill = "") + theme_map() + theme(legend.position = "right")+  
  labs(x = "", y = "", title = " 2019 County-level Business Access to IT (BAIT) - Map",
       caption = "Note: The measurement is county-level median of IT budget per establishment (USD)") +  
  theme(plot.title = element_text(size = rel(1.5), hjust = 0.5),
        plot.caption = element_text(size = rel(1.2), hjust = 0),
        #legend.title = element_text(size = rel(1.5)),
        legend.text = element_text(size=8),
        legend.position = c(0.92, 0.40)) 

ggsave(here("3.Report","bait_map.png"), width = 7, height = 4, dpi = 300, units = "in", device='png')


# Plot: 2019 County-level Business Acess to IT (BAIT) - Density -----
county_week_use %>% 
  select(county, it_budget_median) %>% 
  distinct() %>% 
  ggplot(aes(x = it_budget_median)) +
  geom_density() + 
  geom_vline(xintercept = q4, linetype="dashed", color = "blue") +
  annotate('text', x = q4+45000, y = 0.00007, label = "> High BAIT ($45,033)", color = "blue", size = 5)+
  #  geom_vline(xintercept = 46603, linetype="dashed", color = "orange") +
  #annotate('text', x = 46603+50000, y = 0.00005, label = "Orange County: 46603 USD", color = "orange", size = 5)+
  labs(x = "County-level median of IT Budget per Establishment (USD)", y = " Density", title = "2019 County-level Business Acess to IT (BAIT) - Density") +  
  theme_bw()

ggsave(here("3.Report","bait_density.png"), width = 7, height = 4, dpi = 300, units = "in", device='png')


# Plot: BAIT and Unemployment Rate - Model-free evidence ------------------

plot <- county_week %>% 
  select(month, county, stayweek, tre, initclaims_rate_regular,q4_high_it_budget_median) %>% 
  filter( !is.na(stayweek)) %>% 
  group_by(month, q4_high_it_budget_median) %>% 
  summarise(avg_initclaims_rate = mean(initclaims_rate_regular, na.rm = TRUE))


plot %>%
  ggplot(aes(x = month, y = avg_initclaims_rate,
             color =  factor(q4_high_it_budget_median)) ) +  
  geom_line(size = 1.3) + 
  scale_x_continuous(breaks = seq(1,10,1), 
                     labels = function(x)month.abb[x])+
  labs(x = "", y = "Rate %", 
       title = "2020 The Impact of BAIT on Unemployment Rate \n After Stay-at-home Enforcement  ")+
  scale_color_manual(name = "Business Access to IT (BAIT)", 
                     labels = c("Low", "Hight"),values=c( "red", "blue")) +
  theme_minimal() + 
  theme(plot.title = element_text(size = rel(1.2), hjust = 0.5, ),
        legend.title = element_text(size = rel(1)),
        legend.key.width= unit(1, 'cm'),
        legend.text = element_text(size=10, color = "#696969"),
        axis.text=element_text(size= 11),
        axis.title.y = element_text(size = rel(1.2), angle = 90),
        axis.title.x = element_text(size = rel(1.2)),
        plot.caption = element_text(size = rel(1), hjust = 0),
        legend.position = "top") +
  labs(caption = "Note: Unemployment rate =  Number of initial unemployment insurance (UI) claims per 100 people in the 2019 labor force.") +
  geom_vline(xintercept = 3,
             color =  "#191970", size=1.2, linetype="dashed") + 
  annotate("text", x = 1.8, y = 2.8, label = "Before", size = 4)+
  annotate("text", x = 6, y = 2.8, label = "After", size = 4) +
  annotate("text", x = 1.8, y = 1.5, label = "Stay-at-home \n enforcement", size = 4) +
  annotate("segment", x = 1, xend = 2.8, y = 3, yend = 3,
           arrow = arrow(ends = "both", angle = 90, length = unit(0.5,"cm")), size = 1) + 
  annotate("segment", x = 3.2, xend = 11, y = 3, yend = 3,
           arrow = arrow(ends = "both", angle = 90, length = unit(0.5,"cm")), size = 1) + 
  annotate("segment", x = 2, xend = 2.8, y = 1.8, yend =2.3 ,
           colour = "black", size = 1, arrow = arrow())

ggsave(here("3.Report","bait_unemployment.png"), width = 7, height = 4, dpi = 300, units = "in", device='png')

