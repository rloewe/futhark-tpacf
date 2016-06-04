#!/usr/bin/python
import os

for dataset in ["small", "medium", "large"]:
    with open(dataset + "/output/tpacf.out", "r") as f, open(dataset + "/output-data", "w") as out:
        DD = []
        RR = []
        DR = []

        newData = []
        data = f.read()
        lines = data.split('\n')
        for i in xrange(len(lines)):
            if not lines[i] == "":
                num = lines[i] + "i64"
                newData.append(num)
                if i % 3 == 0:
                    DD.append(num)
                if i % 3 == 1:
                    RR.append(num)
                if i % 3 == 2:
                    DR.append(num)
        out.write("[" + ", ".join(newData) + "]")
        #out.writelines([
        #    "--DD\n",
        #    "[" + ", ".join(DD) + "]\n",
        #    "--DR\n",
        #    "[" + ", ".join(RR) + "]\n",
        #    "--RR\n",
        #    "[" + ", ".join(DR) + "]\n"
        #    ])

