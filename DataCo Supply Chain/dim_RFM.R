getwd()
setwd("~/Desktop/R Sample CRM")

data.df <- read.csv("rfm_BI.csv")

library(dplyr) 
library(tidyr)
library(car)

variable.names(data.df)
head(data.df,20)
str(data.df)
summary(data.df)

#Remove NA if there is any
data.df <- data.df[complete.cases(data.df),]

#Change the date structure of data.df$Date into Date
library(lubridate)
data.df$Date <- mdy(data.df$Date)

#Removing the unnecessary column
data.df <- data.df %>%
  select(-Count.Name)

#Frequency
rfm <- data.df %>%
  group_by(Customer.Name) %>%
  count(Customer.Name)

#Monetary
total <-  data.df%>%
  group_by(Customer.Name)%>%
  summarise(sum(Sales))

rfm <- total %>% left_join(rfm) %>% rename(total = `sum(Sales)`)

#recency
recency <- data.df %>%
  group_by(Customer.Name) %>%
  summarise(last_date = max(Date))

rfm <- recency %>% left_join(rfm) 

analysis_date <- lubridate::as_date('2018-01-31')

rfm <- rfm %>%
  mutate(most_recent = analysis_date - rfm$last_date)

#Change most_recent to interger
rfm$most_recent <- as.integer(rfm$most_recent)

####SCORING SYSTEMS####
summary(rfm)
str(rfm)

#Finding frequency score in RFM method

#Min = 1, Max = 744. Since 23884 is the outlier of the dataset, we will use the next highest value to determine the score
#1 - 148 = 1, 148 - 296 = 2, 297 - 444 = 3, 444 - 595 = 4, >595 = 5

#quantile 20/40/60/80 won't work as median value = 1

rfm<- rfm %>%
  mutate(frequency_points = case_when(
    between(n, 1, 148) ~ "1",
    between(n, 149, 296) ~ "2",
    between(n, 297, 444) ~ "3",
    between(n, 445, 595) ~ "4",
    TRUE ~ "5"
  ))

rfm %>% count(frequency_points)
#Finding monetary score in RFM method

#dividing the monetary value using 20/40/60/80 quantile. 

quantile(rfm$total,.20)
quantile(rfm$total,.40)
quantile(rfm$total,.60)
quantile(rfm$total,.80)

rfm<- rfm %>%
  mutate(monetary_score = case_when(
    between(total, 1, 165) ~ "1",
    between(total, 166, 328) ~ "2",
    between(total, 329, 1110) ~ "3",
    between(total, 1201, 3100) ~ "4",
    TRUE ~ "5"
  ))

rfm %>% count(monetary_score)


#Finding recency score in RFM Method
#The higher the number, the lower the score. It means that the customer didn't purchase recently

summary(rfm)

#Min = 0, Max =1125. There is no wide gap between the highest and the 2nd highest scores. 
#0-225 = 1, 226 - 450 = 2, 451 - 675 = 3, 676 - 900 = 4, >901 = 5

rfm<- rfm %>%
  mutate(recency_score = case_when(
    between(most_recent, 0, 225) ~ "5",
    between(most_recent, 226, 450) ~ "4",
    between(most_recent, 451, 675) ~ "3",
    between(most_recent, 676, 900) ~ "2",
    TRUE ~ "1"
  ))
rfm %>% count(recency_score)

#Ranking score

#Converting all scores into intergeer
rfm <- rfm %>%
  mutate(frequency_points = as.integer(frequency_points),
         monetary_score = as.integer(monetary_score),
         recency_score = as.integer(recency_score))

rfm$rfm_score<- round(rowMeans(rfm[, c(6,7,8)], na.rm = TRUE), 2)

#Create Customer Segments
summary(rfm$rfm_score)

rfm <- rfm %>%
  mutate(customer_segments = cut(rfm_score,
                                 breaks = c(0,1.83, 2.66, 3.33, 4.32, 5),
                                 labels = c("lost","at risk", "promising", "loyal", "champions"))) 

top20percent <- rfm %>%
  filter(rfm_score >=quantile(rfm_score,.80)) %>%
  distinct(Customer.Name, customer_segments)

write.csv(top20percent, "top20.csv")

#export to csv#
write.csv(rfm, "rfm_BI.csv")