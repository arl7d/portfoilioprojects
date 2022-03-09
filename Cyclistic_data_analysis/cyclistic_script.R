install.packages("tidyverse")
library(tidyverse)
library(lubridate)
library(ggplot2)

#load the data
tripdata <- read.csv("tripdata_cleaned_030822.csv")

View(tripdata)

str(tripdata)
glimpse(tripdata)

# convert date-time from character to datetime format
tripdata$started_at <- as.POSIXct(tripdata$started_at, 
                                  format="%Y-%m-%d %H:%M:%S")
tripdata$ended_at <- as.POSIXct(tripdata$ended_at, 
                                format="%Y-%m-%d %H:%M:%S")

# create new column to show ride length (duration)
tripdata$ride_length <- difftime(tripdata$ended_at,
                                 tripdata$started_at, 
                                 units = "mins")

# used below code to delete a column
tripdata <- select(tripdata, -c(ride_length))

# create a new column to show day of the week from started_at date
tripdata$start_day <- c("Sunday", "Monday", "Tuesday", 
                        "Wednesday", "Thursday", "Friday", 
                        "Saturday")[as.POSIXlt(tripdata$started_at)$wday + 1]

# check unique values from member_casual column
unique(tripdata$member_casual, incomparables = FALSE)
unique(tripdata$start_month, incomparables = FALSE)

# calculate mean ride length
mean(tripdata$ride_length)

# calculate max ride length
max(tripdata$ride_length) 
10905.97/60

# max ride length is 181.76 hours, seems odd? let's check the start & end time
sort_by_ride_length <- tripdata[order(-tripdata$ride_length),]

# use to delete a dataframe
rm(rides_type_month)

# based on the start & end dates, the ride type was "docked", data is ok

# remove duplicates
tripdata <- tripdata[!duplicated(tripdata),]

# check if there are still rows with headers (due to file combination)
headers <- filter(tripdata, member_casual == "member_casual")

# remove rows based on condition
tripdata <- tripdata[!(tripdata$ride_id=="ride_id"),]
# all header rows are now removed

# Export as CSV
write.csv(tripdata, "tripdata_cleaned_030822.csv", row.names = FALSE)

# create new column from extracted specific detail from start date
tripdata$start_month <- format(tripdata$started_at, "%B")
tripdata$start_year <- format(tripdata$started_at, "%Y")
tripdata$start_hour <- format(tripdata$started_at, "%H")

# check for negative duration
tripdata[(tripdata$ride_length_mins < 0),]

# remove rows with negative duration
tripdata <- tripdata[!(tripdata$ride_length < 0),]

# create new column with ride_length as numeric
tripdata$ride_length_mins <- as.numeric(tripdata$ride_length)

# dropped ride_length
tripdata <- select(tripdata, -c(ride_length))

# check for rows where bikes started from HQ QR, this is bike maintenance
tripdata[(tripdata$start_station_name == "HQ QR"),]
# none

# check all unique start_station_names
unique(tripdata$start_station_name, incomparables = FALSE)
# looks good

# descriptive analytics
summary(tripdata$ride_length_mins)
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 0.00     6.67    11.87    21.75    21.57 55944.15

# check all unique rideable_type
unique(tripdata$rideable_type, incomparables = FALSE)
# "classic_bike"  "electric_bike" "docked_bike" 

# look at data of docked bikes
tripdata[(tripdata$rideable_type == "docked_bike"),]

# compare members & casuals
aggregate(tripdata$ride_length_mins ~ tripdata$member_casual, FUN = mean)

# tripdata$member_casual tripdata$ride_length_mins
# 1                 casual                  31.92268
# 2                 member                  13.48570

aggregate(tripdata$ride_length_mins ~ tripdata$member_casual, FUN = median)

# tripdata$member_casual tripdata$ride_length_mins
# 1                 casual                 15.900000
# 2                 member                  9.483333

aggregate(tripdata$ride_length_mins ~ tripdata$member_casual, FUN = max)
aggregate(tripdata$ride_length_mins ~ tripdata$member_casual, FUN = min)

# let's see average ride time per member type
aggregate(tripdata$ride_length_mins ~ tripdata$start_day + 
            tripdata$member_casual, FUN = mean)

# re-arrange days of the week into correct order

tripdata$start_day <- ordered(tripdata$start_day, 
                              levels=c("Sunday", "Monday", "Tuesday", 
                                      "Wednesday", "Thursday", 
                                      "Friday", "Saturday"))

# re-arrange months of the year into correct order

tripdata$start_month <- ordered(tripdata$start_month, levels=month.name)



# analyze ridership data by type & weekday

tripdata %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n(), 
            average_duration = mean(ride_length_mins)) %>% 
  arrange(member_casual, weekday)

# let's visualize number of rides

tripdata %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n(), 
            average_duration = mean(ride_length_mins)) %>% 
  arrange(member_casual, weekday) %>% 
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title = "No. of Riders per rider type across the week")

# let's visualize average duration across the week

tripdata %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n(), 
            average_duration = mean(ride_length_mins)) %>% 
  arrange(member_casual, weekday) %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title = "Average duration per rider type across the week (in minutes)", 
       y = "Average duration in minutes")

# let's visualize number of rides per month

tripdata %>% 
  group_by(member_casual, start_month) %>% 
  summarise(number_of_rides = n(), 
            average_duration = mean(ride_length_mins)) %>% 
  arrange(member_casual, start_month) %>% 
  ggplot(aes(x = start_month, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title = "No. of Riders per rider type across the year") + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.6))

# let's visualize average duration across the year

tripdata %>% 
  group_by(member_casual, start_month) %>% 
  summarise(number_of_rides = n(), 
            average_duration = mean(ride_length_mins)) %>% 
  arrange(member_casual, start_month) %>% 
  ggplot(aes(x = start_month, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title = "Average duration per rider type across the year (in minutes)") + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.6))

# let's visualize number of rides per hour per day

tripdata %>% 
  group_by(member_casual, start_hour) %>% 
  summarise(number_of_rides = n(), 
            average_duration = mean(ride_length_mins)) %>% 
  arrange(member_casual, start_hour) %>% 
  ggplot(aes(x = start_hour, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title = "No. of Riders per rider type per hour")

# create a new dataframe to summarize number of rides per type & month

rides_type_month <- tripdata %>% 
  group_by(member_casual, start_month) %>% 
  summarise(number_of_rides = n())

# create a new dataframe to summarize number of rides per month

rides_month <- tripdata %>% 
  group_by(start_month) %>% 
  summarise(number_of_rides = n())

# install & load readxl

install.packages("readxl")
library(readxl)

# import excel data for chicago temp

chicago_temp <- read_excel("chicago_temp.xlsx", sheet = "data")

# install & load data.table

install.packages("data.table")
library(data.table)

# convert chicago temp data from wide to long using "melt" function

chicago_temp_long <- melt(setDT(chicago_temp), id.vars = "Year", 
                          variable.name = "month")

# change column header of temp df from "value" to "temp"

chicago_temp_long <- chicago_temp_long %>% rename(temp = value)

# change column header of rides df from "start_month" to "month"

rides_month <- rides_month %>% rename(month = start_month)

# create new dataframe with grouped temp data by month

chicago_ave_temp <- chicago_temp_long %>% 
  group_by(month) %>% 
  summarise(average_temp = mean(temp))

# combine temp data with riders per month

temp_rides_merged <- merge(rides_month, chicago_ave_temp)

# visualize relationship of rides to temp

ggplot(temp_rides_merged, aes(x = average_temp, y = number_of_rides)) + 
  geom_point() + 
  geom_smooth() +
  labs(title="Chicago temperature vs No. of riders")

# Export as CSV
write.csv(temp_rides_merged, "temp_rides_merged.csv", row.names = FALSE)

# visualize bike type per rider type

tripdata[!(tripdata$rideable_type == "docked_bike"),] %>% 
  group_by(rideable_type, member_casual) %>% 
  summarise(number_of_rides = n()) %>% 
  ggplot(aes(x = member_casual, y = number_of_rides, fill = rideable_type)) +
  geom_col(position = "dodge") +
  scale_fill_manual("legend", values = c("classic_bike" = "blue", 
                                         "electric_bike" = "orange"))+
  labs(title= "Bike type per rider type")

# filter data where ride duration is greater than 24 hours 
#(which is roughly at 1496 mins), but also are not docked
# this is considering that when a bike is not returned after 24 hours,
# the renter's credit card can be charged $1200

more_than_24h <- filter(tripdata, ride_length_mins > 1496, 
                        rideable_type != "docked_bike")

# check casuals vs members with more than 24 hrs rentals

ggplot(more_than_24h, aes(member_casual, fill=member_casual)) +
  geom_bar() + 
  labs(title = "Count of >24hrs rental penalties")

# calculate how long would a casual rent a bike where getting an
# annual pass would be more economical
# single ride is $3.30 for 30 mins, then $0.15 per extra minute
# Monthly subscription is $9, $9-$3.3 = $5.70
# $5.70/$0.15 = 38
# this means that after 38 more minutes on the single ride, 
# it would already be cheaper to just get a monthly pass
# 30 mins + 38 mins = 68 mins
# Thus, let's check casual rides longer than 68 mins

casual_gtr_68 <- filter(tripdata, member_casual == "casual", 
                       rideable_type != "docked_bike",
                       ride_length_mins > 68)

# count the number of casual rides > than 68 mins that are not docked

count(casual_gtr_68)

# count total number of casuals that are not docked

count(filter(tripdata, member_casual == "casual", 
             rideable_type != "docked_bike")) 

# percentage of > 68 mins

(count(casual_gtr_68) / count(filter(tripdata, member_casual == "casual", 
                                    rideable_type != "docked_bike"))) * 100

# result is 5.37%
# 5.37% of all casual rides for the 12 months are greater than 68 mins
# which totals to 119,764 rides





