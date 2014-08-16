import util
import requests
import os

def main():
    csv = util.read_csv("data/flag_urls.csv")
    for data in csv.values():
        for url in data.values():
            if url != "-":
                try:
                    r = requests.head(url)
                    if r.status_code != 200:
                        print url
                except requests.exceptions.MissingSchema:
                    print url

if __name__ == "__main__":
    main()
