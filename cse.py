from googleapiclient.discovery import build
from datetime import datetime

def google_search(search_term, api_key, cse_id, **kwargs):
    service = build("customsearch", "v1", developerKey=api_key)
    res = service.cse().list(q=search_term, cx=cse_id, **kwargs).execute()
    return res
def getData():
    my_api_key = 'AIzaSyDoD64ZpxaKqcp1DKzdEqr1WhzDRkukaCs'
    my_cse_id = '958297827ed374b25'
    result = google_search("how to fix laravel error?", my_api_key, my_cse_id)
    res = []
    start = datetime.now()
    print(f'start {start}')
    for j in result['items']:
        res.append({'title': j['title'], 'link': j['link'], 'summary': j['snippet'] })
    print(res)
    end = datetime.now()
    print(f'end__{end}')
    print(f"differenct_time{(end-start).microseconds}")
getData()
    