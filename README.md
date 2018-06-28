# BCI
- This is a NSERC project being done by William Cui in Concordia University in 2018.
- I aim to control a EV3 robot, Wall-E, with brain computer interface, BCI.
- Hardware: 
  - EV3 MINDSTORM SET (Wall-E, the robot I assembled)
  - g.Nautilus Research
  - g.GAMMAcap2
- Softwave:
  - Python
    - **Package**: Emokit    accessable at https://github.com/openyou/emokit (only needed fot the EPOC+ headset)
    - **Library**: matlab.engine 
      - To install: https://www.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html
      - For more info.: https://www.mathworks.com/help/matlab/matlab_external/get-started-with-matlab-engine-for-python.html
      
  - MATLAB 
    - **Support Package**: LEGO MINDSTORMS EV3
    - **Matlab toolbox**: EEGLAB
    - **API**: g.NEEDaccess MATLAB API *purchasing required; known compatible version of MATLAB: R2015 & R2017b(didn't test the rest)

## Tasks
- [ ] Signal Acquisition 
  - [ ] Softwave for the g.tech headset 
  - [X] Data transition between Python and MATLAB (for EPOC+ headset)
- [ ] Signal Processing
  - [ ] Signal Filtering
  - [ ] Signal Classification
- [ ] Robot Controling 
  - [ ] Signal Classes -> Robot Task Commands
  - [X] Robot Task Scripts (Forward, turn left and turn right)







### Daily notes
  - 05/24/2018: Starting to set up BCI with the old headset (not waiting for the new headset software), EPOC+. The overall impression of the this headset: 4/10 (could have personal bias due to reading Tims report before using it). There are 3 sensors appear to have a weak connection (two of them are on the left size). However, during some random testings with EmotivXavierControlpanel, it seems like the headset is not sensitive to the signal from right side of the brain (left side movement). _Plan of next task(PNT)_: setting up EEGLAB and import data from the headset to MATLAB.
  
  - 05/31/2018: Successfully set up the communication between MATLAB and Python. The communication is base of the loading from or into a file, and it seems a bit slow to me. Not sure if this is a potential factor that would slow down the performance of the whole project.
  
  - 06/01/2018: The communication set up yesterday is imperfect. Trying to do modification. A: Either keep using .mat file to communicate, but, instead of sending one single data point at a time, the .mat file will store the data not read by MATLAB. The plot from MATLAB could be not very fluent, but this should not affect the performance of data processing much. C: Using Python-MATLAB API to connect the two (don't know much about this yet, only saw it available online). _PNT_: Finish A during the weekend, and check out C on Monday.  (Plan B is abandoned)
  
  - 06/05/2018: Data from the EPOC+ headset has **_successfull_** transfered to MATLAB, and plotted out with MATLAB. The communication is done with the Python-MATLAB API library (plan C from last note). _PNT_: 1. The communication done today was only for single channel, so need to extand the system to multi-channels; 2. Identify and delete the useless function in the emokit package; 3. Start looking into the actual signal processing part(now that the data is in MATLAB).
  
  - 06/06/2018: Data acquisition **_done_** of headset EPOC+. Last PNT_1 is done, and 2 partially done. _PNT_:Start looking into the actual signal processing part(last PNT_3).
  
  - 06/09/2018: The software for the g.tech headset is finally arrived. Basic data data acqusition is already understood. Currently working on formating the data for the convenience of later processing.

  - 06/21/2018: Summary of the past two weeks. Encounter sseveral issues: 1. The data recorded does not make sence(in time domain the data is just either a straight line or some smooth curve, nothing likes a EEG signal in time domain) 2. The MATLAB API from g.tec can not initiate data acqusition on my PC and laptop(the first computer used the API is Mahsa's PC, so could be a "no using on a second computer" issue). _PNT_: 1. We are sending a E-mail to the technical support in g.tec for both of the issue just mentioned; 2. Taking a closing look at the data we collected and see if we can figure anything.
  
  - 06/27/2018: Got the basic processing algorithm from Mahsa. So far it is not performing very ideal. On the other hand, the g.NEEDaccess MATLAB API is not compatible with the latest version, R2018a, of MATLAB. The known compatible versions are R2015 and R2017b. The rest are not tested(don't know work or not, but I think it should be fine for all version between R2015 and R2017). The data display on the g.NEEDaccess - Demo Client after applying filter and notch seems pretty good for most of the channels with a few not showing anything. However, while using the MATLAB API, the data collected is a bit disappointing. For most of the channels, the data is just a smoth curve. Even for the channels that looks like a EEG, some how the data has a declining trend, which seem more like a backgroud noise. I believe this is due to the fact that there is more to know about the configuration on the API. _PNT_: Play with the configuration.
