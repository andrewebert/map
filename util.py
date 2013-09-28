import xml.etree.ElementTree as ET
import re

def parse_svg(filename):
    tree = ET.parse(filename)
    root = tree.getroot()
    paths = [p.attrib for p in root.findall('{http://www.w3.org/2000/svg}path')]
    return paths

def parse_fill(style):
    return re.match(r".*fill:(.*?);.*", style).groups()[0]

