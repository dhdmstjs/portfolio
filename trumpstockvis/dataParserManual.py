# -*- coding: utf-8 -*-
"""
Created on Wed Dec 20 14:24:55 2017

@author: sam
"""
import datetime
import pandas as pd
from pandas.io.common import urlencode
import requests
from io import StringIO

import six
from google.cloud import language
from google.cloud.language import enums
from google.cloud.language import types
from google.cloud import storage 

firstYear = 2015
infilename = "tweets_raw.csv"
outfilename = "data_manual3.csv"


    
#helper function for get historical data    
def build_url(symbol, start, end):
    BASE = 'http://finance.google.com/finance/historical'
    params = get_params(symbol, start, end)
    return BASE + '?' + urlencode(params)
 
#helper function for get historical data    
def get_params(symbol, start, end):
    params = {
        'q': symbol,
        'startdate': start.strftime('%Y/%m/%d'),
        'enddate': end.strftime('%Y/%m/%d'),
        'output': "csv"
    }
    return params

#returns all the stock data listed for a company going back to the year specified
def get_historical_data(sym, year):
    start = datetime.datetime(year, 1, 1)
    end = datetime.datetime.today()
    url = build_url(sym, start, end)

    data = requests.get(url).text    
    try:
        data = pd.read_csv(StringIO(data), parse_dates=True)
        new_data = data[['Date','Open']].copy()
        return new_data
    except ValueError:
        return -1

    
#returns the sentiment and magnitude of the string passed  
def sent_analyze(text):
    """Run a sentiment analysis request on text within a passed filename."""
    client = language.LanguageServiceClient()
    
    if isinstance(text, six.binary_type):
        text = text.decode('utf-8')

    # Instantiates a plain text document.
    document = types.Document(
        content=text,
        type=enums.Document.Type.PLAIN_TEXT)

    # Detects sentiment in the document. You can also analyze HTML with:
    #   document.type == enums.Document.Type.HTML
    sentiment = client.analyze_sentiment(document).document_sentiment

    return sentiment.score, sentiment.magnitude
    
def format_date(date):
    date = date.split("-")
    day = date[0]
    if(len(day) == 1):
        day = "0" + day
    month = date[1]
    year = "20" + date[2]
    newDate = month + " " + day + " " + year
    return newDate

def main(): 
    #load the input csv into a pandas dataframe
    #iterate through the lines of the file
    #open second file to write into
    
    with open(outfilename,"w") as outfile:
        count=1
        df = pd.read_csv(infilename, sep=',')
        #iterate through the lines in the dataframe to go one company at a time 
        for allStocksLine in df.iterrows():
            print("analyzing tweet number ",count)
            #for each line, look up the stock data for that company
            ticker = allStocksLine[1][2]
            tweetDate = allStocksLine[1][3]
            industry = allStocksLine[1][4]
            tweet = allStocksLine[1][5]
            print(ticker)
            print(tweet)
            sent,mag = sent_analyze(tweet) 
            print(sent)
            #if(sent<1):
            #    sent = "bad"
            #else:
            #    sent = "good"
            tweet = tweet.replace(",","")
            stock_data = get_historical_data(ticker,firstYear)
            stock_data = stock_data[::-1]
            for oneStockLine in stock_data.iterrows():
                stockDate = format_date(oneStockLine[1][0])
                tweetContent = "-1"
                mention = "-1"
                stockSent = "null"
                if(stockDate == tweetDate):
                    mention = "1"
                    tweetContent = tweet
                    stockSent = sent
                outputString = ""+ticker+","+stockDate+","+str(oneStockLine[1][1])+","+str(stockSent)+","+industry+","+mention+","+tweetContent+"\n"
                outfile.write(outputString)
            count += 1
    
    
                
    #testLine = "If @amazon ever had to pay fair taxes, its stock would crash and it would crumble like a paper bag. The @washingtonpostscam is saving it!"
    #sent, mag = sent_analyze(testLine)
    #for line in stock_data.iterrows():
    #    print(format_date(line[1][0]))
        
        
main()