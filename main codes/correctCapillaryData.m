%This code is written to export the data of .mat file obtained from
%OCTAAnalysis.m into an excel file 'AllMonkData.xlsx'.
%Pratik Chettry on 11082019.
clear all
close all
clc
warning on

PD = 'E:\RepeatExperiments';
Animals = dir(fullfile(PD));
% DataFile = fullfile(PD,'LargeVesselCaliberData.xlsx');

for animals =1:length(Animals)
    close all
    Subject = Animals(animals).name;
    if Subject(1) == '.'
        continue
    end
    if Subject(1) == '$'
        continue
    end
    
    Date = dir(fullfile(PD,Subject));
    for D = 1:length(Date)
        DDir = Date(D).name;
        
        if DDir(1) == '.'
            continue
        end
        if Date(D).isdir == 0
            continue
        end
        
        
        % Left eye
        try
            Eye = 'OS';
            
            CapillaryData = [PD '\' Subject '\' DDir '\' Eye '\CapillaryData.mat'];
            
            %Check if the mat file exists
            if exist(CapillaryData, 'file') ~= 0
                
                %If exists load it.
                load(CapillaryData);
                
                %Make sure you use the correct mask this time around.
                MacCapillaryMask = CircularMask-MVMaskMac;
                MacCapillaryMask = imbinarize(MacCapillaryMask,0.5);
                
                ONHCapillaryMask = ONHVascularMask-MVMaskONH;
                ONHCapillaryMask = imbinarize(ONHCapillaryMask,0.5);
                
                %Calculate the necessary metrics.
                DensitySVConly = mean(DensSVCMonly(MacCapillaryMask));
                DensitySVPonly = mean(DensSVPMonly(MacCapillaryMask));
                DensityRPConly = mean(DensRPCO(ONHCapillaryMask), 'omitnan');
                
                VesselFractionSVConly = mean(NumVesSVCMonly(MacCapillaryMask)) / mean(NumStrSVCMonly(MacCapillaryMask));
                VesselFractionSVPonly = mean(NumVesSVPMonly(MacCapillaryMask)) / mean(NumStrSVPMonly(MacCapillaryMask));
                VesselFractionRPConly = mean(NumVesRPCOnly(ONHCapillaryMask)) / mean(NumStrRPCOnly(ONHCapillaryMask), 'omitnan');
                
                VoxelSize = TPixelScale*TPixelScale*APixelScale;
                VesselVolSVConly = sum(NumVesSVCMonly(MacCapillaryMask))*VoxelSize/1000000000;
                VesselVolSVPonly = sum(NumVesSVPMonly(MacCapillaryMask))*VoxelSize/1000000000;
                VesselVolRPConly = sum(NumVesRPCOnly(ONHCapillaryMask), 'omitnan')*VoxelSize/1000000000; % convert to microL
                
                %Save the mat file again for later retrieval.
                save([PD '\' Subject '\' DDir '\' Eye '\CapillaryData.mat'],'-v7.3')
                clear('DensitySVConly','DensitySVPonly','DensityRPConly','VesselFractionSVConly','VesselFractionSVPonly'...
                    ,'VesselFractionRPConly','VesselVolSVConly','VesselVolSVPonly','VesselVolRPConly');
            end
        catch
            display('Error in ', Subject, char(39),'s ', DDir,' OS');
        end
    end
end
