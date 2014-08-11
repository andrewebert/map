from unicodecsv import unicodecsv
from IPython.core.debugger import Tracer
import util

def find(dict, k1, k2):
    if k1 in dict and k2 in dict[k1] and dict[k1][k2] != "":
        return dict[k1][k2]
    else:
        return None

def main():
    with open("data/owner.csv", 'rb') as o:
        owner_table = list(unicodecsv.reader(o))
    with open("data/disputed.csv", 'rb') as d:
        disputed_table = list(unicodecsv.reader(d))

    dates = [row[0] for row in owner_table[1:]]
    codes = sorted(list(set.union(set(owner_table[0][1:]), set(disputed_table[0][1:]))))
    
    table = [[""] + codes] + [[date] + ["" for code in codes] for date in dates]

    owner = util.read_csv("data/owner.csv")
    disputed = util.read_csv("data/disputed.csv")

    #Tracer()()

    for di, date in enumerate(dates):
        for ci, code in enumerate(codes):
            o = find(owner, date, code)
            d = find(disputed, date, code)
            if o and d:
                if o == "-":
                    table[di+1][ci+1] = d
                    print d
                elif d == "-":
                    table[di+1][ci+1] = o
                    print o
                else:
                    raise Exception("{} - {}: {} vs. {}".format(date, code, o, d))
            elif o:
                table[di+1][ci+1] = o
                print o
            elif d:
                table[di+1][ci+1] = d
                print d

    with open("data/description.csv", 'wb') as csvfile:
        writer = unicodecsv.writer(csvfile, delimiter=",")
        for row in table:
            writer.writerow(row)

if __name__ == "__main__":
    main()


