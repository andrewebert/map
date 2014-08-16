sed -e 's/http[^,]*\/\([^/]*\.svg\)/static\/img\/\1/g' -e 's/%/%25/g' data/flag_urls.csv > data/flag.csv
