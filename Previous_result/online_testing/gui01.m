function varargout = gui01(varargin)
% GUI01 MATLAB code for gui01.fig
%      GUI01, by itself, creates a new GUI01 or raises the existing
%      singleton*.
%
%      H = GUI01 returns the handle to a new GUI01 or the handle to
%      the existing singleton*.
%
%      GUI01('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI01.M with the given input arguments.
%
%      GUI01('Property','Value',...) creates a new GUI01 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui01_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui01_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui01

% Last Modified by GUIDE v2.5 18-Jul-2017 16:00:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui01_OpeningFcn, ...
                   'gui_OutputFcn',  @gui01_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui01 is made visible.
function gui01_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui01 (see VARARGIN)

% Choose default command line output for gui01
handles.output = hObject;

cd ('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project');
addpath(genpath('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project\\online_testing'))
%% Set variables

Nch = 14;           %number of sensors
Nfe = 6;            %number of features
Tepoc = 2;          %epoc duration in seconds
Tcut = 0.5;         %amount to trim for filter artefacts
Tdelay = 0.5;       %delay between button press and recording
fs = 128;           %sample frequency
Nsa = floor(Tepoc * fs);    %number of samples per epoc
Nsa_l = floor((Tepoc + Tcut) * fs);    %number of samples per epoc before trimming
Ntr_min = 8;                %number of training epocs before first model
score_threshold = 0.7;
Passband = [8 30];
[Filt_B,Filt_A] = butter(5,Passband/(fs/2));

robot_on = 0;
topspeed = 30;

display_spec = 0;
display_feature = 1;

TimeAxis = [0:Nsa-1]/fs;
EEG_window = zeros(Nch,Nsa_l);
EEG_window_filt = zeros(Nch,Nsa_l);
EEG_window_filt_trim = zeros(Nch,Nsa);
handles.y = EEG_window_filt_trim;
handles.x = TimeAxis;
plot(handles.x,handles.y);

%% set timer
handles.timer = timer(...
    'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly.
    'Period', 0.2, ...                      % Initial period is 0.2 sec.
    'TimerFcn', {@update_display,hObject}); % Specify callback function.

%% Initialize receiving data
addpath(genpath('C:\\Users\\Tim\\Downloads\\liblsl-Matlab'))
%addpath(genpath('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project\\software\\labstreaminglayer-master\\LSL\\liblsl-Matlab'))
%ReceiveData
lib = lsl_loadlib();
result = lsl_resolve_byprop(lib,'type','EEG');
EEG_inlet = lsl_inlet(result{1});
% result = lsl_resolve_byprop(lib,'type','Marker');
% Keyb_inlet = lsl_inlet(result{1});

%[ChunkData,Timestamps] = inlet.pull_chunk()
%[SampleData,Timestamp] = inlet.pull_sample(0)

%% Arduino control
ard = arduino('com3','nano');
button = [...
%     {'rest'},{'d2'};
%     {'forward'},{'d4'};
%     {'back'},{'d7'};
    {'left'},{'d8'};
    {'right'},{'d12'}];
[Ncl,~]=size(button);
led_record = 'd3';
led=[...
%     {'rest'},{'d5'};
%     {'forward'},{'d6'};
%     {'back'},{'d9'};
    {'left'},{'d10'};
    {'right'},{'d11'};
    {'record'},{led_record}];
for pin = 1:Ncl + 1
    configurePin(ard, led{pin,2}, 'PWM');
    writeDigitalPin(ard, led{pin,2}, 0);
end
% writeDigitalPin(ard, led.record, 1);

for btn = 1:Ncl
    configurePin(ard, button{btn,2}, 'DigitalInput');
end


% writePWMDutyCycle(ard,led.forward,0.13);
% writeDigitalPin(ard, led.record, 0);

%value = readDigitalPin(ard,'D12');
%% Lego Mindstorm robot control
if robot_on
    robot = legoev3('usb');
    % robot = legoev3('bluetooth','COM7');
    clearLCD(robot)
    writeStatusLight(robot,'off')
    motor_r = motor(robot,'A');
    motor_l = motor(robot,'B');
    motor_m = motor(robot,'D');
    motor_m.Speed = 0;
    motor_r.Speed = 0;
    motor_l.Speed = 0;
    start(motor_r);
    start(motor_l);
    start(motor_m);
    % stop(motor_r)
    % beep(robot)
    % writeLCD(robot,'Hello, LEGO!',5,8)
    % playTone(robot,5000,0.2,5)
    % writeStatusLight(robot,'red')
    % writeStatusLight(robot,'green')
    % writeStatusLight(robot,'off')
    sensor_ir = irSensor(robot,1);
    time_bite  = tic();
    bite_proximity = 100;
    
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui01 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.

function update_display(hObject, eventdata, hfigure) 


% get chunk
EEG_ChunkData = [];
while isempty(EEG_ChunkData)
    [EEG_ChunkData,EEG_Timestamps] = EEG_inlet.pull_chunk();
end
[~,Nsa_in]=size(EEG_ChunkData);
if Nsa_in < Nsa_l
    EEG_window = [EEG_window(:,Nsa_in+1 : Nsa_l), EEG_ChunkData(1:Nch,:)];
elseif Nsa_in >= Nsa_l
    EEG_window = EEG_ChunkData(1:Nch, Nsa_in - Nsa_l + 1:Nsa_in);
end

handles.current_data = EEG_window(1,:);
plot(TimeAxis,EEG_window(1,:));



function varargout = gui01_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
running = 0;

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
