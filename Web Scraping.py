#!/usr/bin/env python
# coding: utf-8

# In[1]:


from bs4 import BeautifulSoup
import requests


# In[2]:


url = 'https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue'
    
page=requests.get(url)

soup= BeautifulSoup(page.text, 'html')


# In[3]:


print(soup.prettify())


# In[4]:


<table class="wikitable sortable" 
<caption>


# In[5]:


table= soup.find_all('table')[1]


# In[6]:


soup.find('table',class_ = 'wikitable sortable')


# In[7]:


table = table.find_all('th')


# In[8]:


print(table)


# In[9]:


world_titles= table.find_all('th')


# In[10]:


world_titles


# In[11]:


world_title_tables = [title.text.strip() for title in world_titles]

print(world_title_tables)


# In[12]:


import pandas as pd


# In[13]:


df= pd.DataFrame(columns = world_title_tables)

df


# In[14]:


column_data = table.find_all('tr')


# In[15]:


for row in column_data[1:]:
    row_data = row.find_all('td')
    Individual_row_data = [data.text.strip() for data in row_data]
   
    length= len(df)
    df.loc[length] = Individual_row_data


# In[16]:


df


# In[17]:


df.to_csv(r'C:\Users\moham\Documents\Python Web Scraping\Companies.csv', index = False)


