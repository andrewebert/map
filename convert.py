import sys
import json
import re
import os
from IPython.core.debugger import Tracer

import util

NOW = "2014_08"

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
    changed.update({k: dict(code = k, **new[k]) for k in added_keys})
    removed = list(old_keys - new_keys)

    print "Added:", added_keys, "Changed:", changed_keys, "Removed:", removed
    return changed


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


def update_data(original, changes):
    attrs = ["flag", "fill", "owner", "name", "formal", "link", "description", "replacing", "replaced_by", "code"]
    info_attrs = ["flag", "formal", "link", "description", "link", "code"]
    defaults = {attr: {code: data[attr] for code, data in original.items() if attr in data}
            for attr in attrs}
    defaults["fill"]["UNA"] = "color11"
    defaults["flag"]["UNA"] = \
        "static/img/Flag_of_the_United_Nations.svg"
    defaults["name"]["UNA"] = "United Nations"
    defaults["fill"]["FBE"] = "color1"
    defaults["flag"]["FBE"] = "static/img/Flag_of_Belgium.svg"
    defaults["name"]["FBE"] = "the Belgian government in exile"
    defaults["fill"]["FFR"] = "color2"
    defaults["flag"]["FFR"] = "static/img/Flag_of_Free_France_1940-1944.svg"
    defaults["name"]["FFR"] = "Free France"
    colonies = {code: [] for code in original.keys() + ["UNA"]}
    main_owners = {}
    colony_names = {
            "GB": "the United Kingdom",
            "US": "the United States",
            "NL": "the Kingdom of the Netherlands",
            "DK": "the Kingdom of Denmark",
            "UNA": "the United Nations",
            "RU": "the Soviet Union",
            }
    flagless = []

    def update(date, change):
        for code, data in change.items():
            for attr in attrs:
                if attr in data:
                    defaults[attr][code] = data[attr]

        for code, data in change.items():
            if ("is" in data and data["is"] == "-") or "d" in data:
                if code in defaults["replaced_by"]:
                    data["removed"] = False
                    #print date, "unremoving", code
                    try: 
                        defaults["replacing"][defaults["replaced_by"][code]].remove(code)
                    except KeyError:
                        del defaults["replaced_by"][code]
                    except ValueError:
                        pass
                elif "is" in data and data["is"] == "-":
                    #print "killing", code, date
                    data["removed"] = True
                    for attr in info_attrs:
                        data[attr] = ""
            if "is" in data:
                replacement = data["is"]
                defaults["replaced_by"][code] = replacement
                if replacement != "-":
                    data["removed"] = True
                    #print date, "replacing", code, "with", replacement
                    try:
                        defaults["replacing"][replacement].append(code)
                    except KeyError:
                        defaults["replacing"][replacement] = [code]
                    try:
                        change[replacement]["replacing"] = defaults["replacing"][replacement]
                    except KeyError:
                        change[replacement] = {"replacing": defaults["replacing"][replacement]}
                    for attr in info_attrs:
                        if replacement in defaults[attr]:
                            data[attr] = defaults[attr][replacement]
                        else:
                            #print "missing replacement", attr, "of", replacement, "replacing", code
                            data[attr] = ""
                del data["is"]

        for code, data in change.items():
            if "description" in data:
                if data["description"] == "-":
                    data["fill"] = defaults["fill"][code]
                    try:
                        del main_owners[code]
                    except KeyError:
                        pass
                else:
                    owners = re.findall("\[...?\]", data["description"])
                    if owners:
                        main_owner = owners[0][1:-1]
                        main_owners[code] = main_owner
                        main_owner_for_fill = main_owner
                        while main_owner_for_fill in main_owners:
                            main_owner_for_fill = main_owners[main_owner_for_fill]
                        data["fill"] = defaults["fill"][main_owner_for_fill]
                        colonies[main_owner].append(code)
                        for owner in owners:
                            try:
                                name = colony_names[owner[1:-1]]
                            except KeyError:
                                name = defaults["name"][owner[1:-1]]
                            data["description"] = data["description"].replace(owner, name)
                    else:
                        data["fill"] = "disputed"

            if "flag" in data:
                if data["flag"] == "-":
                    flagless.append(code)
                    if code in main_owners:
                        data["flag"] = defaults["flag"][main_owners[code]]
                    else:
                        data["flag"] = ""
                elif data["flag"] in flagless:
                    flagless.remove(code)
                if code in colonies:
                    for c in colonies[code]:
                        if c in flagless:
                            if date == NOW:
                                original[c]["flag"] = data["flag"]
                            else:
                                if c in change:
                                    change[c]["flag"] = data["flag"]
                                else:
                                    change[c] = {"flag": data["flag"]}
 
        for code, data in change.items():
            if code in defaults["replacing"]:
                for replacing in defaults["replacing"][code]:
                    for attr in info_attrs:
                        if attr in data:
                            try:
                                change[replacing][attr] = data[attr]
                            except KeyError:
                                change[replacing] = {attr: data[attr]}
            if date !=  NOW and "fill" in data and code in colonies:
                for colony in colonies[code]:
                    #print "changing colony fill", date, colony, code
                    if colony in change:
                        change[colony]["fill"] = data["fill"]
                    else:
                        change[colony] = {"fill": data["fill"]}



    update(NOW, original)
    for date, change_data in reversed(sorted(changes.items())):
        if change_data:
            update(date, change_data)
    print "FR", colonies["FR"]
    print "BE", colonies["BE"]


def write_js(var, dict):
    return "{0} = {1};".format(var, json.dumps(dict, sort_keys=True,
        indent = 4, separators=(',',': ')))


def convert(original_file, change_files):
    original_map, changes_map = get_data(original_file, change_files)

    original_sources = transpose_dict(original_map)


    # changes_map: {date: 
    #                  {code: 
    #                      {"d": d, "fill": fill},
    #                  }, ...}
    changes_map = {date: transpose_dict(data)
            for date, data in changes_map.items()}
    # changes_map: {date: 
    #                  {"d": 
    #                      {code1: d1, code2: d2, ... },
    #                   "fill":
    #                      {code1: fill1, code2: fill2, ...}
    #                  }, ...}
    changes_map = transpose_dict(changes_map)
    # changes_map: {"d": 
    #                  {date:
    #                      {code1: d1, code2: d2, ... },
    #                      ...
    #                  },
    #               "fill": 
    #                  {date:
    #                      {code1: fill1, code2: fill2, ... },
    #                      ...
    #                  }

    def get_changes(tag):
        source = util.read_csv('data/' + tag + '.csv')
        original_sources[tag] = source[NOW]
        del source[NOW]
        changes_map[tag] = source

    get_changes('name')
    get_changes('formal')
    get_changes('flag')
    get_changes('link')
    get_changes('description')
    get_changes('is')

    original = merge_data(original_sources)

    changes = {}

    dates = list(set.union(*(set(source.keys()) for source in changes_map.values())))
    #Tracer()()
    for date in dates:
        cs = merge_data({tag: source[date] if date in source else {}
            for tag, source in changes_map.items()})
        #rs = changes_map[date]["removed"] if date in changes_map else {}
        if cs != {}:
            changes[date] = cs
            #if rs != {}:
                #changes[date]["removed"] = rs

    for code, data in original.items():
        data["code"] = code
    update_data(original, changes)

    #for code, data in sorted(original.items()):
        #name = data["name"] if "name" in data else ""
        #print code, name
        #for date, data in reversed(sorted(changes.items())):
            #if code in data and "flag" in data[code]:
                #print "    " + date

    original_str = write_js("initial_countries", original)
    changes_str = write_js("changes", changes)
    #fills_str = write_js("fills", fills)
    with open("static/js/data/initial.js", 'w') as f:
        f.write(original_str)
    with open("static/js/data/changes.js", 'w') as f:
        f.write(changes_str)
    #with open("static/js/data/fills.js", 'w') as f:
        #f.write(fills_str)


def convert_history():
    with open("data/history.txt") as f:
        lines = f.readlines()
    history = {}
    curr_year = None
    curr = {}
    while lines != []:
        line = lines[0].strip()
        lines = lines[1:]
        if re.match(r'\d{4}', line):
            if curr_year:
                history[curr_year] = curr
            curr_year = line;
            curr = {"highlighted": lines[0].strip(), "text": []}
            lines = lines[1:]
        elif line != "":
            curr["text"].append(line)
    if curr_year:
        history[curr_year] = curr

    with open("static/js/data/history.js", 'w') as f:
        f.write(write_js("history_data", history))


if __name__ == "__main__":
    filenames = list(reversed(util.get_images()))
    convert(filenames[0], filenames[1:])
    convert_history()

