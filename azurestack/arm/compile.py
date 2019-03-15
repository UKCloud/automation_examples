import os
import glob
import sys
import yaml
import json


tmpl_in = sys.argv[-1]
print("Compiling %s" % tmpl_in)
res = True
# find the parameters yamls
basename = os.path.splitext(tmpl_in)[0]
plist = "%s.parameters*yaml" % basename
parms_list = glob.glob(plist)
if len(parms_list):
    print("Compiling parameters:")
    for parms in parms_list:
        # print "- %s" % parms
        parms_in = parms
        parms_out = parms_in.replace(".yaml", ".json")
        tmpl = yaml.load(open(parms_in))
        print("- %s -> %s" % (parms_in, parms_out))
        res = json.dumps(tmpl, indent=2)
        open(parms_out, "w").write(res)

# parse and save the template
tmpl = yaml.load(open(tmpl_in))
tmpl_out = tmpl_in.replace(".yaml", ".json")
print("Compiling base template:")
print("- %s -> %s" % (tmpl_in, tmpl_out))
json.dump(tmpl, open(tmpl_out, 'w'), indent=2)
# open(tmpl_out, "w").write(res)
if res:
    print("OK")
else:
    print("Doh!")
    print(res)
