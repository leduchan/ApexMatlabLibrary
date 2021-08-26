%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------------
% Company: APEX TECHNOLOGIES 
% Author: LE Duc Han, R&D engineer
% Date:  10/09/2020
% ---------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
close all;
clear;
%----------------------------------------------------------------------
%% Initialize APEX OSA Instrument
% Create the TCP/IP object if it does not exist
% otherwise use the object that was found.
APEX_OSA = tcpip('192.168.1.52', 5900);

% Variables and constants of the equipement

% Set properties for writing the data if needed
% OSA_APEX.OutputBufferSize = 3e4;
% Set properties for reading the data if needed  
%set(OSA_APEX, 'InputBufferSize', 200);  % Specify the size of the input buffer in bytes for reading 
APEX_OSA.InputBufferSize = 3e5;          %  
% Specify the waiting time to complete a read or write operation if needed 
% deafult Timeout = 10 s
% OSA_APEX.Timeout=30;                   

% Open connection to the APEX OSA. 
fopen(APEX_OSA);

% Identify the APEX OSA
fprintf(APEX_OSA, '*IDN?');             % Sending the command '*IDN?' ot APEX OSA
ID_APEX_OSA = fscanf(APEX_OSA) ;        % Reading the txt data from APEX OSA
                                        % format as text (default) 
%ID_APEX_OSA = query(OSA_APEX, '*IDN?');
fprintf('%s\n', ID_APEX_OSA);

%% Parameter of APEX OSA
% -------------------------------------------------------------------------
% Set the wavelength measurement span
% Span is expressed in nm
Span = 0.5 ; % in [nm]
Command = "SPSPANWL" + num2str(Span) + "\n"; % Command to send or Command = strcat('SPSPANWL', num2str(span+0.0)) 
fprintf(APEX_OSA, Command);
 
% Get the wavelength measurement span of OSA
% Span is expressed in nm
% Command = "SPSPANWL?\n" ;
% fprintf(OSA_APEX, Command) ;
% Span = fscanf(OSA_APEX,'%f') ;        % Reading the txt data from APEX OSA  

% -------------------------------------------------------------------------
% Set the wavelength measurement center
% Center is expressed in nm
Center = 1550.00; 
Command = "SPCTRWL" + num2str(Center) + "\n";
fprintf(APEX_OSA, Command);

% Get the wavelength measurement center
% Center is expressed in nm
% Command = "SPCTRWL?\n" ;
% fprintf(OSA_APEX, Command);
% Center = fscanf(OSA_APEX,'%f');

% -------------------------------------------------------------------------
% Set X Resolution
% Set the wavelength measurement resolution
% Resolution is expressed in the value of 'ScaleXUnit'
SweepResolution = 1.12e-3; % in nm of ScaleXUnit
Resolution = SweepResolution; 
Command = "SPSWPRES" + num2str(Resolution) + "\n"; 
fprintf(APEX_OSA, Command);

% Get X Resolution
% Get the wavelength measurement resolution
% Resolution is expressed in the value of 'ScaleXUnit'
% Command = "SPSWPRES?\n" ;
% fprintf(OSA_APEX, Command);
% SweepResolution = (fscanf(OSA_APEX,'%f'))*1e3; % convert in pm

% -------------------------------------------------------------------------
% Set Y Resolution
% Set the Y-axis power per division value
% Resolution is expressed in the value of 'ScaleYUnit'
% dYResolution = 0.215;
% Command = "SPDIVY" + num2str(dYResolution) + "\n";
% fprintf(OSA_APEX, Command);

% % Get the Y-axis power per division value
% % Resolution is expressed in the value of 'ScaleYUnit'
% Command = "SPDIVY?\n";
% fprintf(APEX_OSA, Command);
% fscanf(APEX_OSA,'%f');

% -------------------------------------------------------------------------
% Set the number of points for the measurement
NPoints = 3566;   
Command = "SPNBPTSWP" + num2str(NPoints) + "\n"; 
fprintf(APEX_OSA, Command);

% % Get the number of points for the measurements 
% Command = "SPNBPTSWP?\n";
% fprintf(OSA_APEX, Command);

%% Measurements
% Runs a measurement and returns the trace of the measurement (between 1 and 6)
% If Type is
%     - "auto" or 0, an auto-measurement is running
%     - "single" or 1, a single measurement is running (default)
%     - "repeat" or 2, a repeat measurement is running
% In this function, the connection timeout is disabled and enabled after the
% execution of the function
% "auto"
%Command = "SPSWP0\n";
%"single":      
Command = "SPSWP1\n";
%"repeat":
%Command = "SPSWP2\n";
fprintf(APEX_OSA,Command); % Start a single sweep

% % Stop a measurement
% Command = "SPSWP3\n"; 
% fprintf(APEX_OSA,Command);

%% Get data (GetData)
% Get the spectrum data of a measurement
% returns a 2D list [Y-axis Data, X-Axis Data]
% ScaleX is a string which can be :
%     - "nm" : get the X-Axis Data in nm (default)
%     - "GHz": get the X-Axis Data in GHz
% ScaleY is a string which can be :
%     - "log" : get the Y-Axis Data in dBm (default)
%     - "lin" : get the Y-Axis Data in mW
% TraceNumber is an integer between 1 (default) and 6

TraceNumber =1; 
% Y-axis Data for the measured power 
% "lin" Data:
%Command = "SPDATAL" + str(int(TraceNumber)) + "\n"; 
% 'log' data 
Command = "SPDATAD" + int2str(TraceNumber) + "\n";
fprintf(APEX_OSA,Command); 
% Pause for the communication delay
pause(3);   
% Get Y-axis power data from APEX OSA 
while(APEX_OSA.BytesAvailable>0)
    YData = fscanf(APEX_OSA,'%f');
end

% Get Y-axis wavelength data  from APEX OSA
%Command = "SPDATAF" + str(int(TraceNumber)) + "\n"  %"GHz"
Command = "SPDATAWL" + int2str(TraceNumber) + "\n"; 
fprintf(APEX_OSA,Command); 
% Pause for the communication delay
pause(3);   
% Get Y-axis power data from APEX OSA 
while(APEX_OSA.BytesAvailable>0) 
    XData = fscanf(APEX_OSA,'%f');
end

% Get data from APEX OSA
Data =[flip(XData(2:end,1)) flip(YData(2:end,1))];

%% SAVE DATA
%--------------------------------------------------
% save measured spectrum using SCPI remote control commands 
%--------------------------------------------------
% Save a trace on local hard disk
% FileName is a string representing the path of the file to save
% TraceNumber is an integer between 1 (default) and 6
% Type is the type of the file to save
% Type is a string between the following values:
%     - Type = "DAT" : data are saved in a binary format (default)
%     - Type = "TXT" : data are saved in a text format
        
% if Type:
%    Command = "SPSAVEB" + str(TraceNumber) + "_" + str(FileName) + "\n"
% else:
%    Command = "SPSAVEA" + str(TraceNumber) + "_" + str(FileName) + "\n"
FileName = 'C:\ApexSpec\SpectTXT'; % Save a trace on local hard disk D of OSA Device 
Command = "SPSAVEB" + num2str(TraceNumber) + "_" + FileName + "\n";
fprintf(APEX_OSA,Command);
%fprintf(ApexOSA,"SPSWP" + "1"+ "_" + 'C:\SaveFiles\SpectTXT' + "\n"); % Save a trace on local hard disk C

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
fclose(APEX_OSA); 
delete(APEX_OSA); 
clear OSA_APEX;

%% ---------------------------------------------------------------------
%   THE END
%%---------------------------------------------------------------------
