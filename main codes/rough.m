clear all
close all
clc
warning on

PD = 'E:\RepeatExperiments';
Animals = dir(fullfile(PD));
% DataFile = fullfile(PD,'LargeVesselCaliberData.xlsx');

for animals =3%:length(Animals)
    
    Subject = Animals(animals).name;
    if Subject(1) == '.'
        continue
    end
    if Subject(1) == '$'
        continue
    end
    
    Date = dir(fullfile(PD,Subject));
    for D = 4%:length(Date)
        DDir = Date(D).name;
        
        if DDir(1) == '.'
            continue
        end
        if Date(D).isdir == 0
            continue
        end
        
        
        % Left eye
        try
            load([PD '\' Subject '\' DDir '\OS\AllData.mat'],'BScanImagesMACOCTA','BScanImagesOCTA',...
                'RasterILMMAC','RasterIPLMAC','RasterRNFLMAC','RasterILM','RasterRNFL',...
                'CircularMask','ONHVascularMask','DensSVCM','DensSVPM','DensRPCO',...
                'TPixelScale','APixelScale','BWONH','BWMac');
            
            Eye = 'OS';
            % ONH = 1, Macula = 2;
            CapData = [PD '\' Subject '\' '1\' Eye '\CapillaryData.mat'];
            if exist(CapData)== 0
                Region = 1;
                if Region == 1
                    
                    maskedRPC = DensRPCO.*ONHVascularMask;
                    [ONHBW] = imSegment(maskedRPC);
                    
                    % maskedImageMac = maskedImage;
                    maskedRPC(ONHBW) = 0;
                    
                    MVMaskONH = (DensRPCO.*ONHVascularMask)-(maskedRPC);
                    figure;subplot(1,2,1);imshow(maskedRPC);subplot(1,2,2); imshow(MVMaskONH);
                    
                    Region = 2;
                elseif Region == 2
                    BWMajorVesselsMAC = imbinarize(BScanImagesMACOCTA,0.95);
                    VolNewSVC = zeros(size(BWMajorVesselsMAC)); % For angio data
                    % Designate the appropriate pixels in the angio or segmentation data for
                    % the ILM to bottom of IPL - the superficial vascular complex (SVC)
                    for idx = 1:size(BWMajorVesselsMAC, 3)
                        for gdx = 1:size(BWMajorVesselsMAC, 2)
                            VolNewSVC(round(RasterILMMAC(idx,gdx)):round(RasterIPLMAC(idx...
                                ,gdx)),gdx,idx) = BWMajorVesselsMAC(round(RasterILMMAC(idx,gdx)):round(RasterIPLMAC(idx,gdx)),gdx,idx);
                        end
                    end
                    
                    % Gives us a mean intensity projection map(grayscale) instead of a maximum
                    % intensity projection map.
                    squeezedSVC = flipud(squeeze(mean(VolNewSVC, 1))');
                    meanDensSVC = imadjust(squeezedSVC);
                    %Filter the image with a median filter
                    filtDensSVC = medfilt2(meanDensSVC);
                    %Threshold the image
                    T= graythresh(filtDensSVC);
                    bwDensSVC = imbinarize(filtDensSVC,T);
                    %Open the image (erosion followed by dilation);
                    %Get the major vessel mask
                    MVmaskMac = bwareaopen(bwDensSVC,200);
                    
                    % Use mask to get only capillaries
                    maskedSVC = DensSVCM.*CircularMask;
                    maskedSVC(MVmaskMac) =0;
                    figure;
                    subplot(1,2,1);imshow(DensSVCM);
                    subplot(1,2,2); imshow(MVmaskMac);
                    
                    counter = 1;
                    while counter <2
                        Sure = questdlg('Would you like to use this mask?', 'Mask', 'Yes', 'No', 'No');
                        switch Sure
                            case 'No'
                                Same = questdlg('Would you like to correct previous mask?', 'Use old mask', 'Yes', 'No', 'No');
                                switch Same
                                    case 'Yes'
                                        [MacBW] = imSegment(maskedSVC);
                                        
                                        %                         maskedImageMac = maskedImage;
                                        maskedSVC(MacBW) = 0;
                                    case 'No'
                                        maskedSVC = DensSVCM.*CircularMask;
                                        [MacBW] = imSegment(maskedSVC);
                                        
                                        %                         maskedImageMac = maskedImage;
                                        maskedSVC(MacBW) = 0;
                                end
                                counter = counter+1;
                            case 'Yes'
                                counter = counter +1;
                        end
                    end
                    
                    MVMaskMac = (DensSVCM.*CircularMask)-(maskedSVC);
                    figure;subplot(1,2,1);imshow(MVMaskMac);subplot(1,2,2); imshow(MVMaskMac);
                    
                    
                    
                end
            else
                
                CapData = [PD '\' Subject '\' '1\' Eye '\CapillaryData.mat'];
                load(CapData,'MVMaskONH','MVMaskMac');
                
                Region = 1;
                if Region ==1
                    
                    % Use mask to get only capillaries
                    maskedRPC = DensRPCO.*ONHVascularMask;
                    maskedRPC(MVMaskONH)=0;
                    if isa(MVMaskONH,'double')
                        MVMaskONH = imbinarize(MVMaskONH,0.5);
                    end
                    figure;subplot(1,2,1);imshow(DensRPCO.*ONHVascularMask);subplot(1,2,2); imshow(maskedRPC);
                    
                    counter = 1;
                    while counter <2
                        Sure = questdlg('Would you like to use the mask?', 'Mask', 'Yes', 'No', 'No');
                        switch Sure
                            case 'Yes'
                                counter = counter+1;
                            case 'No'
                                [ONHBW] = imSegment(maskedRPC);
                                
                                % maskedImageMac = maskedImage;
                                maskedRPC(ONHBW) = 0;
                                
                                counter = counter +1;
                        end
                    end
                    MVMaskONH = (DensRPCO.*ONHVascularMask)-(maskedRPC);
                    figure;subplot(1,2,1);imshow(maskedRPC);subplot(1,2,2); imshow(MVMaskONH);
                    
                    
                else Region = 'Mac';
                    % ONH = 1, Macula = 2;
                    if Region == 2
                        maskedSVC = DensSVCM.*CircularMask;
                        if isa(MVMaskONH,'double')
                            MVMaskMac = imbinarize(MVMaskMac,0.5);
                        end
                        maskedSVC(MVMaskMac)=0;
                        figure;subplot(1,2,1);imshow(DensSVCM.*CircularMask);subplot(1,2,2); imshow(maskedSVC);
                        
                        counter = 1;
                        while counter <2
                            Sure = questdlg('Would you like to use the mask?', 'Mask', 'Yes', 'No', 'No');
                            switch Sure
                                case 'Yes'
                                    counter = counter+1;
                                case 'No'
                                    BWMajorVesselsMAC = imbinarize(BScanImagesMACOCTA,0.95);
                                    
                                    VolNewSVC = zeros(size(BWMajorVesselsMAC)); % For angio data
                                    
                                    % Designate the appropriate pixels in the angio or segmentation data for
                                    % the ILM to bottom of IPL - the superficial vascular complex (SVC)
                                    for idx = 1:size(BWMajorVesselsMAC, 3)
                                        for gdx = 1:size(BWMajorVesselsMAC, 2)
                                            VolNewSVC(round(RasterILMMAC(idx,gdx)):round(RasterIPLMAC(idx...
                                                ,gdx)),gdx,idx) = BWMajorVesselsMAC(round(RasterILMMAC(idx,gdx)):round(RasterIPLMAC(idx,gdx)),gdx,idx);
                                        end
                                    end
                                    
                                    % Gives us a mean intensity projection map(grayscale) instead of a maximum
                                    % intensity projection map.
                                    squeezedSVC = flipud(squeeze(mean(VolNewSVC, 1))');
                                    meanDensSVC = imadjust(squeezedSVC);
                                    %Filter the image with a median filter
                                    filtDensSVC = medfilt2(meanDensSVC);
                                    %Threshold the image
                                    T= graythresh(filtDensSVC);
                                    bwDensSVC = imbinarize(filtDensSVC,T);
                                    %Open the image (erosion followed by dilation);
                                    %Get the major vessel mask
                                    MVmaskMac = bwareaopen(bwDensSVC,200);
                                    
                                    % Use mask to get only capillaries
                                    maskedSVC = DensSVCM.*CircularMask;
                                    maskedSVC(MVmaskMac) =0;
                                    figure;
                                    subplot(1,2,1);imshow(DensSVCM);
                                    subplot(1,2,2); imshow(maskedSVC);
                                    
                                    counter = 1;
                                    while counter <2
                                        Sure = questdlg('Would you like to use this mask?', 'Mask', 'Yes', 'No', 'No');
                                        switch Sure
                                            case 'No'
                                                Same = questdlg('Would you like to correct over the mask?', 'Use old mask', 'Yes', 'No', 'No');
                                                switch Same
                                                    case 'Yes'
                                                        [MacBW] = imSegment(maskedSVC);
                                                        
                                                        %                         maskedImageMac = maskedImage;
                                                        maskedSVC(MacBW) = 0;
                                                    case 'No'
                                                        maskedSVC = DensSVCM.*CircularMask;
                                                        [MacBW] = imSegment(maskedSVC);
                                                        
                                                        %                         maskedImageMac = maskedImage;
                                                        maskedSVC(MacBW) = 0;
                                                end
                                                counter = counter+1;
                                            case 'Yes'
                                                counter = counter +1;
                                        end
                                        
                                    end
                                    
                            end
                        end
                        MVMaskMac = (DensSVCM.*CircularMask)-(maskedSVC);
                        figure;subplot(1,2,1);imshow(maskedSVC);subplot(1,2,2); imshow(MVMaskMac);
                        
                        
                    end
                end
            end
            
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
            %The same mask will work for SVP as well
            maskedSVP = DensSVPM.*CircularMask;
            maskedSVP(MacBW)=0;
            flippedMaskSVP = flipud(maskedSVP);
            imshow(maskedSVP);
            
            %                     figure;
            %                     subplot(1,2,1);imshow(Density2);
            %                     subplot(1,2,2); imshow(maskedSVC);
            for idx = 1:size(BWMac, 3);
                for gdx = 1:size(BWMac, 2);
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
            
            DensitySVConly = mean(DensSVCMonly(CircularMask));
            DensitySVPonly = mean(DensSVPMonly(CircularMask));
            DensityRPConly = mean(DensRPCO(ONHVascularMask), 'omitnan');
            
            VesselFractionSVConly = mean(NumStrSVCMonly(CircularMask)) / mean(NumStrSVCMonly(CircularMask));
            VesselFractionSVPonly = mean(NumVesSVPMonly(CircularMask)) / mean(NumStrSVPMonly(CircularMask));
            VesselFractionRPConlyl = mean(NumVesRPCOnly(ONHVascularMask)) / mean(NumStrRPCOnly(ONHVascularMask), 'omitnan');
            
            VoxelSize = TPixelScale*TPixelScale*APixelScale;
            VesselVolSVC.Global = sum(NumStrSVCMonly(CircularMask))*VoxelSize/1000000000;
            VesselVolSVP.Global = sum(NumVesSVPMonly(CircularMask))*VoxelSize/1000000000;
            VesselVolRPC.Gobal = sum(NumVesRPCOnly(ONHVascularMask), 'omitnan')*VoxelSize/1000000000; % convert to microL
            
            save([PD '\' Subject '\' DDir '\OS\CapillaryData.mat','-v7.3'])
            clear( 'BScanImagesMACOCTA','BScanImagesOCTA',...
                'RasterILMMAC','RasterIPLMAC','RasterRNFLMAC','RasterILM','RasterRNFL',...
                'CircularMask','ONHVascularMask','DensSVCM','DensSVPM','DensRPCO',...
                'TPixelScale','BMOEllipse','ScanHeader','ScanHeaderMAC','CenterX','CenterY')
        catch
            disp(['Error in ', Subject, char(39),'s ', DDir,' OS']);
            
        end
    end
end
disp('End of selection')

    