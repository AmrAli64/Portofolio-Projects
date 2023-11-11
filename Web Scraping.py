# coding: utf-8

# Imported necessary libraries
from bs4 import BeautifulSoup  # Used BS for HTML parsing
import requests  # Used for making HTTP requests
import pandas as pd  # Used Pandas for data manipulation

# Defined the URL to be scraped
url = 'https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue'

# Sent an HTTP request to the URL and got the content
page = requests.get(url)

# Created a BeautifulSoup object to parse the HTML content
soup = BeautifulSoup(page.text, 'html.parser')

# Printed the prettified HTML content (optional)
print(soup.prettify())

# Found the table with class 'wikitable sortable'
table = soup.find('table', class_='wikitable sortable')

# Extracted column headers from the table
table_headers = table.find_all('th')
column_headers = [header.text.strip() for header in table_headers]

# Created an empty DataFrame with the extracted column headers
df = pd.DataFrame(columns=column_headers)

# Found all rows in the table (skipped the first row, as it contained headers)
table_rows = table.find_all('tr')[1:]

# Iterated through each row, extracted data, and appended it to the DataFrame
for row in table_rows:
    row_data = row.find_all('td')
    individual_row_data = [data.text.strip() for data in row_data]
    df = df.append(pd.Series(individual_row_data, index=df.columns), ignore_index=True)

# Displayed the DataFrame
print(df)

# Saved the DataFrame to a CSV file
df.to_csv(r'C:\Users\moham\Documents\Python Web Scraping\Companies.csv', index=False)
