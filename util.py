import xml.etree.ElementTree as ET
import re

def parse_svg(filename):
    tree = ET.parse(filename)
    root = tree.getroot()
    paths = [p.attrib for p in root.findall('{http://www.w3.org/2000/svg}path')]
    return paths

def parse_fill(style):
    return re.match(r".*fill:(.*?);.*", style).groups()[0]

def lookup_fill(fill):
    table = {"#cc6e6e": "color1",
            "#cc916e": "color2",
            "#ccb76e": "color3",
            "#b7cc6e": "color4",
            "#86cc6e": "color5",
            "#6ecc9a": "color6",
            "#6eccc9": "color7",
            "#6ea1cc": "color8",
            "#6e72cc": "color9",
            "#986ecc": "color10",
            "#c66ecc": "color11",
            "#cc6ea3": "color12",
            "#9d9d9d": "color13",
            "#ffffff": "color14",
            }
    return table[fill]


