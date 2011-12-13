import subprocess
import sys
from pylab import *

def run_test(test_name, tag):
    print 'Running test %s ... ' % (test_name,),
    sys.stdout.flush()
    output = subprocess.Popen(['make','test-run','TARGET_CLASS=%s'
            % (test_name,)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = output.communicate()
    print 'done'
    if err != '':
        print err
    ret = []
    for line in out.split('\n'):
        if tag in line:
            split = line.split(' ')
            ret.append( (float(split[1]), float(split[2])) )
    return ret

import math

def report_test(test_results, name):
    x = [math.log(i[0]) for i in test_results]
    y = [i[1] for i in test_results]
    plot(x, y, 'b', label='Scalability Results For %s' % (name,))
    show()

def run_and_show(name):
    results = run_test(name, 'FrameworkTag:')
    report_test(results, name)

run_and_show('CharFrequency.x10')
