from bs4 import BeautifulSoup
import requests
import pandas as pd
import unicodedata

# create empty dataframe as a container for our data later on

df = pd.DataFrame(columns = ['Description','Location','Price (PHP)','Bedrooms','Floor_area (sqm)','Land_area (sqm)','Link'])

# initialize page as zero

page = 0

# function below taken from stack overflow to convert latin n to english n

def strip_accents(text):
    return ''.join(char for char in
                   unicodedata.normalize('NFKD', text)
                   if unicodedata.category(char) != 'Mn')

# main routine to sift through pages and take real estate info then load it into dataframe

while page in range(0,50):
    page += 1
    html_text = requests.get(f'https://www.lamudi.com.ph/house/buy/?page={page}').text
    soup = BeautifulSoup(html_text, 'lxml')
    all_info_main = soup.find_all('div', class_='ListingCell-AllInfo ListingUnit')
    for all_info in all_info_main:
        header = all_info.find('h2', class_='ListingCell-KeyInfo-title').text.strip()
        location = all_info.find('span', class_='ListingCell-KeyInfo-address-text').text.strip()
        try:
            price = all_info.find('span', class_='PriceSection-FirstPrice').text.strip()
        except AttributeError:
            price ="no info"
        try:
            bedrooms = all_info.find('span', class_='KeyInformation-value_v2 KeyInformation-amenities-icon_v2 icon-bedrooms').text.strip()
        except AttributeError:
            bedrooms ="no info"
        try:
            floor_area = all_info.find('span', class_='KeyInformation-value_v2 KeyInformation-amenities-icon_v2 icon-livingsize').text.strip()
        except:
            floor_area ="no info"
        try:
            land_area = all_info.find('span', class_='KeyInformation-value_v2 KeyInformation-amenities-icon_v2 icon-land_size').text.strip()
        except AttributeError:
            land_area ="no info"
        link = all_info.a['href']
        df = df.append({
                'Description' : strip_accents(header),
                'Location' : strip_accents(location),
                'Price (PHP)' : price.lstrip("₱ "),
                'Bedrooms' : bedrooms,
                'Floor_area (sqm)' : floor_area.rstrip(" m²"),
                'Land_area (sqm)' : land_area.rstrip(" m²"),
                'Link' : link},
                ignore_index = True
                )
    print(f'finished page {page}')

# output dataframe into CSV file

df.to_csv('C:\Arlo\Data Science\Python\PH_houses.csv', encoding='utf-8', index=False)



        #print(header)
        #print(location)
        #print(price)
        #print(bedrooms)
        #print(floor_area)
        #print(land_area)
        #print(link)
        #print("\n")

