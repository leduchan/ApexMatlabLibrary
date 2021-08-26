# MatlabApex
Installation 
  1. Download the package MatlabApex 
  2. Unzip it and move it in the directory of your Matalb project
# Using 
Most of the commonly used operations are provided by the attached MATALB
class OSA_VISA.This class is open for source further extensions.
Most commonly used OSA_VISA CLASS methods and properties
OSA_VISA() constructor that opens the connection to the instrument
APEX_OSA = OSA_VISA( '192.168.1.52',5900);
Close() closes the connection to the instrument
ID_osa = GetID(APEX_OSA); get ID of APEX OSA device
APEX_OSA.SetSpan(0.5); set span of measurements
Span = APEX_OSA.GetSpan() ; get span of measurements
StartWavelength=APEX_OSA.GetStartWavelength; get start wavelength
APEX_OSA.Run(1); running single sweep for measurements.
OSA_VISA_updated CLASS
More properties are added into the CLASS OSA_VISA_updated in order to directly get
access the properties of OSA.
APEX_OSA.Span ; get span of measurements
APEX_OSA.StartWavelength ; get start wavelength
