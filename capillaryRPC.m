BWMajorVesselsONH = imbinarize(BScanImagesOCTA,0.95);

VolNewRPC = zeros(size(BWMajorVesselsONH)); % For angio data

% Designate the appropriate pixels in the angio or segmentation data for
% the ILM to bottom of IPL - the superficial vascular complex (SVC)
for idx = 1:1:(size(BWMajorVesselsONH, 3))
    for gdx = 1:1:(size(BWMajorVesselsONH, 2))
        if ~isnan(RasterRNFL(idx,gdx))
            VolNewRPC(round(RasterILM(idx,gdx)):round(RasterRNFL(idx,gdx)),gdx,idx) = BWMajorVesselsONH(round(RasterILM(idx,gdx)):round(RasterRNFL(idx,gdx)),gdx,idx);
        end
    end      
end

% Gives us a greyscale map instead of a maximum intensity projection map.
squeezedRPC = flipud(squeeze(mean(VolNewRPC, 1))');
meanDensRPC = imadjust(squeezedRPC);
figure; imshow(meanDensRPC);

J2= imbilatfilt(meanDensRPC,1,5);
figure;imshow(J2);

T= graythresh(meanDensRPC);
bwDensRPC = imbinarize(meanDensRPC,T);
figure; imshow(bwDensRPC);

% T= adaptthresh(meanDensRPC,1);
% bwDensRPC = imbinarize(meanDensRPC,T);
% figure; imshow(bwDensRPC);

subRPC = imsubtract(imcomplement(meanDensRPC),DensRPCO);
maximum = imsubtract(meanDensRPC,subRPC);
figure; imshow(subRPC);

se = strel('disk',1);
closeDensRPC = imclose(subRPC,se);
figure;imshow(closeDensRPC)

filtDensRPC = medfilt2(closeDensRPC);
figure; imshow(filtDensRPC);

compDensRPC = imcomplement(filtDensRPC);
figure; imshow(compDensRPC);

binDensRPC = imbinarize (compDensRPC,'adaptive');
figure;imshow(binDensRPC)

options = struct('FrangiScaleRange',[5 13],'FrangiScaleRatio',1,'FrangiBetaOne',...
0.5,'FrangiBetaTwo',0.5, 'FrangiC',500,'verbose',true,'BlackWhite',false);

V = FrangiFilter2D(J2,options);
imshow(V,[])

T= adaptthresh(V,1);
% bwDensRPC = imbinarize(meanDensRPC,T);
% figure; imshow(bwDensRPC);
V1 = imbinarize(V,T);
figure;imshow(V1);

se = strel('disk',3);
closeV = imclose(V,se);
figure;imshow(closeV)

compV = imcomplement(V);
imshow(compV);


BW = edge(compDensRPC,'canny');
imshow(BW);

se = strel('disk',12);
closeDensRPC = imclose(V,se);
imshow(closeDensRPC)