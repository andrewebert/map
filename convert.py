import sys
import json
import re
from unicodecsv import unicodecsv
from IPython.core.debugger import Tracer

from util import parse_svg

def parse_fill(style):
    return re.match(r".*fill:(.*?);.*", style).groups()[0]

def extract_map_data(paths):
    map = {}
    fills = {}
    for p in paths:
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
    return map, fills


def get_map_difference(old, new):
    old_keys = set(old.keys())
    new_keys = set(new.keys())
    changed_keys = [k for k in new_keys if k not in old_keys or old[k] != new[k]]
    changed = {k: new[k] for k in changed_keys}
    removed = list(old_keys - new_keys)
    return {"removed": removed, "changed": changed}


def get_data(filenames):
    files = list(reversed(filenames))
    t, paths = parse_svg(files[0])
    original, fills = extract_map_data(paths)
    prev = original
    changes = {}
    for f in files[1:]:
        time, paths = parse_svg(f)
        map, new_fills = extract_map_data(paths)
        changes[time] = get_map_difference(prev, map)
        fills.update(new_fills)
        prev = map
    return original, changes, fills


def read_csv(filename):
    data = {}
    with open(filename, 'rb') as f:
        reader = unicodecsv.reader(f)
        codes = reader.next()[1:]
        for row in reader:
            date = row[0]
            changes = {codes[i]: name for i, name in enumerate(row[1:]) if name != u''}
            if changes != {}:
                data[date] = changes
    return data


# sources: {tag: {code: value}}
def merge_data(sources):
    codes = set.union(*(set(source.keys()) for source in sources.values()))
    data = {}
    for code in list(codes):
        data[code] = {}
        for tag, source in sources.items():
            if code in source:
                data[code][tag] = source[code]
    return data


def merge_changes(changes_map, changes_names, changes_formals):
    changes = {}
    dates = list(set.union(*(set(source.keys())
        for source in (changes_map, changes_names, changes_formals))))
    for date in dates:
        changes[date] = {}
        if date in changes_map:
            changes[date]["removed"] = changes_map[date]["removed"]
        changes[date]["changed"] = merge_data({
            "d": changes_map[date]["changed"] if date in changes_map else {},
            "name": changes_names[date] if date in changes_names else {},
            "formal": changes_formals[date] if date in changes_formals else {}})
    return changes

def convert(filenames):
    original_map, changes_map, fills = get_data(filenames)

    original_sources = {"d": original_map}
    change_sources = {"d": {date: data["changed"]
        for date, data in changes_map.items() if "changed" in data}}

    def get_changes(tag):
        source = read_csv('data/' + tag + '.csv')
        original_sources[tag] = source["2013_01"]
        del source["2013_01"]
        change_sources[tag] = source

    get_changes('name')
    get_changes('formal')
    get_changes('owner')

    original = merge_data(original_sources)

    changes = {}

    dates = list(set.union(*(set(source.keys()) for source in change_sources.values())))
    #Tracer()()
    for date in dates:
        cs = merge_data({tag: source[date] if date in source else {}
            for tag, source in change_sources.items()})
        rs = changes_map[date]["removed"] if date in changes_map else {}
        if cs != {} or rs != {}:
            changes[date] = {}
            if cs != {}:
                changes[date]["changed"] = cs
            if rs != {}:
                changes[date]["removed"] = rs


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

