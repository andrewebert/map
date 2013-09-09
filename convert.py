import xml.etree.ElementTree as ET
import sys
import json

tree = ET.parse(sys.argv[1])
root = tree.getroot()

paths = [p.attrib for p in root.findall('{http://www.w3.org/2000/svg}path')]
d = {p["code"]: {"name": p["name"], "formal": p["formal"], "code": p["code"], "d": p["d"]} for p in paths}
print "{\n"+ ",\n".join("\"" + k + "\": " + json.dumps(v, sort_keys=True) for k, v in sorted(d.items())) + "\n}"
#js = json.dumps(d, sort_keys=True, indent=2, separators=(',', ': '))
#print js
