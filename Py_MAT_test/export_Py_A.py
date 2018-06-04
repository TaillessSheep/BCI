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
import os

# Parameters
fileName = 'pydata.mat'

# Set up
wait = 0



# Main body
try:
    while(True):    
        for i in range(0,300):
            t = math.sin(2*math.pi*i/300) # t is the export data
            while True:
                try:
                    scipy.io.loadmat(fileName)['data']
                    continue
                except (KeyboardInterrupt):
                    raise
                except:
                    break
            print('ha')
            scipy.io.savemat(fileName, mdict={'data':t})
#            try:
#                while scipy.io.loadmat(fileName)['pydata']['check'][0][0]:
#                   time.sleep(0.01)
#                   print(wait)
#                   wait += 1
#                break
#            except(KeyboardInterrupt):
#                raise
#            except:
#                pass
#                
#            wait = 0
#            print('ha')
#            scipy.io.savemat(fileName, mdict={'pydata':{'data':t, 'check':True}})
except(KeyboardInterrupt,SystemExit):
    print('Ok~')
    os.remove(fileName)
    sys.exit(1)