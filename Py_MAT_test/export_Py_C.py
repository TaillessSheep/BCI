# -*- coding: utf-8 -*-
"""
Created on Thu May 31 12:06:43 2018

@author: wi_cui
"""
import math
import scipy.io
import time
import sys

wait = 0

try:
    while(True):    
        for i in range(0,300):
            t = math.sin(2*math.pi*i/300) # t is the export data
            try:
                while scipy.io.loadmat('pydata.mat')['pydata']['check']:
                   time.sleep(0.01)
                   print(wait)
                   wait += 1
            except(KeyboardInterrupt):
                raise
            except:
                pass
            wait = 0
            print('ha')
            scipy.io.savemat('pydata.mat', mdict={'pydata':{'data':t, 'check':True}})
except(KeyboardInterrupt,SystemExit):
    print('Ok~')
