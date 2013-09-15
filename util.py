import os
import xml.etree.ElementTree as ET

def parse_svg(filename):
    time = os.path.basename(filename)[6:13]
    tree = ET.parse(filename)
    root = tree.getroot()
    paths = [p.attrib for p in root.findall('{http://www.w3.org/2000/svg}path')]
    return time, paths

