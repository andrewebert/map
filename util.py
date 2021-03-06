from unicodecsv import unicodecsv
import xml.etree.ElementTree as ET
import re
import os

img_dir = "data/img/"

def format_filename(date):
    return img_dir + "world_" + date + ".svg"

def get_images():
    images = os.listdir(img_dir)
    return sorted([img_dir + i for i in images])

def parse_svg(filename):
    tree = ET.parse(filename)
    root = tree.getroot()
    paths = [p.attrib for p in root.findall('{http://www.w3.org/2000/svg}path')]
    return paths

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


