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

filtDensRPC = medfilt2(meanDensRPC);
figure; imshow(filtDensRPC);

gaussDensRPC = imgaussfilt(filtDensRPC);
figure;imshow(gaussDensRPC)

maskedRPC = DensRPCO.*ONHVascularMask;
figure; imshow(maskedRPC)

jpt = (DensRPCO -gaussDensRPC);
bin = imbinarize(jpt,0.6);
imshow(bin)


% gaussDensRPC = imgaussfilt(filtDensRPC,2);
% figure; imshow(gaussDensRPC);
% 
% binary = gaussDensRPC <0.1;
% figure; imshow(binary)

T = adaptthresh(filtDensRPC);
binDensRPC = imbinarize(filtDensRPC,T);
figure; imshow(binDensRPC);

figure; imshow(DensRPCO);

%% Important K-means clustering
% % But did not work in time:
% maskedRPC=meanDensRPC.*ONHVascularMask;
% I = uint8(maskedRPC);
% [L,Centers] = imsegkmeans(I,2);
% B = labeloverlay(I,L);
% figure;imshow(B)
% 
% Y=rescale(L);
% Y = imbinarize(Y,0.1);
% figure;imshow(Y);
% title('Labeled Image')
% 
% 
% G = imclose(Y,strel('square',4));
% imshow(G);
% 
% open = bwareaopen(G,40);
% imshow(open);
% 
% 
% cb = imclearborder(DensRPCO);
% figure;imshow(cb);
% 
% % eroded = imerode(binDensRPC,ones(4));
% % figure; imshow(eroded);
% 
% close = imopen(cb,strel('square',2));
% figure;imshow(close);
% 
% biglines = bwareaopen(open,200);
% figure; imshow(biglines);
% 
% capillaries = cb-biglines;
% figure;imshow(capillaries);
% figure; imshow(DensRPCO-capillaries);
% 
% maskedRPC = DensRPCO.*ONHVascularMask;
% figure; imshow(maskedRPC)
% 
% comp = imcomplement(gaussDensRPC);
% figure; imshow(comp);
% 
% 
% %% Use low-pass filter to remove capillary and get intact major blood vessels
% lpDensRPC = lowpassfilter(maskedRPC,70);
% figure;imshow(lpDensRPC);
% 
% %%
% T= otsuthresh(maskedRPC);
% bwDensRPC = imbinarize(maskedRPC,T);
% % figure; imshow(bwDensRPC);
% 
% conV1 = bwareaopen(bwDensRPC,200);
% % imshow(conV1);
% 
% % figure;imshow(DensSVCM);
% 
% maskedSVC = DensSVCM;
% maskedSVC(conV1) =0;
% figure;imshow(maskedSVC);
% 
% maskedSVP = DensSVPM;
% maskedSVP(conV1)=0;
% figure;imshow(maskedSVP);
% 
% 
% 
% 
%% Frangi-filter
% options = struct('FrangiScaleRange',[4 10],'FrangiScaleRatio',1,'FrangiBetaOne',...
% 0.5,'FrangiBetaTwo',0.25, 'FrangiC',50,'verbose',true,'BlackWhite',false);
% 
% V = FrangiFilter2D(maskedRPC,options);
% imshow(V,[])
% 
% %%
% lpDensRPC = lowpassfilter(V,40);
% figure;imshow(lpDensRPC);
% 
% T= graythresh(lpDensRPC);
% bw = imbinarize(lpDensRPC,T);
% figure; imshow(bw);
% 
% closebw = imclose(bw,strel('disk',2));
% figure;imshow(closebw)
% 
% 
%% Matched filter for vessel segmentation
% out=matchedfilter(lpDensRPC,5,5);
% figure;imshow(out);
% %%
% T= graythresh(out);
% bwDensRPC = imbinarize(out,T);
% figure; imshow(bwDensRPC);
% 
% conV1 = bwareaopen(bw,200);
% imshow(conV1);
% 
% figure; imshow(DensRPCO);
% 
% openDensRPC = imopen(conV1,strel('disk',3));
% figure;imshow(openDensRPC);
% 
% 
% figure; imshow(DensRPCO);
% maskedRPC = DensRPCO;
% maskedRPC(conV1) =0;
% imshow(maskedRPC);

% se = strel('disk',1);
% closeDensRPC = imclose(subRPC,se);
% figure;imshow(closeDensRPC)
% 
% filtDensRPC = medfilt2(closeDensRPC);
% figure; imshow(filtDensRPC);
% 
% compDensRPC = imcomplement(filtDensRPC);
% figure; imshow(compDensRPC);
% 
% binDensRPC = imbinarize (compDensRPC,'adaptive');
% figure;imshow(binDensRPC)
% 
% options = struct('FrangiScaleRange',[5 13],'FrangiScaleRatio',1,'FrangiBetaOne',...
% 0.5,'FrangiBetaTwo',0.5, 'FrangiC',500,'verbose',true,'BlackWhite',false);
% 
% V = FrangiFilter2D(J2,options);
% imshow(V,[])
% 
% T= adaptthresh(V,1);
% % bwDensRPC = imbinarize(meanDensRPC,T);
% % figure; imshow(bwDensRPC);
% V1 = imbinarize(V,T);
% figure;imshow(V1);
% 
% se = strel('disk',3);
% closeV = imclose(V,se);
% figure;imshow(closeV)
% 
% compV = imcomplement(V);
% imshow(compV);
% 
% 
% BW = edge(compDensRPC,'canny');
% imshow(BW);
% 
% se = strel('disk',12);
% closeDensRPC = imclose(V,se);
% imshow(closeDensRPC)