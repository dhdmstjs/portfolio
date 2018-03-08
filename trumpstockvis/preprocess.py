# -*- coding: utf-8 -*-
"""
Created on Fri Dec  1 23:36:46 2017

@author: sam
"""

import calendar
import datetime
from io import StringIO

import pandas as pd
from pandas.io.common import urlencode

import six
import sys
import time
import requests
from requests import get

from urllib.parse import quote_plus

from bs4 import BeautifulSoup

from google.cloud import language
from google.cloud.language import enums
from google.cloud.language import types
from google.cloud import storage 

#location of file to open
fileLoc = "tweets.csv"
outFileLoc = "results.csv"

START_YEAR = 2015
#number of tweets to analyze
TOTAL = 8000
#steps
def main():
    
    completed = 0
    client = language.LanguageServiceClient()
    df = pd.read_csv(fileLoc)
    for tweet in df["Tweet_Text"]:
        if(completed < TOTAL):  
            date = df.iloc[completed]["Date"]
            clean_date = format_date(date)
            #api call to google cloud nlp to extract entities from tweet
            #print(tweet)
            #if there are entities then get the wikipedia url
            urls,names = gcloud_analyze(tweet,completed,client)
            print(tweet)
            #print(urls)
            #print(names)
            #use beautifulsoup to check if the entity is a company 
            #that is traded on any american stock exchanges
            if urls:
                index = 0
                for url in urls:
                    #if so then parse the wikipedia data for exchange and ticker symbol
                    exchange, ticker = wikipedia_parse(url)
                    print(exchange)
                    print(ticker)
                    #finally call the google finance api for historical price data of the company
                    
                    if(ticker != -1):
                        data = get_historical_data(ticker,START_YEAR)
    
                        print(data)
                        #if the stock data was retreived successfully then check the sentiment of the tweet
                        #towards the company
                        if(data != -1):
                            salience, sentiment = entity_sentiment_text(tweet,names[index])
                            with open(outFileLoc,"a") as outfile:
                                for row in data.iterrows():
                                    mention = -1
                                    if(row["Date"] == clean_date):
                                        mention = 1
                                    line = str(ticker) + "," + row["Date"] + "," + str(sentiment) + "," + str(exchange) + "," + str(mention) + "," + tweet + "\n" 
                                    outfile.write(line)
                        index += 1    
                    

#symbol,date,price,sent,inds,mention,text
#MSFT,Jan 2000,39.81,bad,tech,-1,-1
                
                
            completed += 1
            time.sleep(5)
        else:
            break
        
        
def entity_sentiment_text(text,target):
    """Detects entity sentiment in the provided text."""
    client = language.LanguageServiceClient()

    if isinstance(text, six.binary_type):
        text = text.decode('utf-8')

    document = types.Document(
        content=text.encode('utf-8'),
        type=enums.Document.Type.PLAIN_TEXT)

    # Detect and send native Python encoding to receive correct word offsets.
    encoding = enums.EncodingType.UTF32
    if sys.maxunicode == 65535:
        encoding = enums.EncodingType.UTF16

    result = client.analyze_entity_sentiment(document, encoding)

    for entity in result.entities:
        if(entity.name == target):
            return entity.salience,entity.sentiment

def format_date(date):
    month_map = {k: v for k,v in enumerate(calendar.month_abbr)}

    parts = date.split("-")
    new_date = str(parts[2]) + "-" +  month_map[int(parts[1])] + "-" + str(parts[0])
    return new_date

def gcloud_analyze(tweet,complete,client):   
    document = types.Document(content=tweet,type=enums.Document.Type.PLAIN_TEXT)
    entities = client.analyze_entities(document = document)
    urls = []
    names = []
    print("-----Tweet Number: ", complete,"------")
    for index, item in enumerate(entities.entities):
        if(item.type == 3):
            meta = item.metadata
            #print(item.name)
            if(meta["wikipedia_url"] != ""):
                urls.append(meta["wikipedia_url"])
                names.append(item.name)
                #print("organization found!")
            #print("no organizations found")
    return urls, names
        
def wikipedia_parse(url):
    req = requests.get(url)

    soup = BeautifulSoup(req.content,"lxml")
    table = soup.find("table",{"class":"infobox vcard"})
    
    stock = False
    
    try:
        for header in table.find_all("th"):
            if(header.a != None and stock == False):
                if(header.a.string == "Traded\xa0as"):
                    exchange = header.parent.td.div.ul.li.find_all("a")[0].string
                    ticker = header.parent.td.div.ul.li.find_all("a")[1].string
                    stock = True
        
        if(stock == False):
            return -1,-1
        else:
            return exchange, ticker
    except AttributeError:
        return -1,-1




def get_params(symbol, start, end):
    params = {
        'q': symbol,
        'startdate': start.strftime('%Y/%m/%d'),
        'enddate': end.strftime('%Y/%m/%d'),
        'output': "csv"
    }
    return params


def build_url(symbol, start, end):
    BASE = 'http://finance.google.com/finance/historical'
    params = get_params(symbol, start, end)
    return BASE + '?' + urlencode(params)

def get_historical_data(sym, year):
    start = datetime.datetime(year, 1, 1)
    end = datetime.datetime.today()
    url = build_url(sym, start, end)

    data = requests.get(url).text
    try:
        data = pd.read_csv(StringIO(data), index_col='Date', parse_dates=True)
        filtered_data = data[['Date','Open']].copy()
        return filtered_data
    except ValueError:
        return -1

                        
main()

    


