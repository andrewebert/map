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
    table = {"#af0b0b": "color1",
             "#cd8c00": "color2",
             "#d4dd00": "color3",
             "#19a137": "color4",
             "#0496b6": "color5",
             "#470baf": "color6",
             "#97209a": "color7",
             "#d0977c": "color8",
             "#d0c47c": "color9",
             "#9cd07c": "color10",
             "#7dcfb5": "color11",
             "#6f8de0": "color12",
             "#b47cd0": "color13",
             "#dd629f": "color14",
            }
    return table[fill]


