from flask import Flask, jsonify
from flask import render_template
from flask import url_for

# getting URL
from flask import request
from googlesearch import search
from googleapiclient.discovery import build

# text length
from urllib.request import urlopen
from bs4 import BeautifulSoup
import ssl

# get indexing
import requests
import urllib
import pandas as pd
from requests_html import HTML
from requests_html import HTMLSession
import json
app = Flask(__name__)
app.config["TEMPLATES_AUTO_RELOAD"] = True
# get indexing from each URL


def get_source(url):
    try:
        session = HTMLSession()
        response = session.get(url)
        return response

    except requests.exceptions.RequestException as e:
        print(e)


def get_results(url):
    query = urllib.parse.quote_plus(url)
    response = get_source("https://www.google.co.uk/search?q=site%3A" + url)

    return response


def parse_results(response):
    string = response.html.find("#result-stats", first=True).text
    if string:
        indexed = int(string.split(' ')[1].replace(',', ''))
        return indexed
    else:
        return 0


def count_indexed_pages(url):
    response = get_results(url)
    return parse_results(response)


def getLen(url):
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    html = urlopen(url, context=ctx).read()
    # html = urllib.request.urlopen(url, timeout=5)
    soup = BeautifulSoup(html, "html.parser")

    span_tags = soup.find_all('span')
    p_tags = soup.find_all('p')
    td_tags = soup.find_all('td')
    btn_tags = soup.find_all('button')
    # div = soup.find_all('div')
    span_total = sum([len(tag.text) for tag in span_tags])
    p_total = sum([len(tag.text) for tag in p_tags])
    td_total = sum([len(tag.text) for tag in td_tags])
    btn_total = sum([len(tag.text) for tag in btn_tags])
    total_len = span_total + p_total + td_total + btn_total
    return total_len


def google_search(search_term, api_key, cse_id, **kwargs):
    service = build("customsearch", "v1", developerKey=api_key)
    res = service.cse().list(q=search_term, cx=cse_id, start=1, num=10).execute()
    return res


@app.route('/')
def hello():
    return render_template('index.html')


@app.route('/search', methods=['POST', 'GET'])
# def resultUrl():
#     if(request.method == "POST"):
#         url = request.values.get('urls')
#     print(url)
#     quit()
#     len_index = {'len': getLen(url), 'index': count_indexed_pages(url)}
#     print(len_index)
#     quit()
# def resultUrl():
#     my_api_key = 'AIzaSyADPhYEsAnbQ1INlKQXKeFeGGNHFzI3PGs'
#     my_cse_id = '958297827ed374b25'
#     if request.method == 'POST':
#         query = request.get_data('s')
#     data = google_search(query, my_api_key, my_cse_id)
#     result = []
#     print(data)
#     quit()
#     for j in data['items']:
#         result.append({'title': j['title'], 'link': j['link'], 'summary': j['snippet']})
#     return result
def resultUrl():
    if request.method == 'POST':
        query = request.values.get('s')
    result = []
    for j in search(query, tld="co.in", num=10, stop=10, pause=5):
        index = count_indexed_pages(j)
        result.append({'url': j, 'len': getLen(j), 'index': index})
    return result

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
