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



## Folder Description
- Main:           The main code to execute the whole BCI system and some scripts that call functions from other folders
- gTech_BCI:      Signal recording related MATLAB script
- DataProcessing: Signal processing related MATLAB script
- Materials:      Some good to know reading materials


### Tasks
- [X] Signal Acquisition 
  - [X] Softwave for the g.tech headset 
  - [X] Data transition between Python and MATLAB (for EPOC+ headset)
- [X] Signal Processing (Working on improving the accuracy)
  - [X] Signal Filtering
  - [X] Signal Classification
- [X] Robot Controling 
  - [X] Signal Classes -> Robot Task Commands
  - [X] Robot Task Scripts (Forward, turn left and turn right)



* NOTE: Details about how to use the system can be found in Wiki.
