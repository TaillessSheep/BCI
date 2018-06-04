# -*- coding: utf-8 -*-
"""
Created on Thu May 31 12:06:43 2018

@author: wi_cui
"""

# Libraries
import math
import scipy.io
#import time
import sys

# Parameters
fileName = 'pydata.mat'

# Setup


# Main body
try:
    while(True):    
        for i in range(0,300):
            t = math.sin(2*math.pi*i/300) # t is the export data
            try:
                check = scipy.io.loadmat(fileName)['pydata']['check']
            except(KeyboardInterrupt):
                raise
            except:
                print('Trouble read file.')
                
            if check == 0:
                new_data = t
                check = 1
            else:
                new_data = scipy.io.loadmat(fileName)['pydata']['data']
                new_data = {new_data, }
                
            scipy.io.savemat(fileName, mdict={'pydata':{'data':t, 'check':True}})
except(KeyboardInterrupt,SystemExit):
    print('Ok~')
    sys.exit(1)