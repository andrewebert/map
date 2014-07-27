from pprint import pprint
import csv
import codecs
import sys
from unicodecsv import unicodecsv

import util

attributes = ["d", "name", "formal", "code", "owner", "disputed", "color"]

def extract_names(paths):
    names = {}
    formals = {}
    for p in paths:
        try:
            names[p["code"]] = p["name"]
            formals[p["code"]] = p["formal"] if p["formal"] != "" else p["name"]
        except KeyError:
            print "Missing data"
            pprint(p)
    return names, formals

def make_csv(d, filename):
    s = sorted(d.items())
    codes = ["code"] + [e[0] for e in s]
    names = ["2013_01"] + [e[1] for e in s]
    rows = [["{:04d}_{:02d}".format(y, m)]
            for y in xrange(2012, 1899, -1) for m in xrange(12, 0, -1)]
    with open(filename, 'wb') as f:
        writer = unicodecsv.writer(f)
        writer.writerow(codes)
        writer.writerow(names)
        writer.writerows(rows)

if __name__ == "__main__":
    t, paths = util.parse_svg(sys.argv[1])
    n, f = extract_names(paths)
    make_csv(n, "names.csv")
    make_csv(f, "formal.csv")
