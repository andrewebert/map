import sys
import json
import re
import os
from unicodecsv import unicodecsv
from IPython.core.debugger import Tracer

import util

NOW = "2014_07"

def extract_map_data(paths):
    map = {}
    for p in paths:
        d = p["d"]
        try:
            if p["code"] == "-99":
                raise KeyError
            map[p["code"]] = {"d": d}
        except KeyError:
            print "Missing code:"
            print p["id"]
            print p["style"]
        else:
            try:
                fill = util.parse_fill(p["style"])
                try:
                    map[p["code"]]["fill"] = util.lookup_fill(fill)
                except KeyError as e:
                    print "Invalid fill:", p["id"], p["code"], p["style"]
                    raise e
            except AttributeError:
                print "Missing fill:", p["code"], p["style"]
    return map


def get_map_difference(old, new):
    old_keys = set(old.keys())
    new_keys = set(new.keys())
    # ignore fill changes here, they're not relevant
    for k in new_keys:
        if k in old_keys and old[k]["d"] == new[k]["d"] and old[k]["fill"] != new[k]["fill"]:
            print "fill changed", k
            new[k] = old[k]
    added_keys = [k for k in new_keys if k not in old_keys]
    changed_keys = [k for k in new_keys if k in old_keys and old[k] != new[k]]
    changed = {k: {"d": new[k]["d"]} for k in changed_keys}
    changed.update({k: new[k] for k in added_keys})
    removed = list(old_keys - new_keys)

    print "Added:", added_keys, "Changed:", changed_keys, "Removed:", removed
    return {"removed": removed, "changed": changed}


def get_data(original_file, changed_files):
    paths = util.parse_svg(original_file)
    original = extract_map_data(paths)
    prev = original
    changes = {}
    for f in changed_files:
        time = os.path.basename(f)[6:13]
        paths = util.parse_svg(f)
        print "\n", time,
        new = extract_map_data(paths)
        changes[time] = get_map_difference(prev, new)
        prev = new
    return original, changes


def read_csv(filename):
    data = {}
    with open(filename, 'rb') as f:
        reader = unicodecsv.reader(f)
        codes = reader.next()[1:]
        i = 0
        while True:
            try:
                row = reader.next()
                i += 1
                date = row[0]
                changes = {codes[i]: name for i, name in enumerate(row[1:]) if name != u''}
                if changes != {}:
                    data[date] = changes
            except UnicodeDecodeError as e:
                print "Unicode error", filename, i
                raise e
            except StopIteration:
                break
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

# {K1: {k1: v1}, K2: {k1: v2, k2: v3}, K3: {k2: v4}}
# => {k1: {K1: v1, K2: v2}, k2: {K2: v3, K3: v4}}
def transpose_dict(d):
    result = {}
    for outer_key, data in d.items():
        for inner_key, value in data.items():
            if inner_key in result:
                result[inner_key][outer_key] = value
            else:
                result[inner_key] = {outer_key: value}
    return result


def update_fills(original, changes):
    default_fills = {code: data["fill"] for code, data in original.items() if "fill" in data}
    default_fills["UNA"] = "color11"

    def update(countries):
        for country, data in countries.items():
            if "fill" in data:
                default_fills[country] = data["fill"]
            if "disputed" in data:
                if data["disputed"] != "-":
                    data["fill"] = "color13"
                else:
                    data["fill"] = default_fills[country]
            if ("disputed" not in data or data["disputed"] == "-") and "owner" in data:
                if data["owner"] != "-":
                    data["fill"] = default_fills[data["owner"].split(" ")[0]]
                else:
                    data["fill"] = default_fills[country]
    
    update(original)
    for date, change_data in changes.items():
        if change_data:
            update(change_data)


def convert(original_file, change_files):
    original_map, changes_map = get_data(original_file, change_files)

    original_sources = transpose_dict(original_map)

    # changes_map: {date: 
    #                {"changed":
    #                    {code: 
    #                       {"d": d, "fill": fill},
    #                       ...
    #                    },
    #                 "removed": [code, ...]}}
    change_sources = transpose_dict(changes_map)["changed"]
    # change_sources: {date: 
    #                     {code: 
    #                         {"d": d, "fill": fill}
    #                     }, ...}
    change_sources = {date: transpose_dict(data)
            for date, data in change_sources.items()}
    # change_sources: {date: 
    #                     {"d": 
    #                         {code1: d1, code2: d2, ... }
    #                      "fill":
    #                         {code1: fill1, code2: fill2, ...
    change_sources = transpose_dict(change_sources)
    # change_sources: {"d": 
    #                     {date:
    #                         {code1: d1, code2: d2, ... },
    #                         ...
    #                     }
    #                  "fill": 
    #                     {date:
    #                         {code1: fill1, code2: fill2, ... },
    #                         ...
    #                     }

    def get_changes(tag):
        source = read_csv('data/' + tag + '.csv')
        original_sources[tag] = source[NOW]
        del source[NOW]
        change_sources[tag] = source

    get_changes('name')
    get_changes('formal')
    get_changes('owner')
    get_changes('flag')
    get_changes('link')
    get_changes('disputed')
    get_changes('is')

    original = merge_data(original_sources)

    changes = {}

    dates = list(set.union(*(set(source.keys()) for source in change_sources.values())))
    #Tracer()()
    for date in dates:
        cs = merge_data({tag: source[date] if date in source else {}
            for tag, source in change_sources.items()})
        #rs = changes_map[date]["removed"] if date in changes_map else {}
        if cs != {}:
            changes[date] = cs
            #if rs != {}:
                #changes[date]["removed"] = rs

    update_fills(original, changes)

    def write_js(var, dict):
        return "{0} = {1};".format(var, json.dumps(dict, sort_keys=True,
            indent = 4, separators=(',',': ')))

    original_str = write_js("initial_countries", original)
    changes_str = write_js("changes", changes)
    #fills_str = write_js("fills", fills)
    with open("static/js/data/initial.js", 'w') as f:
        f.write(original_str)
    with open("static/js/data/changes.js", 'w') as f:
        f.write(changes_str)
    #with open("static/js/data/fills.js", 'w') as f:
        #f.write(fills_str)



if __name__ == "__main__":
    filenames = list(reversed(util.get_images()))
    convert(filenames[0], filenames[1:])

