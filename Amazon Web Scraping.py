
import pandas as pd
from bs4 import BeautifulSoup
import requests
import time
from datetime import date

def get_amazon_product_data():
    # URL and headers
    URL = 'https://www.amazon.com/SAMSUNG-Factory-Unlocked-Android-Smartphone/dp/B0BLP3ZZXT/ref=sr_1_2?crid=1T5R75YKJF99N&keywords=iphone+14+pro+max+phone&psr=EY17&qid=1699014160&s=todays-deals&sprefix=iphone+14+pro%2Ctodays-deals%2C208&sr=1-2'

    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36 Edg/118.0.2088.46",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        "DNT": "1",
        "Connection": "close",
        "Upgrade-Insecure-Requests": "1"
    }

    # Sending requests and creating BeautifulSoup object
    page = requests.get(URL, headers=headers)
    soup = BeautifulSoup(page.content, "html.parser")

    # Extracting product details
    title = soup.find(id='productTitle').get_text().strip()
    price = extract_price(soup)
    rating, num_ratings = extract_rating_and_reviews(soup)
    discount = extract_discount(soup)

    return title, price, rating, num_ratings, discount

def extract_price(soup):
    # Extracting the price
    price_symbol = soup.find('span', {'class': 'a-price-symbol'})
    price_whole = soup.find('span', {'class': 'a-price-whole'})
    price_decimal = soup.find('span', {'class': 'a-price-decimal'})
    price_fraction = soup.find('span', {'class': 'a-price-fraction'})

    # Extracting text from the elements
    symbol = price_symbol.text if price_symbol else ''
    whole_part = price_whole.text if price_whole else '0'
    decimal_part = price_decimal.text.strip('.') if price_decimal else ''
    fraction_part = price_fraction.text.strip('.') if price_fraction else ''

    # Combining parts to form the complete price
    price = f"{symbol}{whole_part}{decimal_part}{fraction_part}"
    return price

def extract_rating_and_reviews(soup):
    # Extracting the rating and number of ratings
    rating_span = soup.find('span', {'class': 'a-icon-alt'})
    num_ratings_span = soup.find('span', {'id': 'acrCustomerReviewText', 'class': 'a-size-base'})

    # Extracting text from the elements
    rating = rating_span.text.split()[0] if rating_span else 'N/A'
    num_ratings = num_ratings_span.text.split()[0] if num_ratings_span else 'N/A'
    return rating, num_ratings

def extract_discount(soup):
    # Extracting the discount percentage
    discount_span = soup.find('span', {'class': 'a-size-large a-color-price savingPriceOverride aok-align-center reinventPriceSavingsPercentageMargin savingsPercentage'})

    # Extracting text from the element
    discount_percentage = discount_span.text.strip() if discount_span else '0%'
    return int(discount_percentage.strip('%')) / 100  # Convert to decimal

# Function to save product data to a CSV file
def save_to_csv(title, price, rating, num_ratings, discount):
    # Today's date
    today = date.today()

    # Define CSV header and data
    header = ['Title', 'Price', 'Date', 'Rating', 'Ratings Number', 'Discount']
    data = [title.strip(), price[1:], today, rating, num_ratings, discount * 100]

    # Open the CSV file in append mode and write the data
    with open('AmazonWebScrapperDataset.csv', 'a+', newline='', encoding='UTF8') as f:
        writer = csv.writer(f)
        writer.writerow(data)

# Main function to run the Amazon web scraping and data saving process
def main():
    # Run the process continuously
    while True:
        # Get Amazon product data
        title, price, rating, num_ratings, discount = get_amazon_product_data()

        # Save the data to the CSV file
        save_to_csv(title, price, rating, num_ratings, discount)

        # Sleep for 24 hours before the next iteration
        time.sleep(86400)  # Sleep for 24 hours

# Entry point to the script
if __name__ == "__main__":
    # Call the main function
    main()
