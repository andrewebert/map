sed -e 's/http[^,]*\/\([^/]*\.svg\)/static\/img\/\1/g' -e 's/%/%25/g' flag_urls.csv > flag.csv
