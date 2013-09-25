import util
import json

time, paths = util.parse_svg("data/img/world-population.svg")

table = []

for p in paths:
    try:
        code = p["data-iso-a2"]
        pop = int(float(p["data-pop-est"]))
        table.append((pop, code))
    except KeyError:
        print "missing code or pop"
        print p["id"]

table.sort()
table.reverse()
d = [code for pop, code in table if pop > 400000]
print "countries:", len(d)

str = "population = " + json.dumps(d) + ";"
with open("static/js/data/population.js", 'w') as f:
    f.write(str)
