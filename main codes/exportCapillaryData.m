%This code is written to export the data of .mat file obtained from
%OCTAAnalysis.m into an excel file 'AllMonkData.xlsx'.
%Pratik Chettry on 01/12/2021.
clear all
close all
clc
warning on

%Make sure you have created an excel file.
XLSFile = 'E:\RepeatExperiments\CapillaryData.xlsx';%Change the paths accordingly or use uigetfile.

DataTitle = {'MonkSubj', 'ExperimentNumber','Eye','','APixelScale','TPixelScale'...
            ,'DensitySVConly','DensitySVPonly','DensityRPConly','VesselFractionSVConly'...
            ,'VesselFractionSVPonly','VesselFractionRPConly','VesselVolSVConly','VesselVolSVPonly'...
            ,'VesselVolRPConly'};

xlswrite(XLSFile, DataTitle, 'Sheet1','A1');
MonkPath = 'E:\RepeatExperiments';%Change the paths accordingly or use uigetfile.

%Get the directory with the name of subjects.
MonkDir = dir (fullfile(MonkPath));
MonkDir(~[MonkDir.isdir]) = [];%Only choose the folders and not the files.
for idx = 1:length(MonkDir)%Loop to choose each subject.
    
    MonkSubj = MonkDir(idx).name;
    
    if MonkSubj(1) == '.'
        continue
    end
    ScanDates = dir (fullfile([MonkPath '\' MonkSubj]));%Folders named according to dates.
    ScanDates(~[ScanDates.isdir]) = [];%Make sure that a folder is selected.
    
    for sdx = 1: length(ScanDates)%Loop for each date of OCT.
        ExperimentNumber = ScanDates(sdx).name;
        if ExperimentNumber(1) == '.'
            continue
        end
        %------------------------------------------------------------------
        %For OD
        EyePath = [MonkPath '\' MonkSubj '\' ExperimentNumber '\OD\'];
        DataFile = fullfile(EyePath, 'CapillaryData.mat');
        
        
        try
            %Only get the specific variables that you need from the mat
            %file.
            load (DataFile,'TPixelScale','APixelScale'...
            ,'DensitySVConly','DensitySVPonly','DensityRPConly','VesselFractionSVConly'...
            ,'VesselFractionSVPonly','VesselFractionRPConlyl','VesselVolSVConly','VesselVolSVPonly'...
            ,'VesselVolRPConly');%Need to correct VesselFractionRPConlyl
            
            SUBCOUNT = xlsread(XLSFile, 'sub', 'A1'); %Set at 2 in the beginning
            
            DATA =  {MonkSubj, ExperimentNumber,'OD','',APixelScale,TPixelScale...
            ,DensitySVConly,DensitySVPonly,DensityRPConly,VesselFractionSVConly...
            ,VesselFractionSVPonly,VesselFractionRPConlyl,VesselVolSVConly,VesselVolSVPonly...
            ,VesselVolRPConly};
                    
            xlswrite(XLSFile, DATA, 'Sheet1', ['A' num2str(SUBCOUNT)]);
            
            xlswrite(XLSFile, {num2str(SUBCOUNT+1)}, 'sub', 'A1');
            clear('DATA');
            
        catch
            disp(EyePath)
        end
        
        
        %%%----------------------------------------------------------------
        %For OS
        EyePath = [MonkPath '\' MonkSubj '\' ExperimentNumber '\OS\'];
        DataFile = fullfile(EyePath, 'CapillaryData.mat');
        
        try
            %Only get the specific variables that you need from the mat
            %file.
            load (DataFile,'TPixelScale','APixelScale'...
            ,'DensitySVConly','DensitySVPonly','DensityRPConly','VesselFractionSVConly'...
            ,'VesselFractionSVPonly','VesselFractionRPConlyl','VesselVolSVConly','VesselVolSVPonly'...
            ,'VesselVolRPConly');
        
            
            SUBCOUNT = xlsread(XLSFile, 'sub', 'A1');
            DATA =  {MonkSubj, ExperimentNumber,'OS','',APixelScale,TPixelScale...
            ,DensitySVConly,DensitySVPonly,DensityRPConly,VesselFractionSVConly...
            ,VesselFractionSVPonly,VesselFractionRPConlyl,VesselVolSVConly,VesselVolSVPonly...
            ,VesselVolRPConly};
            
            xlswrite(XLSFile, DATA, 'Sheet1', ['A' num2str(SUBCOUNT)]);
            
            xlswrite(XLSFile, {num2str(SUBCOUNT+1)}, 'sub', 'A1');
            
        catch
            disp(EyePath)
        end
        
    end
end
xlswrite(XLSFile, {num2str(2)}, 'sub', 'A1');
