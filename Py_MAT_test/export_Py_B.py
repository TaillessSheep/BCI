# -*- coding: utf-8 -*-
"""
Created on Thu May 31 12:06:43 2018

@author: wi_cui
"""
import math
import scipy.io
import sys
import time

try:
    while(True):    
        for i in range(0,300):
            t = math.sin(2*math.pi*i/300) # t is the export data
            print(t);
            try:
                scipy.io.savemat('pydata.mat', mdict={'pydata':{'data':t}})                
            except(KeyboardInterrupt):
                raise
            except:
                print('oops :(')
            time.sleep(0.005)
except(KeyboardInterrupt,SystemExit):
    print('Ok~')
    sys.exit(1)