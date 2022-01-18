clear all
close all
clc


PD = 'E:\RepeatExperiments';
Animals = dir(fullfile(PD));
% DataFile = fullfile(PD,'LargeVesselCaliberData.xlsx');

animals =12;%1:length(Animals)
close all
Subject = Animals(animals).name;
%     if Subject(1) == '.'
%         continue
%     end
%     if Subject(1) == '$'
%         continue
%     end
%
Date = dir(fullfile(PD,Subject));
%     for
D = 13;%:length(Date)

DDir = Date(D).name;

%         if DDir(1) == '.'
%             continue
%         end
%         if Date(D).isdir == 0
%             continue
%         end
%

% Left eye

Eye = 'OS';

CapillaryData = [PD '\' Subject '\' 'DDir\' Eye '\CapillaryData.mat'];



load([PD '\' Subject '\' DDir '\OS\AllData.mat'],'BScanImagesMACOCTA','BScanImagesOCTA',...
    'RasterILMMAC','RasterIPLMAC','RasterRNFLMAC','RasterILM','RasterRNFL',...
    'CircularMask','ONHVascularMask','DensSVCM','DensSVPM','DensRPCO',...
    'TPixelScale','APixelScale','BWONH','BWMac');



%Take the masked image within the ellipse
maskedRPC = DensRPCO.*ONHVascularMask;
[ONHBW]=imSegment(maskedRPC);%use roi to make binary image of major vessels
maskedRPC(ONHBW) = 0;
MVMaskONH = (DensRPCO.*ONHVascularMask)-(maskedRPC);%MajorVessel mask
% figure;imshow(maskedRPC);

maskedSVC = DensSVCM.*CircularMask;
maskedSVP = DensSVPM.*CircularMask;
[MacBW]=imSegment(maskedSVC);
maskedSVC(MacBW) = 0;
maskedSVP(MacBW) = 0;
MVMaskMac = (DensSVCM.*CircularMask)-(maskedSVC);%MajorVessel mask
% figure;imshow(maskedSVC);imshow(MVMaskMac);

MacCapillaryMask = CircularMask-MVMaskMac;
MacCapillaryMask = imbinarize(MacCapillaryMask,0.5);

ONHCapillaryMask = ONHVascularMask-MVMaskONH;
ONHCapillaryMask = imbinarize(ONHCapillaryMask,0.5);

%%% After the loop,necessary OCTA metrics were calculated.
flippedMaskRPC = flipud(maskedRPC);
for idx = 1:1:(size(BWONH, 3))
    for gdx = 1:1:(size(BWONH, 2))
        if ~isnan(RasterRNFL(idx,gdx))
            if flippedMaskRPC(idx,gdx)==1
                NumStrRPConly(idx, gdx) = RasterRNFL(idx,gdx) - RasterILM(idx,gdx);
                VesselSignal = BWONH(round(RasterILM(idx,gdx)):round(RasterRNFL(idx,gdx)),gdx,idx);
                NumVesRPConly(idx, gdx) = sum(VesselSignal);
                if sum(BWONH(round(RasterILM(idx,gdx)):round(RasterRNFL(idx,gdx)),gdx,idx)) > 1;
                    DensRPConly(idx, gdx) = 1;
                end
            else
                NumStrRPConly(idx, gdx) = 0;
                NumVesRPConly(idx, gdx) = 0;
                if sum(BWONH(round(RasterILM(idx,gdx)):round(RasterRNFL(idx,gdx)),gdx,idx)) > 1;
                    DensRPConly(idx, gdx) = 0;
                end
            end
        end
    end
end

NumStrRPCOnly = flipud(NumStrRPConly); % ending O for ONH
NumVesRPCOnly = flipud(NumVesRPConly);
DensRPCOnly = flipud(DensRPConly);

flippedMaskSVC = flipud(maskedSVC);
for idx = 1:size(BWMac, 3)
    for gdx = 1:size(BWMac, 2)
        if flippedMaskSVC(idx,gdx)==1
            NumStrSVConly(idx, gdx) = RasterIPLMAC(idx,gdx) - RasterILMMAC(idx,gdx);
            VesselSignal = BWMac(round(RasterILMMAC(idx,gdx)):round(RasterIPLMAC(idx,gdx)),gdx,idx);
            NumVesSVConly(idx, gdx) = sum(VesselSignal);
            if sum(BWMac(round(RasterILMMAC(idx,gdx)):round(RasterIPLMAC(idx,gdx)),gdx,idx)) > 1;
                DensSVConly(idx, gdx) = 1;
            end
        else
            NumStrSVConly(idx, gdx) = 0;
            NumVesSVConly(idx, gdx) = 0;
            if sum(BWMac(round(RasterILMMAC(idx,gdx)):round(RasterIPLMAC(idx,gdx)),gdx,idx)) > 1;
                DensSVConly(idx, gdx) = 0;
            end
        end
    end
end

flippedMaskSVP = flipud(maskedSVP);
%                 imshow(maskedSVP);

%                     figure;
%                     subplot(1,2,1);imshow(Density2);
%                     subplot(1,2,2); imshow(maskedSVC);
for idx = 1:size(BWMac, 3)
    for gdx = 1:size(BWMac, 2)
        if flippedMaskSVP(idx,gdx)==1
            NumStrSVPonly(idx, gdx) = RasterIPLMAC(idx,gdx) - RasterRNFLMAC(idx,gdx);
            VesselSignal = BWMac(round(RasterRNFLMAC(idx,gdx)):round(RasterIPLMAC(idx,gdx)),gdx,idx);
            NumVesSVPonly(idx, gdx) = sum(VesselSignal);
            if sum(BWMac(round(RasterRNFLMAC(idx,gdx)):round(RasterIPLMAC(idx,gdx)),gdx,idx)) > 1;
                DensSVPonly(idx, gdx) = 1;
            end
        else
            NumStrSVPonly(idx, gdx) = 0;
            NumVesSVPonly(idx, gdx) = 0;
            if sum(BWMac(round(RasterRNFLMAC(idx,gdx)):round(RasterIPLMAC(idx,gdx)),gdx,idx)) > 1;
                DensSVPonly(idx, gdx) = 0;
            end
        end
    end
end

NumStrSVCMonly = flipud(NumStrSVConly);
NumVesSVCMonly = flipud(NumVesSVConly);
DensSVCMonly = flipud(DensSVConly);
NumStrSVPMonly = flipud(NumStrSVPonly);
NumVesSVPMonly = flipud(NumVesSVPonly);
DensSVPMonly = flipud(DensSVPonly);

DensitySVConly = mean(DensSVCMonly(MacCapillaryMask));
DensitySVPonly = mean(DensSVPMonly(MacCapillaryMask));
DensityRPConly = mean(DensRPCO(ONHCapillaryMask), 'omitnan');

VesselFractionSVConly = mean(NumVesSVCMonly(MacCapillaryMask)) / mean(NumStrSVCMonly(MacCapillaryMask));
VesselFractionSVPonly = mean(NumVesSVPMonly(MacCapillaryMask)) / mean(NumStrSVPMonly(MacCapillaryMask));
VesselFractionRPConlyl = mean(NumVesRPCOnly(ONHCapillaryMask)) / mean(NumStrRPCOnly(ONHCapillaryMask), 'omitnan');

VoxelSize = TPixelScale*TPixelScale*APixelScale;
VesselVolSVConly = sum(NumStrSVCMonly(MacCapillaryMask))*VoxelSize/1000000000;
VesselVolSVPonly = sum(NumVesSVPMonly(MacCapillaryMask))*VoxelSize/1000000000;
VesselVolRPConly = sum(NumVesRPCOnly(ONHCapillaryMask), 'omitnan')*VoxelSize/1000000000; % convert to microL

save([PD '\' Subject '\' DDir '\OS\CapillaryData.mat'],'-v7.3')
clear( 'BScanImagesMACOCTA','BScanImagesOCTA',...
    'RasterILMMAC','RasterIPLMAC','RasterRNFLMAC','RasterILM','RasterRNFL',...
    'CircularMask','ONHVascularMask','DensSVCM','DensSVPM','DensRPCO',...
    'TPixelScale','BMOEllipse','ScanHeader','ScanHeaderMAC','CenterX','CenterY')

disp('Saving ended.')

function [BW] = imSegment(input_image)
[rows, columns] = size(input_image);
BW = false(rows, columns);

F = figure;
F.WindowState = 'maximized';
imshow(input_image);
i = 1;
while i<100
    Continue = questdlg('Would you like to remove more vessels?', 'Remove', 'Yes', 'No','Yes');
    switch Continue
        case 'Yes'
            roi = drawfreehand;
            roi.Closed = true;
            roi.LineWidth = 1;
            
            Delete = questdlg('Would you like to remove the last ROI?','Remove','Yes', 'No', 'No');
            switch Delete
                case 'Yes'
                    delete(roi);
                case 'No'
                    mask = createMask(roi);
                    BW = BW | mask;
            end
            %             imshow(cumulativeBinaryImage)
        case 'No'
            i = 100;
            close(F);
    end
end
end

