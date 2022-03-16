# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.219748Z","iopub.execute_input":"2022-03-16T19:28:38.220073Z","iopub.status.idle":"2022-03-16T19:28:38.233963Z","shell.execute_reply.started":"2022-03-16T19:28:38.22004Z","shell.execute_reply":"2022-03-16T19:28:38.232972Z"}}
# This Python 3 environment comes with many helpful analytics libraries installed
# It is defined by the kaggle/python Docker image: https://github.com/kaggle/docker-python
# For example, here's several helpful packages to load

import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)
import matplotlib.dates as mdates
import numpy as np

# Input data files are available in the read-only "../input/" directory
# For example, running this (by clicking run or pressing Shift+Enter) will list all files under the input directory

import os
for dirname, _, filenames in os.walk('/kaggle/input'):
    for filename in filenames:
        print(os.path.join(dirname, filename))

# You can write up to 20GB to the current directory (/kaggle/working/) that gets preserved as output when you create a version using "Save & Run All" 
# You can also write temporary files to /kaggle/temp/, but they won't be saved outside of the current session

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.235942Z","iopub.execute_input":"2022-03-16T19:28:38.236489Z","iopub.status.idle":"2022-03-16T19:28:38.295416Z","shell.execute_reply.started":"2022-03-16T19:28:38.236452Z","shell.execute_reply":"2022-03-16T19:28:38.294426Z"}}
sales = pd.read_csv("/kaggle/input/sales-forecasting/train.csv")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.296841Z","iopub.execute_input":"2022-03-16T19:28:38.297161Z","iopub.status.idle":"2022-03-16T19:28:38.323199Z","shell.execute_reply.started":"2022-03-16T19:28:38.297116Z","shell.execute_reply":"2022-03-16T19:28:38.322167Z"}}
sales.head()

# %% [markdown]
# ### Viz list:
# 1. sales over time
# 2. category vs sales
# 3. sub-category vs sales
# 4. state vs sales
# 5. city vs sales
# 6. segment vs sales
# 7. top customers
# 8. count of shipmodes
# 9. region vs sales
# 10. leadtime histogram

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.32467Z","iopub.execute_input":"2022-03-16T19:28:38.325634Z","iopub.status.idle":"2022-03-16T19:28:38.351588Z","shell.execute_reply.started":"2022-03-16T19:28:38.325584Z","shell.execute_reply":"2022-03-16T19:28:38.3509Z"}}
sales.describe()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.35384Z","iopub.execute_input":"2022-03-16T19:28:38.354098Z","iopub.status.idle":"2022-03-16T19:28:38.383113Z","shell.execute_reply.started":"2022-03-16T19:28:38.354064Z","shell.execute_reply":"2022-03-16T19:28:38.382161Z"}}
sales.info()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.384357Z","iopub.execute_input":"2022-03-16T19:28:38.38508Z","iopub.status.idle":"2022-03-16T19:28:38.389762Z","shell.execute_reply.started":"2022-03-16T19:28:38.385041Z","shell.execute_reply":"2022-03-16T19:28:38.389089Z"}}
# replacing the spaces in the column names to underscore
sales.columns = sales.columns.str.replace(' ','_')

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.391049Z","iopub.execute_input":"2022-03-16T19:28:38.391436Z","iopub.status.idle":"2022-03-16T19:28:38.428913Z","shell.execute_reply.started":"2022-03-16T19:28:38.391399Z","shell.execute_reply":"2022-03-16T19:28:38.42797Z"}}
# converting the dates from string to date format
sales["Order_Date"] = pd.to_datetime(sales["Order_Date"], dayfirst = True).dt.date
sales["Ship_Date"] = pd.to_datetime(sales["Ship_Date"], dayfirst = True).dt.date

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.430284Z","iopub.execute_input":"2022-03-16T19:28:38.43067Z","iopub.status.idle":"2022-03-16T19:28:38.47062Z","shell.execute_reply.started":"2022-03-16T19:28:38.430623Z","shell.execute_reply":"2022-03-16T19:28:38.469935Z"}}
# creating a new column to show leadtime, which is the difference between the "ship_date" and "order_date"
sales["Leadtime"] = sales["Ship_Date"] - sales["Order_Date"]

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.471852Z","iopub.execute_input":"2022-03-16T19:28:38.472484Z","iopub.status.idle":"2022-03-16T19:28:38.489962Z","shell.execute_reply.started":"2022-03-16T19:28:38.472433Z","shell.execute_reply":"2022-03-16T19:28:38.489078Z"}}
sales["Month"] = pd.DatetimeIndex(sales["Order_Date"]).month
sales["Year"] = pd.DatetimeIndex(sales["Order_Date"]).year

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.491237Z","iopub.execute_input":"2022-03-16T19:28:38.491748Z","iopub.status.idle":"2022-03-16T19:28:38.500832Z","shell.execute_reply.started":"2022-03-16T19:28:38.49171Z","shell.execute_reply":"2022-03-16T19:28:38.499861Z"}}
# sum group by order_date
sales.groupby("Year")["Sales"].sum()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.501897Z","iopub.execute_input":"2022-03-16T19:28:38.502448Z","iopub.status.idle":"2022-03-16T19:28:38.510428Z","shell.execute_reply.started":"2022-03-16T19:28:38.502415Z","shell.execute_reply":"2022-03-16T19:28:38.509655Z"}}
import matplotlib.pyplot as plt

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.511459Z","iopub.execute_input":"2022-03-16T19:28:38.512307Z","iopub.status.idle":"2022-03-16T19:28:38.704051Z","shell.execute_reply.started":"2022-03-16T19:28:38.512249Z","shell.execute_reply":"2022-03-16T19:28:38.703378Z"}}
sales.groupby("Year")["Sales"].sum().plot()
plt.ylabel("Sales")
plt.title("Trend of Total sales per year")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.705186Z","iopub.execute_input":"2022-03-16T19:28:38.705547Z","iopub.status.idle":"2022-03-16T19:28:38.714179Z","shell.execute_reply.started":"2022-03-16T19:28:38.705517Z","shell.execute_reply":"2022-03-16T19:28:38.713124Z"}}
# average sales group by month
sales.groupby("Month")["Sales"].mean()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.719515Z","iopub.execute_input":"2022-03-16T19:28:38.720431Z","iopub.status.idle":"2022-03-16T19:28:38.983303Z","shell.execute_reply.started":"2022-03-16T19:28:38.720367Z","shell.execute_reply":"2022-03-16T19:28:38.982553Z"}}
sales.groupby("Month")["Sales"].mean().plot.bar()
plt.ylabel("Sales")
plt.title("Average Sales for each month")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.984477Z","iopub.execute_input":"2022-03-16T19:28:38.98489Z","iopub.status.idle":"2022-03-16T19:28:38.994558Z","shell.execute_reply.started":"2022-03-16T19:28:38.984837Z","shell.execute_reply":"2022-03-16T19:28:38.993929Z"}}
# average sales grouped by state
sales.groupby("State")["Sales"].sum().sort_values(ascending=False).head(10)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:38.995711Z","iopub.execute_input":"2022-03-16T19:28:38.996259Z","iopub.status.idle":"2022-03-16T19:28:39.254218Z","shell.execute_reply.started":"2022-03-16T19:28:38.996223Z","shell.execute_reply":"2022-03-16T19:28:39.253293Z"}}
plt.figure(figsize=(10,5))
sales.groupby("State")["Sales"].sum().sort_values(ascending=False).head(10).plot.bar()
plt.ylabel("Sales")
plt.title("Top 10 States in terms of Sales")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:39.255327Z","iopub.execute_input":"2022-03-16T19:28:39.25554Z","iopub.status.idle":"2022-03-16T19:28:39.26717Z","shell.execute_reply.started":"2022-03-16T19:28:39.255513Z","shell.execute_reply":"2022-03-16T19:28:39.266102Z"}}
# average sales grouped by City
sales.groupby("City")["Sales"].sum().sort_values(ascending=False).head(10)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:39.268958Z","iopub.execute_input":"2022-03-16T19:28:39.269842Z","iopub.status.idle":"2022-03-16T19:28:39.539363Z","shell.execute_reply.started":"2022-03-16T19:28:39.269793Z","shell.execute_reply":"2022-03-16T19:28:39.538336Z"}}
plt.figure(figsize=(10,5))
sales.groupby("City")["Sales"].sum().sort_values(ascending=False).head(10).plot.bar()
plt.ylabel("Sales")
plt.title("Top 10 Cities in terms of Sales")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:39.540887Z","iopub.execute_input":"2022-03-16T19:28:39.541223Z","iopub.status.idle":"2022-03-16T19:28:39.55393Z","shell.execute_reply.started":"2022-03-16T19:28:39.54118Z","shell.execute_reply":"2022-03-16T19:28:39.552613Z"}}
# average sales grouped by category
sales.groupby("Category")["Sales"].sum().sort_values(ascending=False)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:39.555552Z","iopub.execute_input":"2022-03-16T19:28:39.556438Z","iopub.status.idle":"2022-03-16T19:28:39.774285Z","shell.execute_reply.started":"2022-03-16T19:28:39.556383Z","shell.execute_reply":"2022-03-16T19:28:39.773524Z"}}
sales.groupby("Category")["Sales"].sum().sort_values().plot.barh()
plt.ylabel("Sales")
plt.title("Total Sales per category")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:39.775439Z","iopub.execute_input":"2022-03-16T19:28:39.775817Z","iopub.status.idle":"2022-03-16T19:28:40.105465Z","shell.execute_reply.started":"2022-03-16T19:28:39.775779Z","shell.execute_reply":"2022-03-16T19:28:40.104447Z"}}
plt.figure(figsize=(10,10))
sales.groupby("Sub-Category")["Sales"].sum().sort_values().plot.barh()
plt.ylabel("Sales")
plt.title("Total Sales per Sub-category")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:40.106985Z","iopub.execute_input":"2022-03-16T19:28:40.107317Z","iopub.status.idle":"2022-03-16T19:28:40.124313Z","shell.execute_reply.started":"2022-03-16T19:28:40.107284Z","shell.execute_reply":"2022-03-16T19:28:40.123476Z"}}
# average sales grouped by state then city
sales.groupby(["State","City"])["Sales"].sum().sort_values(ascending=False)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:40.12598Z","iopub.execute_input":"2022-03-16T19:28:40.126614Z","iopub.status.idle":"2022-03-16T19:28:40.136918Z","shell.execute_reply.started":"2022-03-16T19:28:40.126565Z","shell.execute_reply":"2022-03-16T19:28:40.135962Z"}}
# average sales grouped by segment
sales.groupby("Segment")["Sales"].sum().sort_values(ascending=False)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:40.138074Z","iopub.execute_input":"2022-03-16T19:28:40.138302Z","iopub.status.idle":"2022-03-16T19:28:40.354644Z","shell.execute_reply.started":"2022-03-16T19:28:40.138274Z","shell.execute_reply":"2022-03-16T19:28:40.353544Z"}}
sales.groupby("Segment")["Sales"].sum().sort_values().plot.barh()
plt.ylabel("Sales")
plt.title("Total Sales per Segment")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:40.35636Z","iopub.execute_input":"2022-03-16T19:28:40.356796Z","iopub.status.idle":"2022-03-16T19:28:40.373354Z","shell.execute_reply.started":"2022-03-16T19:28:40.356723Z","shell.execute_reply":"2022-03-16T19:28:40.372462Z"}}
# average sales grouped by Customer
sales.groupby("Customer_Name")["Sales"].sum().sort_values(ascending=False).head()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:40.37515Z","iopub.execute_input":"2022-03-16T19:28:40.375439Z","iopub.status.idle":"2022-03-16T19:28:40.610682Z","shell.execute_reply.started":"2022-03-16T19:28:40.375407Z","shell.execute_reply":"2022-03-16T19:28:40.609383Z"}}
sales.groupby("Customer_Name")["Sales"].sum().sort_values(ascending=False).head().plot.bar()
plt.ylabel("Sales")
plt.title("Top Customers")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:40.612366Z","iopub.execute_input":"2022-03-16T19:28:40.612828Z","iopub.status.idle":"2022-03-16T19:28:40.625302Z","shell.execute_reply.started":"2022-03-16T19:28:40.612737Z","shell.execute_reply":"2022-03-16T19:28:40.624267Z"}}
# average sales grouped by Region
sales.groupby("Region")["Sales"].sum().sort_values(ascending=False)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:40.626552Z","iopub.execute_input":"2022-03-16T19:28:40.626857Z","iopub.status.idle":"2022-03-16T19:28:40.854722Z","shell.execute_reply.started":"2022-03-16T19:28:40.626812Z","shell.execute_reply":"2022-03-16T19:28:40.853811Z"}}
sales.groupby("Region")["Sales"].sum().sort_values(ascending=False).plot.bar()
plt.ylabel("Sales")
plt.title("Total Sales per Region")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:40.856225Z","iopub.execute_input":"2022-03-16T19:28:40.856814Z","iopub.status.idle":"2022-03-16T19:28:40.886126Z","shell.execute_reply.started":"2022-03-16T19:28:40.856777Z","shell.execute_reply":"2022-03-16T19:28:40.885115Z"}}
sales.head()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:40.887483Z","iopub.execute_input":"2022-03-16T19:28:40.888036Z","iopub.status.idle":"2022-03-16T19:28:40.91795Z","shell.execute_reply.started":"2022-03-16T19:28:40.887987Z","shell.execute_reply":"2022-03-16T19:28:40.917183Z"}}
sales.info()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:40.919232Z","iopub.execute_input":"2022-03-16T19:28:40.919929Z","iopub.status.idle":"2022-03-16T19:28:40.931663Z","shell.execute_reply.started":"2022-03-16T19:28:40.919891Z","shell.execute_reply":"2022-03-16T19:28:40.930654Z"}}
sales["Leadtime"].dt.days.describe()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:40.933281Z","iopub.execute_input":"2022-03-16T19:28:40.933991Z","iopub.status.idle":"2022-03-16T19:28:41.176156Z","shell.execute_reply.started":"2022-03-16T19:28:40.933942Z","shell.execute_reply":"2022-03-16T19:28:41.174851Z"}}
# plot histogram of Leadtime in days
plt.hist(sales["Leadtime"].dt.days)
plt.title("Leadtime histogram")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:41.177362Z","iopub.execute_input":"2022-03-16T19:28:41.177597Z","iopub.status.idle":"2022-03-16T19:28:41.211305Z","shell.execute_reply.started":"2022-03-16T19:28:41.17757Z","shell.execute_reply":"2022-03-16T19:28:41.210277Z"}}
sales.head()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:41.212502Z","iopub.execute_input":"2022-03-16T19:28:41.213184Z","iopub.status.idle":"2022-03-16T19:28:41.252438Z","shell.execute_reply.started":"2022-03-16T19:28:41.213144Z","shell.execute_reply":"2022-03-16T19:28:41.251406Z"}}
sales["Year_Month"] = sales["Year"].astype(str) + "-" + sales["Month"].astype(str)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:41.253587Z","iopub.execute_input":"2022-03-16T19:28:41.253936Z","iopub.status.idle":"2022-03-16T19:28:41.278038Z","shell.execute_reply.started":"2022-03-16T19:28:41.253908Z","shell.execute_reply":"2022-03-16T19:28:41.27714Z"}}
sales["Year_Month"] = pd.to_datetime(sales["Year_Month"]).dt.date

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:41.279502Z","iopub.execute_input":"2022-03-16T19:28:41.27997Z","iopub.status.idle":"2022-03-16T19:28:41.313833Z","shell.execute_reply.started":"2022-03-16T19:28:41.279936Z","shell.execute_reply":"2022-03-16T19:28:41.312911Z"}}
sales.info()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:41.315539Z","iopub.execute_input":"2022-03-16T19:28:41.316065Z","iopub.status.idle":"2022-03-16T19:28:41.721346Z","shell.execute_reply.started":"2022-03-16T19:28:41.316018Z","shell.execute_reply":"2022-03-16T19:28:41.720344Z"}}
# sales trend using year_month
plt.figure(figsize=(20,5))
plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m'))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=75))
sales.groupby("Year_Month")["Sales"].sum().plot()
plt.ylabel("Sales")
plt.title("Sales Trend by Year-Month")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:41.72259Z","iopub.execute_input":"2022-03-16T19:28:41.722842Z","iopub.status.idle":"2022-03-16T19:28:42.217177Z","shell.execute_reply.started":"2022-03-16T19:28:41.722812Z","shell.execute_reply":"2022-03-16T19:28:42.216286Z"}}
# sales trend using year_month
plt.figure(figsize=(20,5))
plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m'))
plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=75))
sales[sales.Category == "Furniture"].groupby("Year_Month")["Sales"].sum().plot(label="Furniture")
sales[sales.Category == "Office Supplies"].groupby("Year_Month")["Sales"].sum().plot(label="Office Supplies")
sales[sales.Category == "Technology"].groupby("Year_Month")["Sales"].sum().plot(label="Technology")
plt.ylabel("Sales")
plt.legend()
plt.title("Sales Trends of each Category")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:42.218652Z","iopub.execute_input":"2022-03-16T19:28:42.219295Z","iopub.status.idle":"2022-03-16T19:28:42.23733Z","shell.execute_reply.started":"2022-03-16T19:28:42.219246Z","shell.execute_reply":"2022-03-16T19:28:42.236608Z"}}
sales_trend = sales[["Year_Month","Sales"]].groupby("Year_Month").sum()
sales_trend = sales_trend.sort_values(by="Year_Month")
sales_trend.head()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:42.238296Z","iopub.execute_input":"2022-03-16T19:28:42.239111Z","iopub.status.idle":"2022-03-16T19:28:42.251105Z","shell.execute_reply.started":"2022-03-16T19:28:42.239074Z","shell.execute_reply":"2022-03-16T19:28:42.250001Z"}}
# compute for rolling average
sales_trend["rolmean"] = sales_trend.rolling(window=5).mean()
sales_trend.head()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:42.255962Z","iopub.execute_input":"2022-03-16T19:28:42.256832Z","iopub.status.idle":"2022-03-16T19:28:42.653059Z","shell.execute_reply.started":"2022-03-16T19:28:42.256752Z","shell.execute_reply":"2022-03-16T19:28:42.652197Z"}}
# sales trend using year_month with rolling average
sales_trend.plot(figsize=(20,5))
plt.legend()
plt.title("Sales Trend by Year-Month with Rolling Average")

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:42.654263Z","iopub.execute_input":"2022-03-16T19:28:42.654495Z","iopub.status.idle":"2022-03-16T19:28:42.674755Z","shell.execute_reply.started":"2022-03-16T19:28:42.654468Z","shell.execute_reply":"2022-03-16T19:28:42.673826Z"}}
# create a new dataframw where sales are aggregated monthly, then show date & monthly total sales only
sales_data = sales[["Year_Month","Sales"]].groupby("Year_Month").sum()
sales_data = sales_data.sort_values(by="Year_Month")
sales_data.head()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:42.676122Z","iopub.execute_input":"2022-03-16T19:28:42.677021Z","iopub.status.idle":"2022-03-16T19:28:42.694184Z","shell.execute_reply.started":"2022-03-16T19:28:42.676974Z","shell.execute_reply":"2022-03-16T19:28:42.692837Z"}}
# use adfuller to check if sales trend is stationary
from statsmodels.tsa.stattools import adfuller
result = adfuller(sales_data)
print('ADF Statistic: %f' % result[0])
print('p-value: %f' % result[1])
print('Critical Values:')
for key, value in result[4].items():
	print('\t%s: %.3f' % (key, value))

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:42.696128Z","iopub.execute_input":"2022-03-16T19:28:42.696665Z","iopub.status.idle":"2022-03-16T19:28:43.013608Z","shell.execute_reply.started":"2022-03-16T19:28:42.696631Z","shell.execute_reply":"2022-03-16T19:28:43.012331Z"}}
# get the log of the sales data
sales_data_log = np.log(sales_data)
sales_data_log.plot()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:43.015328Z","iopub.execute_input":"2022-03-16T19:28:43.015672Z","iopub.status.idle":"2022-03-16T19:28:43.035633Z","shell.execute_reply.started":"2022-03-16T19:28:43.015628Z","shell.execute_reply":"2022-03-16T19:28:43.034355Z"}}
# check how stationary is the log'd data
result = adfuller(sales_data_log)
print('ADF Statistic: %f' % result[0])
print('p-value: %f' % result[1])
print('Critical Values:')
for key, value in result[4].items():
	print('\t%s: %.3f' % (key, value))

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:43.037445Z","iopub.execute_input":"2022-03-16T19:28:43.038208Z","iopub.status.idle":"2022-03-16T19:28:43.408299Z","shell.execute_reply.started":"2022-03-16T19:28:43.038155Z","shell.execute_reply":"2022-03-16T19:28:43.407082Z"}}
# create a new dataframe which is shifted by 1 month
sales_shift = sales_data_log - sales_data_log.shift()
sales_shift.plot()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:43.410468Z","iopub.execute_input":"2022-03-16T19:28:43.410903Z","iopub.status.idle":"2022-03-16T19:28:43.427534Z","shell.execute_reply.started":"2022-03-16T19:28:43.410865Z","shell.execute_reply":"2022-03-16T19:28:43.426618Z"}}
# check how stationary the shifted data is
result = adfuller(sales_shift.dropna())
print('ADF Statistic: %f' % result[0])
print('p-value: %f' % result[1])
print('Critical Values:')
for key, value in result[4].items():
	print('\t%s: %.3f' % (key, value))

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:43.428891Z","iopub.execute_input":"2022-03-16T19:28:43.429302Z","iopub.status.idle":"2022-03-16T19:28:43.686082Z","shell.execute_reply.started":"2022-03-16T19:28:43.429268Z","shell.execute_reply":"2022-03-16T19:28:43.685332Z"}}
# autocorrelation
from pandas.plotting import autocorrelation_plot
autocorrelation_plot(sales_data_log)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:43.68724Z","iopub.execute_input":"2022-03-16T19:28:43.687589Z","iopub.status.idle":"2022-03-16T19:28:44.168538Z","shell.execute_reply.started":"2022-03-16T19:28:43.687559Z","shell.execute_reply":"2022-03-16T19:28:44.167356Z"}}
# check acf & pacf
from statsmodels.graphics.tsaplots import plot_acf,plot_pacf
import statsmodels.api as sm
fig = plt.figure(figsize=(12,8))
ax1 = fig.add_subplot(211)
fig = sm.graphics.tsa.plot_acf(sales_shift.dropna(),lags=15,ax=ax1)
ax2 = fig.add_subplot(212)
fig = sm.graphics.tsa.plot_pacf(sales_shift.dropna(),lags=15,ax=ax2)

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:44.169993Z","iopub.execute_input":"2022-03-16T19:28:44.170387Z","iopub.status.idle":"2022-03-16T19:28:44.308344Z","shell.execute_reply.started":"2022-03-16T19:28:44.170341Z","shell.execute_reply":"2022-03-16T19:28:44.307429Z"}}
# use ARIMA for forecasting
from statsmodels.tsa.arima.model import ARIMA
model=ARIMA(sales_shift,order=(1,1,1))
model_fit=model.fit()
model_fit.summary()

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:44.311029Z","iopub.execute_input":"2022-03-16T19:28:44.31137Z","iopub.status.idle":"2022-03-16T19:28:44.701311Z","shell.execute_reply.started":"2022-03-16T19:28:44.311332Z","shell.execute_reply":"2022-03-16T19:28:44.700306Z"}}
# plot forecast
sales_data['forecast']=model_fit.predict(start=25,end=50,dynamic=True)
sales_data[['Sales','forecast']].plot(figsize=(12,8))

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:28:44.702883Z","iopub.execute_input":"2022-03-16T19:28:44.703155Z","iopub.status.idle":"2022-03-16T19:28:45.281935Z","shell.execute_reply.started":"2022-03-16T19:28:44.703124Z","shell.execute_reply":"2022-03-16T19:28:45.280804Z"}}
# use sarimax instead due to seasonality
import statsmodels.api as sm
model=sm.tsa.statespace.SARIMAX(sales_data['Sales'],order=(1, 1, 0),seasonal_order=(1,1,0,12))
results=model.fit()
sales_data['forecast']=results.predict(start=35,end=50,dynamic=True)
sales_data[['Sales','forecast']].plot(figsize=(12,8))

# %% [code] {"execution":{"iopub.status.busy":"2022-03-16T19:29:35.727216Z","iopub.execute_input":"2022-03-16T19:29:35.728075Z","iopub.status.idle":"2022-03-16T19:29:36.113629Z","shell.execute_reply.started":"2022-03-16T19:29:35.728029Z","shell.execute_reply":"2022-03-16T19:29:36.112805Z"}}
# extend forecast until 2022
from pandas.tseries.offsets import DateOffset
future_dates=[sales_data.index[-1]+ DateOffset(months=x)for x in range(0,36)]
future_datest_df=pd.DataFrame(index=future_dates[1:],columns=sales_data.columns)

future_datest_df.tail()

future_df=pd.concat([sales_data,future_datest_df])

future_df['forecast'] = results.predict(start = 43, end = 200, dynamic= True)
future_df[['Sales', 'forecast']].plot(figsize=(12, 8))
