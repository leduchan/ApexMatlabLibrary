%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------------
% Company: APEX TECHNOLOGIES 
% Author: LE Duc Han, R&D engineer
% Date:  10/09/2020
% ---------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize APEX OSA Instrument
clc;
close all;
%clear all;
clear; 
% -------------------------------------------------------------------------
%tcpip('192.168.1.52', 5900);
APEX_OSA = OSA_VISA_updated( '192.168.1.52',5900);

% There are two types of methods of class : 
%   - Ordinary methods and static methods
% Ordinary methods: Call ordinary methods using MATLAB function syntax or dot notation.
%   obj.methodName(arg) % obj is not the arguement input  
%   methodName(obj,arg) % obj is the input arguement 
% Static methods: do not require an object of the class. 
%   Call staticMethod using the syntax classname.methodname(arg)

% -------------------------------------------------------------------------
% Identity of APEX OSA device 
%ID_osa = APEX_OSA.GetID()
ID_osa = GetID(APEX_OSA);
fprintf('%s\n', ID_osa);

% -------------------------------------------------------------------------
% % Set and Get the Start wavelength and stop wavelength (WL) 
% % Set start and stop WL
% StartWavelength = 1552.750; % nm   % 1549.750; % nm
% StopWavelength = 1560.250;  % nm   % 1550.250
% APEX_OSA.SetStartWavelength(StartWavelength);
% APEX_OSA.SetStopWavelength(StopWavelength); 
% % StartWL = APEX_OSA.GetStartWavelength()
% % StopWL  = APEX_OSA.GetStopWavelength() 

% -------------------------------------------------------------------------
% Set and Get the Span
% Set Span
Span = 0.5; % nm
APEX_OSA.SetSpan(Span); 
% Get Span
%Span = APEX_OSA.GetSpan()

% Set and Get the Center WL
% Set center WL
Center = 1550.00; % nm
APEX_OSA.SetCenter(Center); 
% Get center WL
% Center = APEX_OSA.GetSpan();
% fprintf('%f\n', Center);
fprintf('%.2f\n', APEX_OSA.Span);

% -------------------------------------------------------------------------
% % Set X resolution 
% SweepResolution = 1.12e-3; % in nm of ScaleXUnit
% APEX_OSA.SetXResolution(SweepResolution); 
% % Get X resolution
% SweepResolution = APEX_OSA.GetXResolution();
% fprintf('%f\n', SweepResolution);

% -------------------------------------------------------------------------
% % Set Y Resolution
% dBdivResolution = 5.40; % dB/div
% APEX_OSA.SetYResolution(dBdivResolution);
% % Get Y Resolution
% dBdivResolution = APEX_OSA.GetYResolution();
% fprintf('%f\n', dBdivResolution);

% -------------------------------------------------------------------------
% Set number of points 
NPoints = 3565; 
APEX_OSA.SetNPoints(NPoints); 
% Get number of points
%NPoints = APEX_OSA.GetNPoints();
fprintf('%i\n', APEX_OSA.NPoints);

% -------------------------------------------------------------------------
APEX_OSA.SetScaleXUnit('nm'); 

% -------------------------------------------------------------------------
APEX_OSA.Run(1);

% -------------------------------------------------------------------------
% Get measured data from APEX OSA
Data = APEX_OSA.GetData('nm','log',1);

%% SAVE DATA
% Save a trace on local hard disk
FileName = 'C:\ApexSpec\SpectTXT'; % Save a trace on local hard disk D of OSA Device
%SaveToFile(obj, FileName, TraceNumber, Type)
APEX_OSA.SaveToFile(FileName,1,0);

%--------------------------------------------------
% save measured spectrum using matlab code
%--------------------------------------------------
% Save data into .txt files
% Create a sample text file that contains floating-point numbers.
% The first three lines: 
    % Version	1	
    % Nb.pts	3565	
    % nm	dBm
    % measured data    
% fileID = fopen('OSA_Spectrum.txt','w');
fileID = fopen('OSA_Spectrum.txt','w');
fprintf(fileID,'%6s %12s\n','Version','1');
fprintf(fileID,'%6s %12s\n','Nb.pts','3565');
fprintf(fileID,'%6s %12s\n','nm','dBm');
fprintf(fileID,'%6.12f %12.12f\n',Data');
fclose(fileID);

% Save data (.mat)
filename = 'ApexSpec';  
fullpath = "D:\Work\Remote Control\Matlab\Example\" + filename; 
save(fullpath,'Data');

%% DATA ANALYSIS
% Plots
figure; grid on; hold on; 
plot(Data(:,1),Data(:,2),'-b','linewidth',2);
box on
%% Disconnect and clean up the server connection. 
APEX_OSA.close(); 

