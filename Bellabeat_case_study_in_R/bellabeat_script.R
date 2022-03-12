# %% [markdown]
# # Bellabeat Case Study in R
# 
# #### Google Data Analytics Course 2nd Capstone project
# 
# * Author: Thomas Karlo Blanco
# * Start date: 03-10-2022
# 
# ## Scenario: 
# Bellabeat needs help on their marketing strategy through analysing the publicly available data from non-bellabeat smart devices. We'll be looking into the data available and see what additional features we can add to the device to help increase sales.
# 
#     
# ## Below are the deliverables:
#     1. A clear summary of the business task
#     2. A description of all data sources used
#     3. Documentation of any cleaning or manipulation of data
#     4. A summary of your analysis
#     5. Supporting visualizations and key findings
#     6. Your top high-level content recommendations based on your analysis

# %% [markdown]
# ## Clear summary of the business task:
# 
# Primary goal is to use the data provided to be able to:
# 1. Find trends in usage of non-bellabeat smart devices
# 2. How can these trends apply to Bellabeat customers?
# 3. How could these trends help influence Bellabeat marketing strategy?

# %% [markdown]
# ## Description of all data sources used
# 
# * Data needed is available in Kaggle through this link: https://www.kaggle.com/arashnic/fitbit
# * Format is CSV and is ranging from activities, calories, steps taken, heart rate, etc..
# * These have been made available to the public c/o https://www.kaggle.com/arashnic via CCO: Public domain

# %% [markdown]
# ## Documentation of any cleaning or manipulation of data
# 
# Let's now look into the data that we have:

# %% [markdown]
# ## Loading the required packages:

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:25:46.420759Z","iopub.execute_input":"2022-03-12T21:25:46.423051Z","iopub.status.idle":"2022-03-12T21:25:47.714057Z"}}
library(tidyverse)
library(lubridate)

# %% [markdown]
# ## Importing data:

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:25:51.632386Z","iopub.execute_input":"2022-03-12T21:25:51.663788Z","iopub.status.idle":"2022-03-12T21:25:53.350523Z"}}
daily_activity <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/dailyActivity_merged.csv")
daily_calories <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/dailyCalories_merged.csv")
daily_Intensities <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/dailyIntensities_merged.csv")
weight_log <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/weightLogInfo_merged.csv")
sleep_day <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/sleepDay_merged.csv")
heartrate <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/heartrate_seconds_merged.csv")
minute_cal <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/minuteCaloriesNarrow_merged.csv")
minute_met <- read_csv("../input/fitbit/Fitabase Data 4.12.16-5.12.16/minuteMETsNarrow_merged.csv")

# %% [markdown]
# ## Formating the Date & Time columns on necessary dataframes:

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:25:55.693528Z","iopub.execute_input":"2022-03-12T21:25:55.695199Z","iopub.status.idle":"2022-03-12T21:26:03.355004Z"}}
# change ActivityDate type from chr to date
daily_activity$ActivityDate <- mdy(daily_activity$ActivityDate)

# convert Date format to standard date & 24 hr time on weight_log table
weight_log$Date <- as.POSIXct(weight_log$Date, format = "%m/%d/%Y %I:%M:%S %p")

# convert Date format to standard date & 24 hr time on sleep_day table
sleep_day$SleepDay <- as.POSIXct(sleep_day$SleepDay, format = "%m/%d/%Y %I:%M:%S %p")

# change format for ActivityMinute on minute_cal df
minute_cal$ActivityMinute <- as.POSIXct(minute_cal$ActivityMinute, format = "%m/%d/%Y %I:%M:%S %p")

# change format for Time column on heartrate df
heartrate$Time <- as.POSIXct(heartrate$Time, format = "%m/%d/%Y %I:%M:%S %p")

# %% [markdown]
# ## Feature engineering:
# 
# creating new columns from existing ones (ie: extracting days of the week)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-12T21:26:06.476286Z","iopub.execute_input":"2022-03-12T21:26:06.477885Z","iopub.status.idle":"2022-03-12T21:26:06.515069Z"}}
# creating a new column for day of the week
daily_activity$day <- c("Sunday", "Monday", "Tuesday", 
                        "Wednesday", "Thursday", "Friday", 
                        "Saturday")[as.POSIXlt(daily_activity$ActivityDate)$wday + 1]

# setting the correct order of days
daily_activity$day <- ordered(daily_activity$day, 
                              levels=c("Sunday", "Monday", "Tuesday", 
                                      "Wednesday", "Thursday", 
                                      "Friday", "Saturday"))

# create new column (date_only) on weight_log df
weight_log$Date_only <- as.Date(weight_log$Date)

# create new column (ActivityDate) on sleep_day df then removing SleepDay
sleep_day$ActivityDate <- as.Date(sleep_day$SleepDay)
sleep_day <- select(sleep_day, -c(SleepDay))

# %% [markdown]
# ## Renaming certain columns for commonality & clarity:

# %% [code] {"execution":{"iopub.status.busy":"2022-03-12T21:26:09.630485Z","iopub.execute_input":"2022-03-12T21:26:09.631997Z","iopub.status.idle":"2022-03-12T21:26:09.660750Z"}}
# rename Date_only to ActivityDate on weight_log df
weight_log <- weight_log %>% rename(ActivityDate = Date_only)

# rename Date_only to ActivityDate on weight_log df
weight_log <- weight_log %>% rename(Date_Time = Date)

# rename Time to Date_Time on heartrate df
heartrate <- heartrate %>% rename(Date_Time = Time)

# rename Value column to Heartrate on heartrate column
heartrate <- heartrate %>% rename(Heartrate = Value)

# rename ActivityMinute to Time on minute_cal df
minute_cal <- minute_cal %>% rename(Date_Time = ActivityMinute)

# %% [markdown]
# ## Verifying dataframes are ok

# %% [code] {"execution":{"iopub.status.busy":"2022-03-12T21:32:36.612492Z","iopub.execute_input":"2022-03-12T21:32:36.614279Z","iopub.status.idle":"2022-03-12T21:32:36.646159Z"}}
head(daily_activity)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-12T21:32:38.783500Z","iopub.execute_input":"2022-03-12T21:32:38.785157Z","iopub.status.idle":"2022-03-12T21:32:38.807952Z"}}
head(sleep_day)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-12T21:32:40.431229Z","iopub.execute_input":"2022-03-12T21:32:40.432863Z","iopub.status.idle":"2022-03-12T21:32:40.459499Z"}}
head(weight_log)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-12T21:32:41.850321Z","iopub.execute_input":"2022-03-12T21:32:41.852133Z","iopub.status.idle":"2022-03-12T21:32:41.875293Z"}}
head(minute_cal)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-12T21:32:43.617335Z","iopub.execute_input":"2022-03-12T21:32:43.618906Z","iopub.status.idle":"2022-03-12T21:32:43.641148Z"}}
head(heartrate)

# %% [markdown]
# ## Summarizing Data:
# Looking into the quartiles, min, mean & max values of certain features on our dataframes

# %% [code] {"execution":{"iopub.status.busy":"2022-03-12T21:34:16.844367Z","iopub.execute_input":"2022-03-12T21:34:16.846001Z","iopub.status.idle":"2022-03-12T21:34:19.617880Z"}}
daily_activity %>%  
  select(TotalSteps,
         TotalDistance,
         SedentaryMinutes) %>%
  summary()

sleep_day %>%  
  select(TotalSleepRecords,
  TotalMinutesAsleep,
  TotalTimeInBed) %>%
  summary()

weight_log %>%  
  select(WeightPounds,
         BMI) %>%
  summary()

minute_cal %>%  
  select(Calories) %>%
  summary()

heartrate %>%  
  select(Heartrate) %>%
  summary()

# %% [markdown]
# ### Insights from summary:
# 
# 1. Average total steps only at 7.6k, this is below the number of recommended steps per day for an active lifestyle. Read further on this link: https://www.10000steps.org.au/articles/counting-steps/
# 2. Average sedentary minutes is at 991. Daily sedentary time of 600 minutes per day or more can increase the risk of chronic disease. Link: https://baptisthealth.net/baptist-health-news/how-much-exercise-will-offset-10-or-more-hours-of-sitting/#:~:text=The%20research%20findings%20based%20on,week%20to%20counter%20sedentary%20behavior.
# 3. Recommended sleep time is 7 or more hours per day, based on our data, the average sleep time is 419.5 minutes, or roughly 7 hours. https://www.mayoclinic.org/healthy-lifestyle/adult-health/expert-answers/how-many-hours-of-sleep-are-enough/faq-20057898
# 4. Recommended BMI is 18.5 to 24.9. Looking at our data,  the average is 25.19, which is a little higher than recommended. https://www.medicalnewstoday.com/articles/323446#body-mass-index-bmi

# %% [markdown]
# ## Creating additional separate tables:

# %% [code] {"execution":{"iopub.status.busy":"2022-03-12T21:35:26.555706Z","iopub.execute_input":"2022-03-12T21:35:26.557234Z","iopub.status.idle":"2022-03-12T21:35:26.589537Z"}}
daily_weight <- weight_log %>% group_by(Id,ActivityDate) %>% summarise(ave_weight_lbs = mean(WeightPounds))

# %% [code] {"execution":{"iopub.status.busy":"2022-03-12T21:37:42.324600Z","iopub.execute_input":"2022-03-12T21:37:42.326169Z","iopub.status.idle":"2022-03-12T21:37:42.351976Z"}}
head(daily_weight)

# %% [markdown]
# ## Merging dataframes:
# also ran some formatting of certain dataframes

# %% [code] {"execution":{"iopub.status.busy":"2022-03-12T21:43:16.861750Z","iopub.execute_input":"2022-03-12T21:43:16.863469Z","iopub.status.idle":"2022-03-12T21:43:43.732039Z"}}
# merge sleep_day & daily activity by Id & ActivityDate
combined_data <- merge(sleep_day, daily_activity, by=c("Id","ActivityDate"))

# merge sleep_day,daily activity & daily_weight by Id & ActivityDate
combined_v2 <- merge(combined_data, daily_weight, by=c("Id","ActivityDate"))

# merge daily activity & daily_weight by Id & ActivityDate
combined_v3 <- merge(daily_activity, daily_weight, by=c("Id","ActivityDate"))
# combined_v3 has activity & weight data, so far.. 
# we have 2 participants  that has complete data for a month. 6962181067 & 8877689391
#unfortunately, participant# 8877689391 has weight info & daily activities, but does not have sleep_day info

# merge heartrate & minute_cal dfs
heartrate_minute_cal <- merge(heartrate, minute_cal, by=c("Id","Date_Time"))

# create a separate dataframe for participant# 6962181067 because, this user is the only one that has complete data for all datasets
user_67 <- filter(combined_v2, Id == 6962181067)

# code below no longer needed
# heartrate_minute_cal$Time <- as.POSIXct(heartrate_minute_cal$Time, format = "%m/%d/%Y %I:%M:%S %p")

# create hour column on heartrate_minute_cal df
heartrate_minute_cal$hour <- format(heartrate_minute_cal$Date_Time, "%H")

# %% [markdown]
# ## Visualizations:
# Now let's create visualizations from the dataframes that we have cleaned & merged.

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:39:29.021721Z","iopub.execute_input":"2022-03-12T21:39:29.023291Z","iopub.status.idle":"2022-03-12T21:39:29.457666Z"}}
ave_daily_steps <- daily_activity %>% group_by(day) %>% summarise(ave_steps=mean(TotalSteps))
ggplot(ave_daily_steps, aes(x=day, y=ave_steps)) + geom_col() + coord_cartesian(ylim= c(6000,8500))

# %% [markdown]
# Most number of steps are made during Tuesdays & Saturdays, least during Sundays

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:39:32.203912Z","iopub.execute_input":"2022-03-12T21:39:32.205461Z","iopub.status.idle":"2022-03-12T21:39:32.453535Z"}}
ave_daily_cal <- daily_activity %>% group_by(day) %>% summarise(ave_cal=mean(Calories))
ggplot(ave_daily_cal, aes(x=day, y=ave_cal)) + geom_col() + coord_cartesian(ylim= c(2100,2400))

# %% [markdown]
# Most number of calories burned are during Tuesdays & Saturdays, which is aligned with what we have seen with Total Steps. But least calories burned during Thursdays

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:39:34.911793Z","iopub.execute_input":"2022-03-12T21:39:34.913509Z","iopub.status.idle":"2022-03-12T21:39:35.122354Z"}}
daily_activity %>% group_by(ActivityDate) %>% summarise(ave_steps = mean(TotalSteps)) %>%
ggplot(aes(x = ActivityDate, y = ave_steps)) + geom_line()

# %% [markdown]
# This aligns with what we are seeing with our summary that average daily steps are around 7.6k.

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:39:45.781174Z","iopub.execute_input":"2022-03-12T21:39:45.782803Z","iopub.status.idle":"2022-03-12T21:39:47.021415Z"}}
ggplot(data=daily_activity, aes(x=TotalSteps, y=SedentaryMinutes)) + geom_point() + geom_smooth()

# %% [markdown]
# On the left side of our plot, where most of the data are located, it is clearly showing a negative correlation between total steps & sedentary minutes. Which is expected.

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:39:50.222306Z","iopub.execute_input":"2022-03-12T21:39:50.223893Z","iopub.status.idle":"2022-03-12T21:39:50.512089Z"}}
ggplot(data=sleep_day, aes(x=TotalMinutesAsleep, y=TotalTimeInBed)) + geom_point() + geom_smooth()

# %% [markdown]
# Points above the 45 degree correlation line indicate the times that the participants where laying in bed but were not asleep. This means that we are seeing cases where the participants could already be lying in bed but are still not sleepy.

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:40:30.148603Z","iopub.execute_input":"2022-03-12T21:40:30.150225Z","iopub.status.idle":"2022-03-12T21:40:30.416003Z"}}
ggplot(combined_data, aes(x=TotalMinutesAsleep, y=TotalSteps)) + geom_point() + geom_smooth()

# %% [markdown]
# No significant correlation with Total minutes asleep & total steps

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:40:34.998657Z","iopub.execute_input":"2022-03-12T21:40:35.000310Z","iopub.status.idle":"2022-03-12T21:40:35.276772Z"}}
ggplot(combined_data, aes(x=Calories, y=TotalSteps)) + geom_point() + geom_smooth() + labs(title="Calories burned vs Total Steps")

# %% [markdown]
# We are seeing correlation with Calories burned with TotalSteps taken, which is expected.

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:41:08.797515Z","iopub.execute_input":"2022-03-12T21:41:08.799245Z","iopub.status.idle":"2022-03-12T21:41:08.997320Z"}}
ggplot(user_67,aes(x=ActivityDate)) + 
geom_line(aes(y=ave_weight_lbs))

# %% [markdown]
# Because User_67 did have complete weight data for the whole date range, we can plot its trend. 
# User_67's weight went down from 138 to 135 in a month but went back up again on May 9th

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:41:12.145293Z","iopub.execute_input":"2022-03-12T21:41:12.146908Z","iopub.status.idle":"2022-03-12T21:41:12.397230Z"}}
ggplot(user_67,aes(x=ActivityDate)) + 
geom_col(aes(y=SedentaryMinutes/5)) + 
geom_line(aes(y=ave_weight_lbs)) + 
scale_y_continuous(name = "Ave_weight", sec.axis = sec_axis(trans=~.*5, name="Sedentary_minutes"))

# %% [markdown]
# Checking user_67's sedentary minutes, no sudden increase in on May 9. The weight increase could have been caused by other reasons.

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:41:17.984445Z","iopub.execute_input":"2022-03-12T21:41:17.986165Z","iopub.status.idle":"2022-03-12T21:41:28.704559Z"}}
ggplot(heartrate_minute_cal, aes(x=Heartrate, y=Calories)) + geom_point()

# %% [markdown]
# We are seeing correlation between heartrate & calories, which is expected.

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:45:14.294800Z","iopub.execute_input":"2022-03-12T21:45:14.296874Z","iopub.status.idle":"2022-03-12T21:45:14.659304Z"}}
heartrate_minute_cal %>% 
group_by(hour) %>% 
summarise(ave_heartrate_by_hour = mean(Heartrate)) %>% 
ggplot(aes(x=hour, y=ave_heartrate_by_hour)) + 
geom_col() +
coord_cartesian(ylim= c(50,85))

# %% [markdown]
# Looking into the participants' heartrates across the whole day. It peaks at around 10am & 6pm, lowest at around 4am

# %% [code] {"jupyter":{"outputs_hidden":false},"execution":{"iopub.status.busy":"2022-03-12T21:45:17.406359Z","iopub.execute_input":"2022-03-12T21:45:17.408216Z","iopub.status.idle":"2022-03-12T21:45:17.745740Z"}}
heartrate_minute_cal %>% 
group_by(hour) %>% 
summarise(ave_cal_by_hour = mean(Calories)) %>% 
ggplot(aes(x=hour, y=ave_cal_by_hour)) + 
geom_col()

# %% [markdown]
# Same peaks & lows with calories burned, which is expected.

# %% [markdown]
# ## Recommendations:
# 
# 1. Inline with the 10k steps daily goal, it would be good to have an indicator in the smart wearable device if this has been reached. Either through a symbol on the screen, or a certain light indicator in the device.
# 
# 2. Regarding sedentary minutes, once the 600 minute daily sedentary mark has been reached, it would be good to have an alert that will notify the user to be more active throughout the day.
# 
# 3. About sleep time, it would be good to have a sleep notification to help set a routine sleep time for the users, then have an indicator on the device if the minimal 7 hour sleep time has already been reached.
# 
# 4. If possible, it would be good if the device would be able to track the least active day of the week, and send notifications during that day to encourage the user to be more active during that day.
# 
# 5. We are seeing that the higher the heartrate, the more calories burned. With this, it would be good to have something similar to "mood lighting" on the device and would turn to a color based on the heartrate of the user. With this, while the user is exercising, having a visual feedback of the user's heart rate can be a form of encouragement to continue the high intensity workout, which would burn more calories.
# 
# 6. Another good capability of the device is to be able to track the most active time of the day. When this time of the day comes, the device can pop-up a notification for the user to start working out. This can support building a daily workout routine.
