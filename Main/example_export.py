# This is an example of popping a packet from the Emotiv class's packet queue
# Additionally, exports the data to a CSV file.
# You don't actually need to dequeue packets, although after some time allocation lag may occur if you don't.


import platform
import time
import matlab.engine
import numpy as np

from emokit.emotiv import Emotiv

if platform.system() == "Windows":
    pass


future = matlab.engine.connect_matlab(async=True)
global eng
eng = future.result()
eng.run('global_set',nargout=0)


if __name__ == "__main__":
    with Emotiv(eng, verbose=True, write=True) as headset:
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

