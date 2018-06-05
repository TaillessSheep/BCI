# -*- coding: utf-8 -*-
"""
Created on Tue Jun  5 14:23:41 2018

@author: wi_cui

RUN
matlab.engine.shareEngine
IN MATLAB FIRST !!!!!!!!!!!!!!
"""



#import os
import matlab.engine
import math

future = matlab.engine.connect_matlab(async=True)
eng = future.result()
eng.run('global_set',nargout=0)

print('haha')
try:
    while True:
        for i in range(1,300):
        #        eng.workspace['new'] = math.sin(2*math.pi*i/300)
        #        print(eng.length(eng.workspace['new']))
            
            eng.API_Py_1(math.sin(2*math.pi*i/300),nargout=0)
except(KeyboardInterrupt):
    print('Program ending~')
    eng.exit()
    