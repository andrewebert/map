import xml.etree.ElementTree as ET
import sys
import json
import os
import re
from pprint import pprint

attributes = ["d", "name", "formal", "code", "owner", "disputed", "color"]


def parse_fill(style):
    return re.match(r".*fill:(.*?);.*", style).groups()[0]


def parse_svg(filename):
    time = os.path.basename(filename)[6:13]
    tree = ET.parse(filename)
    root = tree.getroot()
    paths = [p.attrib for p in root.findall('{http://www.w3.org/2000/svg}path')]
    map = {}
    fills = {}
    for p in paths:
        #country = {attr: p[attr] for attr in attributes if attr in p}
        country = p["d"]
        try:
            map[p["code"]] = country
        except KeyError:
            print "Missing code:", filename
            print p["id"]
            print p["style"]
        else:
            try:
                fills[p["code"]] = parse_fill(p["style"])
            except AttributeError:
                print "Missing fill:", filename
                print p["code"]
    return time, map, fills


def get_map_difference(old, new):
    old_keys = set(old.keys())
    new_keys = set(new.keys())
    changed_keys = [k for k in old_keys & new_keys if old[k] != new[k]]
    changed = {k: new[k] for k in changed_keys}
    added_keys = new_keys - old_keys
    added = {k: new[k] for k in added_keys}
    removed_keys = old_keys - new_keys
    return {"removed": list(removed_keys), "added": added, "changed": changed}


def get_data(filenames):
    files = list(reversed(filenames))
    t, original, fills = parse_svg(files[0])
    prev = original
    changes = {}
    for f in files[1:]:
        time, map, new_fills = parse_svg(f)
        changes[time] = get_map_difference(prev, map)
        fills.update(new_fills)
        prev = map
    return original, changes, fills


def convert(filenames):
    original, changes, fills = get_data(filenames)
    original_str =  "initial_countries = " + json.dumps(original, sort_keys=True) + ";"
    changes_str = "changes = " + json.dumps(changes, sort_keys=True) + ";"
    fills_str = "fills = " + json.dumps(fills, sort_keys=True) + ";"
    with open("static/js/data/initial.js", 'w') as f:
        f.write(original_str)
    with open("static/js/data/changes.js", 'w') as f:
        f.write(changes_str)
    with open("static/js/data/fills.js", 'w') as f:
        f.write(fills_str)



if __name__ == "__main__":
    convert(sys.argv[1:])

    #original_str = "initial_countries = {\n" +
        #",\n".join("\"" + k + "\": " +
                #json.dumps(v, sort_keys=True) for k, v in sorted(original.items()))
        #+ "\n}"

    #maps = {}
    #metadatas = {}
    #time, map, metadata = parse_svg(filename)
    #maps[time] = map


#d = {p["code"]: {"name": p["name"], "formal": p["formal"], "code": p["code"], "d": p["d"]} for p in paths}
#print "{\n"+ ",\n".join("\"" + k + "\": " + json.dumps(v, sort_keys=True) for k, v in sorted(d.items())) + "\n}"
