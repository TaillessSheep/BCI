# -*- coding: utf-8 -*-
"""
Created on Thu May 31 12:06:43 2018

@author: wi_cui
"""

# Libraries
import math
import scipy.io
import time
import sys
import shutil

# Parameters
fileName = 'pydata.mat'

# Setup
try:
    shutil.os.remove('pydata.mat')
except:
    print ('No pre built pydata.mat. Safe to start~')
    
scipy.io.savemat(fileName, mdict={'pydata':{'data':0, 'check':True}})

# Main body
try:
    while(True):
        for i in range(0,300):
            t = math.sin(2*math.pi*i/300) # t is the export data
            while (True):
                try:
                    if (scipy.io.loadmat(fileName)['pydata']['check'][0][0][0][0]):
                        time.sleep(0.001)
                    else:
                        print('Breaking 1')
                        break
                except(KeyboardInterrupt):
                    raise
                except(KeyError):
                    break
                except:
                    print(sys.exc_info()[0])
                    print(sys.exc_info()[1])
#                    print(scipy.io.loadmat('pydata.mat'))
                    time.sleep(0.001)
            print ('Writing')
            scipy.io.savemat(fileName, mdict={'pydata':{'data':t, 'check':True}})
except(KeyboardInterrupt,SystemExit):
    print('Ok~')
    shutil.os.remove('pydata.mat')
    sys.exit(1)
    