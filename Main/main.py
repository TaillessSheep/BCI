"""
Created on Tue Jun  5 14:23:41 2018
@author: wi_cui

This is the main drive to activate the whole BCI
But most of the functions, especially involving using MATLAB, need to be added into
'emokit\writer_func.py' and then call from 'emokit\writer.py'

MAKE SURE THE COMMAND
matlab.engine.shareEngine
&

IS RUN IN MATLAB FIRST !!!!!!!!!!!!!!
"""

import platform
import time
import matlab.engine
#import numpy as np

from emokit.emotiv import Emotiv

if platform.system() == "Windows":
    pass


future = matlab.engine.connect_matlab(async=True)
#global eng
eng = future.result()
eng.run('setup',nargout=0)


if __name__ == "__main__":
    with Emotiv(eng, record=False, verbose=True, write=True) as headset:
        print("Serial Number: %s" % headset.serial_number)
        print("Exporting data... press control+c to stop.")
        try:
            while headset.running:
                try:
                    packet = headset.dequeue()
                except KeyboardInterrupt:
                    raise
                    headset.stop()
                except Exception:
                    headset.stop()
                time.sleep(0.001)
        except(KeyboardInterrupt):
            print('Program ending~')
            eng.exit()

