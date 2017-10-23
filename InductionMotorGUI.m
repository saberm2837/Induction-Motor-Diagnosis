function varargout = InductionMotorGUI(varargin)
% INDUCTIONMOTORGUI MATLAB code for InductionMotorGUI.fig
%      INDUCTIONMOTORGUI, by itself, creates a new INDUCTIONMOTORGUI or raises the existing
%      singleton*.
%
%      H = INDUCTIONMOTORGUI returns the handle to a new INDUCTIONMOTORGUI or the handle to
%      the existing singleton*.
%
%      INDUCTIONMOTORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INDUCTIONMOTORGUI.M with the given input arguments.
%
%      INDUCTIONMOTORGUI('Property','Value',...) creates a new INDUCTIONMOTORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before InductionMotorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to InductionMotorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help InductionMotorGUI

% Last Modified by GUIDE v2.5 28-Nov-2013 17:58:07

% Begin initialization code - DO NOT EDIT


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InductionMotorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @InductionMotorGUI_OutputFcn, ...
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


% --- Executes just before InductionMotorGUI is made visible.
function InductionMotorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to InductionMotorGUI (see VARARGIN)

% Choose default command line output for InductionMotorGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes InductionMotorGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = InductionMotorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnBrowse.
function btnBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename pathname] = uigetfile({'*.mat'},'File Selector');
pathname = strcat(pathname,filename);
set(handles.txtHiddenPath,'String',pathname);


% --- Executes on selection change in popFFTWindow.
function popFFTWindow_Callback(hObject, eventdata, handles)
% hObject    handle to popFFTWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popFFTWindow contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popFFTWindow


% --- Executes during object creation, after setting all properties.
function popFFTWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popFFTWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnRun.
function btnRun_Callback(hObject, eventdata, handles)
% hObject    handle to btnRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filepath = get(handles.txtHiddenPath,'String');
data=load(filepath); % loading *.mat file
Fs = str2num(get(handles.txtSamplingFrequency,'String')); % Sampling Frequency (Hz)
np = str2num(get(handles.txtNumberOfPoles,'String')); % Number of poles
fsync = str2num(get(handles.txtNominalFrequency,'String')); % Nominal frequency (Hz)
nr = str2num(get(handles.txtRatedSpeed,'String')); % Rated speed (revolutions per minute)
gc = str2num(get(handles.txtCurrentGainFactor,'String')); % Current gain factor
nb = 50000; % Number of rotor bars
global win;
win = get(handles.popFFTWindow,'value');
%%get(handles.popFFTWindow,'Value') % 1 for flat top weighted window, 2 for Hanning window, 3 for Hamming window, 4 for Blackman window

% Pre-calculations
ns = 120*fsync/np; %Synchronous speed (rpm)
s = (ns-nr)/ns;



% Analyzing the phase current in time domain
Li=length(data.t);
t=(0:Li-1)/Fs;
ia = data.i*gc;
axes(handles.axsStatorCurrent);
cla;
plot(t,ia,'linewidth',2,'color', 'k');
grid on;
xlabel('t(s)','fontsize',10,'fontweight','b');
ylabel('i_a(A)','fontsize',10,'fontweight','b');
set(gca,'FontSize',10);
axis([0 0.2 ceil(min(ia-1)) floor(max(ia+1))]);


% Analyzing the frequency spectral in frequency domain    

switch win
    case 1
        iaw = flattopwin(Li).*ia;
    case 2
        iaw = hann(Li).*ia;
    case 3
        iaw = hamming(Li).*ia;
    case 4
        iaw = blackman(Li).*ia;
    otherwise
        iaw = flattopwin(Li).*ia;
end

Ia = fft(iaw)/Li;
f = (Fs/2*linspace(0,1,Li/2))';
IadB = 20*log(2*abs(Ia(1:Li/2)));
axes(handles.axsFrequencySpectrum);
cla;
plot(f,IadB,'linewidth',2,'color', 'k');
grid on;
xlabel('f(Hz)','fontsize',10,'fontweight','b');
ylabel('| I_a |_{dB}','fontsize',10,'fontweight','b');
axis([20 100 -200 50]);
set(gca,'FontSize',10);

%Truncating the current spectrum to remove unwanted part
f1 = (1-3*s)*fsync;
f2 = (1+3*s)*fsync;
L1 = floor(f1*Li/Fs);
L2 = floor(f2*Li/Fs);
IaF = IadB(L1:L2);
L3 = length(IaF);
fas=linspace(L1*Fs/Li-Fs/Li,L2*Fs/Li-Fs/Li,L3);
hold on;

plot(fas,IaF,'linewidth',2,'color', 'r');

[peaks,locs] = findpeaks(IaF,'MinPeakHeight',-100,'MinPeakDistance',floor(L3/4));
inx = locs+L1-1;
axes(handles.axsFrequencySpectrum);
hold on;
plot(inx*Fs/Li-Fs/Li,IadB(inx),'rs','MarkerFaceColor','g');

F_index = numel(peaks);
peaks = round(peaks*100)/100;
Freq = round((inx*Fs/Li-Fs/Li)*100)/100;
if F_index == 1
    text(25, 5,'No Broken Bar Fault', 'Color', 'b');
    amp = num2str(peaks); % Fundamental component amplitude
    amp_str = strcat('Fundamental in dB = ',amp);
    text(25, -20 ,amp_str, 'Color', 'b');
    FreqStr=num2str(Freq);
    Freq_str = strcat('Fundamental Freq(Hz) = ',FreqStr);
    text(65, -20 ,Freq_str, 'Color', 'b');
else
    text(25, 5,'Broken Bar Fault Detected', 'Color', 'b');
    amp1 = num2str(peaks(2)); % Fundamental component 
    amp_str = strcat('Fundamental in dB = ',amp1);
    text(25, -20 ,amp_str, 'Color', 'b');
    amp2 = num2str(peaks(1)); % Lower side-band
    amp_str = strcat('Lower side-band in dB = ',amp2);
    text(25, -45 ,amp_str, 'Color', 'b');
    amp3 = num2str(peaks(3)); % Fundamental component amplitude
    amp_str = strcat('Upper side-band in dB = ',amp3);
    text(25, -70 ,amp_str, 'Color', 'b');
    
    Freq1 = num2str(Freq(2)); % Fundamental component 
    Freq_str = strcat('Fundamental Freq(Hz) = ',Freq1);
    text(68, -20 ,Freq_str, 'Color', 'b');
    Freq2 = num2str(Freq(1)); % Lower side-band
    Freq_str = strcat('Lower side-band Freq(Hz) = ',Freq2);
    text(68, -45 ,Freq_str, 'Color', 'b');
    Freq3 = num2str(Freq(3)); % Fundamental component amplitude
    Freq_str = strcat('Upper side-band Freq(Hz) = ',Freq3);
    text(68, -70 ,Freq_str, 'Color', 'b');
end



function txtSamplingFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to txtSamplingFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSamplingFrequency as text
%        str2double(get(hObject,'String')) returns contents of txtSamplingFrequency as a double


% --- Executes during object creation, after setting all properties.
function txtSamplingFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSamplingFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtCurrentGainFactor_Callback(hObject, eventdata, handles)
% hObject    handle to txtCurrentGainFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtCurrentGainFactor as text
%        str2double(get(hObject,'String')) returns contents of txtCurrentGainFactor as a double


% --- Executes during object creation, after setting all properties.
function txtCurrentGainFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtCurrentGainFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtNumberOfPoles_Callback(hObject, eventdata, handles)
% hObject    handle to txtNumberOfPoles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNumberOfPoles as text
%        str2double(get(hObject,'String')) returns contents of txtNumberOfPoles as a double


% --- Executes during object creation, after setting all properties.
function txtNumberOfPoles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNumberOfPoles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtNominalFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to txtNominalFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNominalFrequency as text
%        str2double(get(hObject,'String')) returns contents of txtNominalFrequency as a double


% --- Executes during object creation, after setting all properties.
function txtNominalFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNominalFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtRatedSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to txtRatedSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtRatedSpeed as text
%        str2double(get(hObject,'String')) returns contents of txtRatedSpeed as a double


% --- Executes during object creation, after setting all properties.
function txtRatedSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtRatedSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
