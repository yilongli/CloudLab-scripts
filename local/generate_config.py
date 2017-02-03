#!/bin/python
import os
import xml.etree.ElementTree as ET
import sys
os.system('/usr/bin/geni-get manifest > /local/manifest.xml')
tree = ET.parse('/local/manifest.xml')
root = tree.getroot()
num_hosts = 0
msg = ""
nodes = []
for child in root.getchildren():
    if child.tag.endswith('node'):
        details = {}
        for node in child.getchildren():
            if node.tag.endswith('vnode'):
                details['type'] = node.attrib['hardware_type']
            if node.tag.endswith('host'):
		print node.attrib
                details['hostname'] = node.attrib['name']
                details['ip'] = node.attrib['ipv4']
        nodes.append(details)
print 'Writing config for ' + str(len(nodes)) + ' hosts'
print "\nWriting pdsh hosts file"
with open('/local/hosts', 'w') as f:
    f.write(str(nodes))

config = "hosts = [('"+nodes[0]['hostname']+"', '"+nodes[0]['ip']+"', 1)"

exports = "/local/ramcloud_logs "+nodes[0]['ip']+"(rw,sync,no_root_squash,no_subtree_check)\n"

portmap = "portmap: "+nodes[0]['ip']  
lockd = "lockd: "+nodes[0]['ip']  
rquotad = "rquotad: "+nodes[0]['ip']
mountd = "mountd: "+nodes[0]['ip']  
statd = "statd: "+nodes[0]['ip']

for i in range(1,len(nodes)):
    config+=", ('%s', '%s', %s)" % (nodes[i]['hostname'],nodes[i]['ip'],str(i+1))
    exports+="/local/ramcloud_logs %s(rw,sync,no_root_squash,no_subtree_check)\n" % nodes[i]['ip']
    portmap+=", %s" % nodes[i]['ip']
    lockd+=", %s" % nodes[i]['ip']
    rquotad+=", %s" % nodes[i]['ip']
    mountd+=", %s" % nodes[i]['ip']
    statd+=", %s" % nodes[i]['ip']

config+="]"
exports+="\n"
portmap+="\n"
lockd+="\n"
rquotad+="\n"
mountd+="\n"
statd+="\n"

print "\nWriting RAMCloud localconfig file"
with open('/local/localconfig.py', 'w') as f:
    f.write(config)
print "\nWriting exports file"
with open('/local/exports', 'w') as f:
    f.write(exports)
hosts_allow = portmap+lockd+rquotad+mountd+statd

print "\nWriting hosts.allow file"
with open('/local/hosts.allow', 'w') as f:
    f.write(hosts_allow)
with open('/local/node-0-ip.txt', 'w') as f:
    f.write(nodes[0]['ip'])

