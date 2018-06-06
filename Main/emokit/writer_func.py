# -*- coding: utf-8 -*-
"""
Created on Wed Jun  6 10:33:46 2018
@author: wi_cui

This package contains functions to insert into the writer.py
"""

import numpy as np
import matlab
import sys

def export(eng,data):
    try:
        data_len = len(data)
        if data_len != 14:
            raise ValueError('Incrrect size of data with %s values' %data_len)
        data_double = matlab.double(list(np.double(data)))
        eng.update(data_double,nargout=0)
    except KeyboardInterrupt:
        raise
    except :
        print(sys.exc_info()[0])
        print(sys.exc_info()[1])


