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
  - MATLAB 
    - **Support Package**: LEGO MINDSTORMS EV3
    - **Matlab toolbox**: EEGLAB

### Tasks
- [ ] Signal Acquisition (waiting for the softwave for the headset)
- [ ] Signal Processing
  - [ ] Signal Filtering
  - [ ] Signal Classification
- [ ] Robot Controling 
  - [ ] Signal Classes -> Robot Task Commands
  - [X] Robot Task Scripts (Forward, turn left and turn right)







## Daily notes
  - 5/24/2018: Starting to set up BCI with the old headset (not waiting for the new headset software), EPOC+. The overall impression of the this headset: 4/10 (could have personal bias due to reading Tims report before using it). There are 3 sensors appear to have a weak connection (two of them are on the left size). However, during some random testings with EmotivXavierControlpanel, it seems like the headset is not sensitive to the signal from right side of the brain (left side movement). Plan of next task(PNT): setting up EEGLAB and import data from the headset to MATLAB.
  
  - 5/31/2018: Successfully set up the communication between MATLAB and Python. The communication is base of the loading from or into a file, and it seems a bit slow to me. Not sure if this is a **_potential factor_** that would slow down the performance of the whole project.
