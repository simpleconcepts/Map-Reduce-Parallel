import subprocess
import sys
from pylab import *

from collections import defaultdict

def run_test(test_name, tag):
    print 'Running test %s ... ' % (test_name,),
    sys.stdout.flush()
    output = subprocess.Popen(['make','test-run','TARGET_CLASS=%s'
            % (test_name,)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = output.communicate()
    print 'done'
    if err != '':
        print err
    ret = defaultdict(list)
    for line in out.split('\n'):
        if tag in line:
            split = line.split(' ')
            numasyncs = float(split[-2])
            speedup = float(split[-1])
            description = ' '.join(split[1:3])
            ret.append( ( description, numasyncs, speedup )) )
    return ret

import math

def report_test(test_results, name):
    x = [i[1] for i in test_results]
    y = [i[2] for i in test_results]
    plot(x, y, 'b', label='Scalability Results For %s' % (name,))
    title(test_results[0][0])
    ybound = min(max(x), max(y))
    print ybound
    plot([0, ybound], [0, ybound], 'r--')
    grid()
    xlabel('Number of asyncs')
    ylabel('Relative Speedup')
    show()

def run_and_show(name):
    results = run_test(name, 'FrameworkTag:')
    report_test(results, name)

if __name__ == '__main__':
    import sys
    if len(sys.argv) != 2:
        print 'Please provide test program'
        exit()
    run_and_show(sys.argv[1])
