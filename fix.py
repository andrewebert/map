#!/bin/python

"""
Usage: fix.py [d fill] code source dest1 dest2 ...

Replaces the given attribute in all dest svg files with the attribute from source
"""

import xml.etree.ElementTree as ET
import util
import sys

def get_path(tree, code):
    root = tree.getroot()
    paths = root.findall('{http://www.w3.org/2000/svg}path')
    for p in paths:
        if "code" not in p.attrib:
            print "missing code:", p.attrib["id"]
    return [p for p in paths if p.attrib["code"] == code][0]

def get_orig(source, code, attr):
    tree = ET.parse(source)
    try:
        path = get_path(tree, code)
    except IndexError as e:
        print "Can't find", code, "in", source
        raise e
    if attr == "d":
        return path
    elif attr == "fill":
        #return util.parse_fill(path.attrib["style"])
        return path.attrib["style"]
        
def set(filename, code, attr, value):
    tree = ET.parse(filename)
    try:
        path = get_path(tree, code)
        if attr == "d":
            path.attrib["d"] = value.attrib["d"]
        elif attr == "fill":
            if path.attrib["style"] != value:
                print "fixed", filename, code
                path.attrib["style"] = value

    except IndexError as e:
        if attr == "d":
            root = tree.getroot()
            root.append(value)
            # We need to add the country
            pass
        else:
            raise e
    finally:
        tree.write(filename)

if __name__ == "__main__":
    attr = sys.argv[1]
    code = sys.argv[2]
    source = sys.argv[3]
    destinations = sys.argv[4:]
    value = get_orig(source, code, attr)
    for dest in destinations:
        set(dest, code, attr, value)
