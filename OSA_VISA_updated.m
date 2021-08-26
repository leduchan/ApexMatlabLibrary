%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------------
% Company: APEX TECHNOLOGIES 
% Author: LE Duc Han, R&D engineer
% Date:  10/09/2020
% ---------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef OSA_VISA_updated < handle
   
    % ------------------------------------------------------------------------------
    %                                   AP2XXX CONSTANTS
    % ------------------------------------------------------------------------------
    properties (Constant)
        % MIN AND MAX WAVELENGTH
        AP2XXX_WLMIN = 1200;
        AP2XXX_WLMAX = 1700;
        % MIN AND MAX WAVELENGTH SPAN
        AP2XXX_MINSPAN = 0.01;
        AP2XXX_MAXSPAN = 100;
        % MIN AND MAX CENTER WAVELENGTH
        AP2XXX_MAXCENTER = OSA_VISA_updated.AP2XXX_WLMAX - OSA_VISA_updated.AP2XXX_MINSPAN / 2;
        AP2XXX_MINCENTER = OSA_VISA_updated.AP2XXX_WLMIN + OSA_VISA_updated.AP2XXX_MINSPAN / 2;
        % MIN AND MAX Y RESOLUTION
        AP2XXX_MINYRES = 0.001;
        AP2XXX_MAXYRES = 100;
        % MIN AND MAX POINTS NUMBER
        AP2XXX_MINNPTS = 2;
        AP2XXX_MAXNPTS = 1000000;
    end
    
    properties
      ReadBufferSize  % Default = 4096. The buffer size used for reading responses in methods ReadString, QueryString. 
      Session % TCP/IP Interface Session 
              % Use it to acces the full scope of available interfaces,
              % methods and properties of Class OSA
      StartWavelength;
      StopWavelength;
      Span;
      Center;
      SweepResolution; 
      ValidSweepResolutions;
      NPoints;
      NoiseMaskValue;
      ValidScaleUnits;
      ScaleXUnit;
      ScaleYUnit;
      ValidPolarizationModes;
      PolarizationMode;
      Validtracenumbers;
      tracenumber;
      NAverageOSA; 
   end
   
   methods
       function obj = OSA_VISA_updated(IPaddress,PortNumber)
           try
           % IPAddress = '192.168.1.52'; 
           % Initiates a new TCP/IP connection specified by resourceString IP address and port number. 
           obj.Session = tcpip(IPaddress, PortNumber);
           
           % Set properties for reading the data if needed  
           %set(OSA_APEX, 'InputBufferSize', 200);  % Specify the size of the input buffer in bytes for reading 
           obj.Session.InputBufferSize = 3e5;          %  
           % Specify the waiting time to complete a read or write operation if needed % deafult Timeout = 10 s
           % OSA_APEX.Timeout=30;
           
           % Open connection to the APEX OSA. 
           fopen(obj.Session);
           catch
               error('Error TCP/IP Connection');
           end
           % Variables and constants of the equipement
          obj.StartWavelength = obj.AP2XXX_WLMIN;
          obj.StopWavelength = obj.AP2XXX_WLMAX;
          obj.Span = obj.AP2XXX_WLMAX - obj.AP2XXX_WLMIN;
          obj.Center = obj.AP2XXX_WLMIN + (obj.Span / 2);
          obj.SweepResolution = 1.12*1e-3; 
          obj.ValidSweepResolutions = [0 , 1 , 2];
          obj.NPoints = 1000;
          obj.NoiseMaskValue = -70;
          obj.ValidScaleUnits = [0 , 1];
          obj.ScaleXUnit = 1;
          obj.ScaleYUnit = 1;
          obj.ValidPolarizationModes = [0 , 1 , 2 , 3];
          obj.PolarizationMode = 0;
          obj.Validtracenumbers = [0 , 1 , 2 , 3 , 4 , 5 , 6];
          obj.tracenumber = 1;
          obj.NAverageOSA = 5;
       end
       
      function IDobj = GetID(obj)
            % Identify the APEX OSA
            fprintf(obj.Session, '*IDN?');   % Sending the command '*IDN?' ot APEX OSA
            IDobj = fscanf(obj.Session) ;    % Reading the txt data from APEX OSA
                                             % format as text (default) 
                                             %ID_APEX_OSA = query(OSA_APEX, '*IDN?');
      end
      
      function close(obj)
          %% Disconnect and clean up the server connection. 
          fclose(obj.Session); 
          delete(obj.Session); 
          clear obj.Session;
      end
      
      function SetStartWavelength(obj,Wavelength)
         % Set the start wavelength of the measurement span
         % Wavelength is expressed in nm
         Command = "SPSTRTWL" + num2str(Wavelength) + "\n";
         fprintf(obj.Session, Command);
         
         obj.StartWavelength = Wavelength;
         obj.Span = obj.StopWavelength - obj.StartWavelength;
         obj.Center = obj.StartWavelength + (obj.Span / 2);
      end
      
      function GetStartWavelength(obj)
         % Get the start wavelength of the measurement span
         % Wavelength is expressed in nm
         Command = "SPSTRTWL?\n";
         fprintf(obj.Session, Command);
         obj.StartWavelength = fscanf(obj.Session,'%f');
      end
      
      function SetStopWavelength(obj, Wavelength)
          % Set the stop wavelength of the measurement span
          % Wavelength is expressed in nm
          Command = "SPSTOPWL" + num2str(Wavelength) + "\n"; 
          fprintf(obj.Session, Command);
          
          obj.StopWavelength = Wavelength;
          obj.Span = obj.StopWavelength - obj.StartWavelength;
          obj.Center = obj.StartWavelength + (obj.Span /2);
      end
      
      function GetStopWavelength(obj)   
        % Get the stop wavelength of the measurement span
        % Wavelength is expressed in nm
        Command = "SPSTOPWL?\n";    
        fprintf(obj.Session, Command);
        obj.StopWavelength = fscanf(obj.Session,'%f') ;
      end
      
      
      function SetSpan(obj,Span)
             % Set the wavelength measurement span
             % Span is expressed in nm
             Command = "SPSPANWL" + num2str(Span) + "\n"; % Command to send or Command = strcat('SPSPANWL', num2str(span+0.0)) 
             fprintf(obj.Session, Command);
             
             obj.Span = Span;
             obj.StopWavelength = obj.Center + (obj.Span / 2);
             obj.StartWavelength = obj.Center - (obj.Span / 2);
      end
      
      function GetSpan(obj)
            % Get the wavelength measurement span of OSA
            % Span is expressed in nm
            Command = "SPSPANWL?\n" ;
            fprintf(obj.Session, Command) ;
            obj.Span = fscanf(obj.Session,'%f') ;        % Reading the txt data from APEX OSA  
      end
      
      function SetCenter(obj, Center)
            %Set the wavelength measurement center
            %Center is expressed in nm
            Command = "SPCTRWL" + num2str(Center) + "\n";
            fprintf(obj.Session, Command) ;
            
            obj.Center = Center;
            obj.StopWavelength = obj.Center + (obj.Span / 2);
            obj.StartWavelength = obj.Center - (obj.Span / 2);
      end
      
      function GetCenter(obj)
            %Get the wavelength measurement center
            %Center is expressed in nm
            Command = "SPCTRWL?\n";
            fprintf(obj.Session, Command) ;
            obj.Center = fscanf(obj.Session,'%f') ;        % Reading the txt data from APEX OSA  
      end
      
      function SetXResolution(obj, Resolution)
        %Set the wavelength measurement resolution
        %Resolution is expressed in the value of 'ScaleXUnit'
        Command = "SPSWPRES" + num2str(Resolution) + "\n"; 
        fprintf(obj.Session, Command) ;
        
        obj.SweepResolution = Resolution;
      end
      
      function GetXResolution(obj)
        % Get the wavelength measurement resolution
        % Resolution is expressed in the value of 'ScaleXUnit'
        Command = "SPSWPRES?\n";
        fprintf(obj.Session, Command);
        obj.SweepResolution = fscanf(obj.Session,'%f') ;        % Reading the txt data from APEX OSA
      end
      
      function SetYResolution(obj, Resolution)
            % Set the Y-axis power per division value
            % Resolution is expressed in the value of 'ScaleYUnit'
            Command = "SPDIVY" + num2str(Resolution) + "\n";
            fprintf(obj.Session, Command);
      end
      
      function Resolution=GetYResolution(obj)
            % Get the Y-axis power per division value
            % Resolution is expressed in the value of 'ScaleYUnit'
            Command = "SPDIVY?\n";
            fprintf(obj.Session, Command);
            Resolution = fscanf(obj.Session,'%f') ;         
      end
      
      function SetNPoints(obj, NPoints)
            % Set the number of points for the measurement
            Command = "SPNBPTSWP" + num2str(NPoints) + "\n"; 
            fprintf(obj.Session, Command);
            obj.NPoints = NPoints;
      end
      
      function GetNPoints(obj)
            % Set the number of points for the measurement
            Command = "SPNBPTSWP?\n"; 
            fprintf(obj.Session, Command);
            obj.NPoints = fscanf(obj.Session,'%i') ;
      end
      
      function Run(obj, Type)
%               Runs a measurement and returns the trace of the measurement (between 1 and 6)
%               If Type is
%                 - "auto" or 0, an auto-measurement is running
%                 - "single" or 1, a single measurement is running (default)
%                 - "repeat" or 2, a repeat measurement is running
%               In this function, the connection timeout is disabled and enabled after the execution of the function
               if Type == 0
                    Command = "SPSWP0\n";
               elseif Type == 2
                    Command = "SPSWP2\n";
               else
                    Command = "SPSWP1\n"; 
               end
               fprintf(obj.Session, Command);
      end
      
      function Stop(obj)
          % Stop a measurement
          Command = "SPSWP3\n";
          fprintf(obj.Session, Command);
      end
      
      function Data = GetData(obj, ScaleX, ScaleY, TraceNumber)         
%         Get the spectrum data of a measurement
%         returns a 2D list [Y-axis Data, X-Axis Data]
%         ScaleX is a string which can be :
%             - "nm" : get the X-Axis Data in nm (default)
%             - "GHz": get the X-Axis Data in GHz
%         ScaleY is a string which can be :
%             - "log" : get the Y-Axis Data in dBm (default)
%             - "lin" : get the Y-Axis Data in mW
%         TraceNumber is an integer between 1 (default) and 6
            
            % Get Y-axis Data
            if ScaleY == "lin"
                Command = "SPDATAL" + int2str(TraceNumber) + "\n";
            else
                Command = "SPDATAD" + int2str(TraceNumber) + "\n";
            end
            fprintf(obj.Session,Command); 
            % Pause for the communication delay
            pause(3);   
            % Get Y-axis data from APEX OSA 
            while(obj.Session.BytesAvailable>0)
                YData = fscanf(obj.Session,'%f');
            end
            
            % Get X-axis Data
            if ScaleX == "ghz"
                Command = "SPDATAF" + int2str(TraceNumber) + "\n";
            else
                Command = "SPDATAWL" + int2str(TraceNumber) + "\n";
            end
            fprintf(obj.Session,Command); 
            % Pause for the communication delay
            pause(3);   
            % Get X-axis power data from APEX OSA 
            while(obj.Session.BytesAvailable>0) 
                XData = fscanf(obj.Session,'%f');
            end
            Data =[flip(XData(2:end,1)) flip(YData(2:end,1))];
      end
      
      function SetNoiseMask(obj, NoiseMaskValue)  
%         Set the noise mask of the signal (values under this mask are set to this value)
%         Noise mask is expressed in the value of 'ScaleYUnit'
          Command = "SPSWPMSK" + num2str(NoiseMaskValue) + "\n";
          fprintf(obj.Session,Command);
          
          obj.NoiseMaskValue = NoiseMaskValue;
      end
      
      function SetScaleXUnit(obj, ScaleXUnit)
%          '''
%         Defines the unit of the X-Axis
%         ScaleXUnit can be a string or an integer
%         If ScaleXUnit is :
%             - "GHz" or 0, X-Axis unit is in GHz (default)
%             - "nm" or 1, X-Axis unit is in nm
%         '''
            if ScaleXUnit == "nm"
                ScaleXUnit = 1;
            else
                ScaleXUnit = 0;
            end
            Command = "SPXUNT" + num2str(ScaleXUnit) + "\n";
            fprintf(obj.Session,Command);
            
            obj.ScaleXUnit = ScaleXUnit;
      end
      
      function SetScaleYUnit(obj, ScaleYUnit)
%       '''
%         Defines the unit of the Y-Axis
%         ScaleXUnit can be a string or an integer
%         If ScaleYUnit is :
%             - "lin" or 0, Y-Axis unit is in mW (default)
%             - "log" or 1, Y-Axis unit is in dBm or dBm
%         '''
            if ScaleYUnit == "log"
                ScaleYUnit = 1;
            else
                ScaleYUnit = 0;
            end
            Command = "SPLINSC" + int2str(ScaleYUnit) + "\n";
            fprintf(obj.Session,Command);
            
            obj.ScaleYUnit = ScaleYUnit; 
      end
      
      function SetPolarizationMode(obj, PolarizationMode)
%           '''
%         Defines the measured polarization channels
%         PolarizationMode can be a string or an integer
%         If PolarizationMode is :
%             - "1+2" or 0, the total power is measured (default)
%             - "1&2" or 1, one measure is done for each polarization channel
%             - "1" or 2, just the polarization channel 1 is measured
%             - "2" or 3, just the polarization channel 2 is measured
%         '''
            if PolarizationMode == "1&2"
                PolarizationMode = 1;
            elseif PolarizationMode.lower() == "1"
                PolarizationMode = 2;
            elseif PolarizationMode.lower() == "2"
                PolarizationMode = 3;
            else
                PolarizationMode = 0;
            end
            Command = "SPPOLAR" + str(PolarizationMode) + "\n"; 
            fprintf(obj.Session,Command);
            
            obj.PolarizationMode = PolarizationMode; 
      end
      
      function PolarizationMode = GetPolarizationMode(obj)
%         '''
%         Gets the measured polarization channels
%         The returned polarization mode can is a string which can be
%             - "1+2" : the total power is measured (default)
%             - "1&2" : one measure is done for each polarization channel
%             - "1" : just the polarization channel 1 is measured
%             - "2" : just the polarization channel 2 is measured
%         '''
        if obj.PolarizationMode == 0
            PolarizationMode = "1+2";
        elseif obj.PolarizationMode == 1
            PolarizationMode = "1&2";
        elseif obj.PolarizationMode == 2
            PolarizationMode = "1";
        elseif obj.PolarizationMode == 3
            PolarizationMode = "2";
        end
        
      end
      
      function WavelengthCalib(obj)
%        '''
%         Performs a wavelength calibration.
%         If a measurement is running, it is previously stopped
%         '''
            Command = "SPWLCALM\n";
            fprintf(obj.Session,Command); 
      end
      
      function DeleteAll(obj)
%         '''
%         Clear all traces
%         '''
          Command = "SPTRDELAL\n";
          fprintf(obj.Session,Command); 
      end
      
      function ActivateAutoNPoints(obj)
%       '''
%         Activates the automatic number of points for measurements
%         '''
            Command = "SPAUTONBPT1\n";
            fprintf(obj.Session,Command); 
      end
      
      function DeactivateAutoNPoints(obj)
%         '''
%         Deactivates the automatic number of points for measurements
%         ''' 
            Command = "SPAUTONBPT0\n";
            fprintf(obj.Session,Command); 
      end
      
%       function FindPeak(self, TraceNumber=1, ThresholdValue=20.0, Axis='X', Find="max"):
% %         '''
% %         Find the peaks in the selected trace
% %         TraceNumber is an integer between 1 (default) and 6
% %         ThresholdValue is a float expressed in dB
% %         Axis is a string or an integer for selecting the axis:
% %             Axis = 0 or 'X' : get the X-axis values of the markers (default)
% %             Axis = 1 or 'Y' : get the Y-axis values of the markers
% %             Axis = 2 or 'XY': get the X-axis and Y-axis values of the markers
% %         Find is a string between the following values:
% %             - Find = "MAX" : only the max peak is returned (default)
% %             - Find = "MIN" : only the min peak is returned
% %             - Find = "ALL" : all peaks are returned in a list
% %             - Find = "MEAN" : a mean value of all peaks is returned
% %         '''
%       end

        function ActivateAverageMode(obj)
%         '''
%         Activates the average mode
%         '''
            Command = "SPAVERAGE1\n"; 
            fprintf(obj.Session,Command); 
        end
        
        function DeactivateAverageMode(obj)
%         '''
%         Deactivates the average mode
%         '''
          Command = "SPAVERAGE0\n";
          fprintf(obj.Session,Command); 
        end
        
%         function AutoMeasure(self, TraceNumber=1, NbAverage=1):
% %         '''
% %         Auto measurement which performs a single and looks for the maximum peak
% %         If a peak is detected, this method selects the spectral range and modify the span
% %         TraceNumber is an integer between 1 (default) and 6
% %         NbAverage is the number of average to perform after the span selection (no average by default)
% %         '''
%         end

        function AddMarker(obj, Position, TraceNumber)
%             '''
%             Add a marker
%             TraceNumber is an integer between 1 (default) and 6
%             Position is the X-axis position of the marker expressed in the value of 'ScaleXUnit'
%             '''
              Command = "SPMKRAD" + num2str(TraceNumber) + "_" + num2str(Position) + "\n";
              fprintf(obj.Session,Command);
        end
        
%         function GetMarkers(self, TraceNumber=1, Axis='y'):
% %         '''
% %         Gets the X-axis or Y-axis markers of a selected trace
% %         TraceNumber is an integer between 1 (default) and 6
% %         Axis is a string or an integer for selecting the axis:
% %             Axis = 0 or 'X' : get the X-axis values of the markers
% %             Axis = 1 or 'Y' : get the Y-axis values of the markers (default)
% %             Axis = 2 or 'XY': get the X-axis and Y-axis values of the markers
% %         '''
%         end

        function DelAllMarkers(obj, TraceNumber)
%             '''
%             Deletes all markers of a selected trace
%             TraceNumber is an integer between 1 (default) and 6
%             '''
            Command = "SPMKRDELAL" + num2str(TraceNumber) + "\n";
            fprintf(obj.Session,Command);
        end
        
%         function LineWidth(self, TraceNumber=1, Get="width"):
% %         '''
% %         Gets the 3-db line width of the selected trace
% %         TraceNumber is an integer between 1 (default) and 6
% %         ThresholdValue is a float expressed in dB
% %         Get is a string between the following values:
% %             - Get = "WIDTH" : only the line width is returned (default)
% %             - Get = "CENTER" : only the line width center is returned
% %             - Get = "LEVEL" : only the line width peak level is returned
% %             - Get = "ALL" : all line width values are returned in a list
% %         ''' 
%         end


        function  SaveToFile(obj, FileName, TraceNumber, Type)
%         '''
%         Save a trace on local hard disk
%         FileName is a string representing the path of the file to save
%         TraceNumber is an integer between 1 (default) and 6
%         Type is the type of the file to save
%         Type is a string between the following values:
%             - Type = "DAT" or 1 : data are saved in a binary format (default)
%             - Type = "TXT" or 0: data are saved in a text format
%         '''
        if (Type==0)
            Command = "SPSAVEB" + num2str(TraceNumber) + "_" + FileName + "\n";
        else
            Command = "SPSAVEA" + num2str(TraceNumber) + "_" + FileName + "\n";
        end
        fprintf(obj.Session,Command);
                
        end
        
        function LockTrace(obj, TraceNumber, Lock)
%         '''
%         Lock or unlock a trace
%         TraceNumber is an integer between 1 and 6
%         Lock is a boolean:
%             - True: the trace TraceNumber is locked
%             - False: the trace TraceNumber is unlocked
%         '''
            if (Lock==True)
                Command = "SPTRLOCK" + num2str(TraceNumber) + "\n";
            else
                Command = "SPTRUNLOCK" + num2str(TraceNumber) + "\n";
            end

            fprintf(obj.Session,Command); 
        end
        
        function SetScrollMode(obj, Enable)
%         '''
%         Enable or disable the screll mode
%         Enable is a boolean:
%             - (1)True: the scroll mode is enabled
%             - (0)False: the scroll mode is disabled
%         '''
            Command = "SPTRSCROLL" + num2str(Enable) + "\n";
            fprintf(obj.Session,Command); 
            
        end
        
      %  methods (Static)
      %  end
   end
end