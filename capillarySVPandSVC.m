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
% figure; imshow(meanDensSVC);

filtDensSVC = medfilt2(meanDensSVC);
% figure; imshow(filtDensSVC);

T= graythresh(filtDensSVC);
bwDensSVC = imbinarize(filtDensSVC,T);
% figure; imshow(bwDensSVC);

conV1 = bwareaopen(bwDensSVC,200);
% imshow(conV1);

% figure;imshow(DensSVCM);

maskedSVC = DensSVCM;
maskedSVC(conV1) =0;
figure;imshow(maskedSVC);

maskedSVP = DensSVPM;
maskedSVP(conV1)=0;
figure;imshow(maskedSVP);

imshow(DensSVCM - maskedSVC);







