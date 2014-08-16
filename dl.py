import util
import requests
import os

def main():
    csv = util.read_csv("data/flag_urls.csv")
    for data in csv.values():
        for url in data.values():
            if url != "-":
                file = "static/img/" + url.split("/")[-1]
                if not os.path.isfile(file):
                    print url
                    r = requests.get(url)
                    if r.status_code == 200:
                        with open(file, 'wb') as f:
                            f.write(r.content)
                    else:
                        print "Invalid URL"
                        raise KeyError
                

if __name__ == "__main__":
    main()