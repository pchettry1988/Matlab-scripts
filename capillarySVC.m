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

% Gives us a greyscale map instead of a maximum intensity projection map.
squeezedSVC = flipud(squeeze(mean(VolNewSVC, 1))');
meanDensSVC = imadjust(squeezedSVC);
% figure; imshow(meanDensSVC);

filtDensSVC = medfilt2(meanDensSVC);
figure; imshow(filtDensSVC);

T= graythresh(filtDensSVC);
bwDensSVC = imbinarize(filtDensSVC,T);
figure; imshow(bwDensSVC);

conV1 = bwareaopen(bwDensSVC,200);
imshow(conV1);

figure;imshow(DensSVCM);


maskedSVC = DensSVCM;
maskedSVC(conV1) =0;

imshow(maskedSVC);

maskedSVP = DensSVPM;
maskedSVP(conV1)=0;
imshow(maskedSVP);


% circularDensSVC = DensSVCM.*CircularMask;
% figure; imshow(circularDensSVC);
% 
% H = imbilatfilt(circularDensSVC,0.5,5); 
% figure;imshow(H);
% % 
% % filtDensSVC = medfilt2(H);
% % figure; imshow(filtDensSVC);
% T= graythresh(H);
% bwDensSVC = imbinarize(H,T);
% figure; imshow(bwDensSVC);
% 
% erodedDensSVC = imerode(bwDensSVC,strel('disk',2));
% figure; imshow(erodedDensSVC);


%% Use low-pass filter to remove capillary and get intact major blood vessels
lpDensSVC = lowpassfilter(filtDensSVC,30);
imshow(lpDensSVC);

%%
T= graythresh(g);
bwDensSVC = imbinarize(g,T);
figure; imshow(bwDensSVC);

%% Matched filter for vessel segmentation
out=matchedfilter(meanDensSVC,10,20);
figure;imshow(out);


out = matchedfilter(filtDensSVC,5,20);
figure; imshow(out)

  %%
% H = imbilatfilt(meanDensSVC,0.5,5);
% figure;imshow(H);

% imgNormalized = (g-min(min(g)))./(max(max(g))-min(min(g)));
% figure; imshow(imgNormalized);

se = strel('square',4);
avg_im = imfilter(g,filt_avg);
figure; imshow(avg_im);



maximum = imsubtract(meanDensSVC,g);
subSVC = imresize(subSVC,[size(DensSVCM,1) size(DensSVCM,2)]);
figure; imshow(maskedSVC);

se = strel('disk',1);
closeDensSVC = imclose(subSVC,se);
figure;imshow(closeDensSVC)

filtDensSVC = medfilt2(closeDensSVC);
figure; imshow(filtDensSVC);

compDensSVC = imcomplement(filtDensSVC);
figure; imshow(compDensSVC);

binDensSVC = imbinarize (compDensSVC,'adaptive');
figure;imshow(binDensSVC)

options = struct('FrangiScaleRange',[0.5 10],'FrangiScaleRatio',0.5,'FrangiBetaOne',...
0.5,'FrangiBetaTwo',0.5, 'FrangiC',500,'verbose',true,'BlackWhite',true);

V = FrangiFilter2D(g,options);
figure;imshow(V)

T = adaptthresh (V);
V1 = imbinarize(V,T);
figure;imshow(V1)

conV1 = bwareaopen(V1,200);
imshow(conV1);

se = strel('square',1);
openDensSVC = imopen(conV1,se);
figure;imshow(openDensSVC)



im = (DensSVCM (DensSVCM == openDensSVC);
figure; imshow(im);
se = strel('square',1);
clopenDensSVC = imclose(openDensSVC,se);
figure;imshow(clopenDensSVC)

BW = edge(compDensSVC,'canny');
imshow(BW);

se = strel('disk',12);
closeDensSVC = imclose(V,se);
imshow(closeDensSVC)


T= adaptthresh(filtDensSVC,0.3);
bwDensSVC = imbinarize(filtDensSVC,T);
figure; imshow(bwDensSVC);

figure; imshow(meanDensSVC);

bwDensSVC = bwareaopen(bwDensSVC, 150);
figure; imshow(bwDensSVC);

subDensSVC = DensSVCM - bwDensSVC;
figure;imshow(subDensSVC);


V = vesselness2D(bwDensSVC, 0.5, [1;1], 1, false);
figure; imshow(V)





