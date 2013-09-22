import util
import json

time, paths = util.parse_svg("static/img/world-population.svg")

table = []

for p in paths:
    try:
        code = p["data-iso-a2"]
        pop = int(float(p["data-pop-est"]))
        table.append((pop, code))
    except KeyError:
        print "missing code or pop"
        print p["id"]

print "countries:", len(table)

table.sort()
table.reverse()
d = [code for pop, code in table]
str = "population = " + json.dumps(d) + ";"
with open("static/js/data/population.js", 'w') as f:
    f.write(str)
