#!/usr/bin/python
import os

parts = {}
for path in os.listdir("large/input"):
    if not path == "DESCRIPTION":
        f = open("large/input/" + path)
        content = f.read()
        lines = content.split('\n')
        xy = {"x": [], "y": []}
        for line in lines:
            if not line == "":
                linesplit = line.split(' ')
                xy["x"].append(linesplit[0])
                xy["y"].append(linesplit[1])

        pathparts = path.split(".")
        if parts.has_key(pathparts[0]):
            parts[pathparts[0]][0] += ", [" + ", ".join(xy["x"]) + "]"
            parts[pathparts[0]][1] += ", [" + ", ".join(xy["y"]) + "]"
        else:
            parts[pathparts[0]] = ["[" + ", ".join(xy["x"]) + "]", "[" + ", ".join(xy["y"]) + "]"]

f = open("large/input-data", "w")
for key,value in parts.iteritems():
    f.write("--" + key + " x\n")
    f.write("[" + value[0] + "]\n")
    f.write("--" + key + " y\n")
    f.write("[" + value[1] + "]\n")

f.close()

#print "--" + path

#print parts
    #print newlines
