import re

def get_src(match, type):
    s = match.group(0)
    href = re.search(type + '="(.*?)"', s).group(1)
    href = href[3:]
    with open("../src/" + href, 'r') as f:
        return href, f.read()

def repl_css(match):
    name, file = get_src(match, 'href')
    return '\n<style type="text/css">\n' + file + '\n</style>\n'

def repl_js(match):
    name, file = get_src(match, 'src')
    if name == "static/js/lib/angular.js":
        return """<script
            src="https://ajax.googleapis.com/ajax/libs/angularjs/1.1.4/angular.min.js"
            type="text/javascript"></script>"""
    else:
        return '\n<script type="text/javascript">\n' + file + '\n</script>\n'

def main():
    with open('../src/templates/map.html', 'r') as f:
        map = f.read()

    map = re.sub(r'<link.*?>', repl_css, map)
    map = re.sub(r'<script.*?></script>', repl_js, map)
    print map

if __name__ == "__main__":
    main()
