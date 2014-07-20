#!/bin/python

"""
Usage: fix.py [d fill delete] code fixed start end
e.g fix.py d AZ 2014_03 1991_09 2011_07

d will change the border shape or add a new country
fill will change the color
"""

import xml.etree.ElementTree as ET
import util
import sys
import os

def get_path(tree, code):
    root = tree.getroot()
    paths = root.findall('{http://www.w3.org/2000/svg}path')
    for p in paths:
        if "code" not in p.attrib:
            print "missing code:", p.attrib["id"],
            raise KeyError
    return [p for p in paths if p.attrib["code"] == code][0]

def get_orig(source, code, attr):
    tree = ET.parse(source)
    try:
        path = get_path(tree, code)
    except IndexError as e:
        print "Can't find", code, "in", source
        raise e
    except KeyError as e:
        print source
        raise e
    if attr == "d" or attr == "new":
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
        elif attr == "delete":
            tree.getroot().remove(path)

    except IndexError as e:
        if attr == "d":
            # We need to add the country
            root = tree.getroot()
            root.append(value)
        else:
            print "Can't find", code, "in", filename
    except KeyError as e:
        print filename
        raise e
    finally:
        tree.write(filename)

def get_filenames(fixed, start, end):
    img_dir = "data/img/"
    def format_filename(date):
        return "world_" + date + ".svg"
    
    source = img_dir + format_filename(fixed)
    svgs = os.listdir(img_dir)
    destinations = sorted([img_dir + s for s in svgs
            if s >= format_filename(start) and 
               s <= format_filename(end)])

    return source, destinations

if __name__ == "__main__":
    attr = sys.argv[1]
    code = sys.argv[2]
    fixed = sys.argv[3]
    if len(sys.argv) > 4:
        start = sys.argv[4]
    else:
        start = "1900_01"
    if len(sys.argv) > 5:
        end = sys.argv[5]
    else:
        end = fixed
    source, destinations = get_filenames(fixed, start, end)
    if attr == "delete":
        value = None
    else:
        value = get_orig(source, code, attr)
    for dest in destinations:
        set(dest, code, attr, value)
