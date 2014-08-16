import xml.etree.ElementTree as ET
import util
import sys
import os

def get_filenames(fixed, start, end):
    source = util.format_filename(fixed)
    svgs = util.get_images()
    destinations = sorted([s for s in svgs
            if s >= util.format_filename(start) and 
               s <= util.format_filename(end)])

    return source, destinations


style = "fill:#7dcfb5;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.50000000000000000;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none"
fixed = "2014_08"
start = "1900_01"
end = fixed
source, destinations = get_filenames(fixed, start, end)
            
for dest in destinations:
    tree = ET.parse(dest)
    root = tree.getroot()
    paths = root.findall('{http://www.w3.org/2000/svg}path')
    for path in paths:
        try:
            util.lookup_fill(util.parse_fill(path.attrib["style"]))
        except KeyError:
            print dest, path.attrib["code"]
            path.attrib["style"] = style
    tree.write(dest)

