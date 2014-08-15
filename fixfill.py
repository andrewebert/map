import xml.etree.ElementTree as ET
import util
import sys
import os

style = "fill:#7dcfb5;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.50000000000000000;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none"
fixed = "2014_07"
start = "1900_01"
end = "2014_07"
source, destinations = get_filenames(fixed, start, end)
            
for dest in destinations:
    tree = ET.parse(dest)
    root = tree.getroot()
    paths = root.findall('{http://www.w3.org/2000/svg}path')
    for path in paths:
        try: 
            util.lookup_fill(util.parse_fill(path.attrib["fill"]))
        except KeyError:
            print dest, path.atrib["code"]
            path.attrib["style"] = style
    tree.write(dest)

