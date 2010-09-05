#!/usr/bin/env python

import os
import os.path
import sys

global verbose
verbose = 0

PREFIXES = ('t_','m_','l_', 's_')
def main(srcdir, destdir):
    # grab all jpegs in source tree and optimize them with jpegtrans
    # in the destination directory
    abs_src = os.path.abspath(srcdir)
    abs_dest = os.path.abspath(destdir)
    jpgs = []
    for root, dirs, files in os.walk(srcdir):
        for name in files:
            lname = name.lower()
            pfx = lname[0:2]
            if lname.endswith('jpg') and pfx in PREFIXES:
                jpgs.append(os.path.abspath(os.path.join(root, name)))
    conversion = [ (jpg, jpg.replace(abs_src, abs_dest)) for jpg in jpgs ]
    ct = 0
    for c in conversion:
        src, dest = c
        destdir = os.path.dirname(dest)
        if not os.path.exists(destdir):
            os.makedirs(destdir)
        cmd = 'jpegtran -optimize "%s" > "%s"' % (src,dest)
        try:
            v = os.system(cmd)
            if v:
                print "Copying because of error on %s" % src
                os.system('cp "%s" "%s"' % (src, dest))
        except Exception, ex:
            print ex
        ct += 1
        if (ct % 100) == 0: 
            print ".",
            sys.stdout.flush()
    print
        
def usage():
    print """Run jpegtran on all .jpg images in a subdirectory placing the
    optimized version in the dest dir (-h for help)"""

if __name__ == '__main__':
    import optparse

    p = optparse.OptionParser(usage=usage())
    p.add_option('-v', '--verbose', action='store', dest='verbose',
                 default=1, type="int",
                 help='verbose level 0-9.  Default = 1')
    p.add_option('-s', '--srcdir', action='store', dest='srcdir',
                 help='Source directory')
    p.add_option('-d', '--destdir', action="store", dest="destdir",
                 help="Destination directory")
    (options, rest) = p.parse_args()
    verbose = options.verbose
    if not options.destdir or not options.srcdir:
        print "You must specify both a source and destination directory"
    else:
        main(options.srcdir, options.destdir)


