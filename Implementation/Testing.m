clc;
clear all;
close all;
%% READ INPUT IMAGE
text = fileread('F:\Projects\Identification and Quantification of Immune Stain TILs\imagepath.txt');
Img=imread(text);
%figure;
% imshow(Img);
% title('Input Image');
imwrite(Img, 'F:\Projects\Identification and Quantification of Immune Stain TILs\output\images\Input Image.jpg');
imwrite(Img, 'F:\Projects\Identification and Quantification of Immune Stain TILs\output\Input Image.jpg');
m=size(Img,1);
n=size(Img,2);
Feature_Vector_Final=[];

%% ROLLING BALL FOR IMAGE ENHANCEMENT
rollball=offsetstrel('ball', 18, 5);
dilatedImg=imdilate(Img, rollball);
Imgop=dilatedImg-Img;
iminvert=imcomplement(Imgop);
% figure;
% imshow(iminvert);
imwrite(iminvert, 'F:\Projects\Identification and Quantification of Immune Stain TILs\output\images\Rolling Ball.jpg');
% title('Rolling Ball Output')
%% SEPARATION OF STAINED AND UNSTAINED PLANES
labimg=rgb2lab(iminvert);
labimg2=labimg(:,:,2:3);
m1=size(labimg2,1);
n1=size(labimg2,2);
o1=size(labimg2,3);
labimg2=reshape(labimg2, m1*n1, 2);
nColors=3;
[mu, mask]=kmeans(labimg2, nColors, 'distance', 'sqEuclidean', 'Replicates', 3);
pixel_labels=reshape(mu, m1, n1);
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);
for k = 1:nColors
    color = Img;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end
% figure, imshow(segmented_images{1}), title('Objects in cluster 1');
imwrite(segmented_images{1}, 'F:\Projects\Identification and Quantification of Immune Stain TILs\output\images\Plane Segmentation -1.jpg');

pqr=segmented_images{2};
% figure, imshow(segmented_images{2}), title('Objects in cluster 2');
imwrite(segmented_images{2}, 'F:\Projects\Identification and Quantification of Immune Stain TILs\output\images\Plane Segmentation -2.jpg');
% figure, imshow(segmented_images{3}), title('Objects in cluster 3');
imwrite(segmented_images{3}, 'F:\Projects\Identification and Quantification of Immune Stain TILs\output\images\Plane Segmentation -3.jpg');
%% NUCLEI DETECTION
mean_cluster_value = mean(mask, 2, 'double');
[tmp, idx] = sort(mean_cluster_value);
%% POSITIVE TUMOUR CELLS NUCLEI DETECTION
positive_cluster_num = idx(3);
L = labimg(:,:,1);
blue_idx = find(pixel_labels == positive_cluster_num);
L_blue = L(blue_idx);
is_light_blue = imbinarize(rescale(L_blue));
nuclei_labels = repmat(uint8(0),[m n]);
nuclei_labels(blue_idx(is_light_blue==false)) = 1;
nuclei_labels = repmat(nuclei_labels,[1 1 3]);
positive_nuclei = Img;
positive_nuclei(nuclei_labels ~= 1) = 0;
% figure, imshow(positive_nuclei), title('Detected Nuclei(Positive cells)');
imwrite(positive_nuclei, 'F:\Projects\Identification and Quantification of Immune Stain TILs\output\images\Positive Nuclei.jpg');

%% NEGATIVE TUMOUR CELLS NUCLEI DETECTION
negative_cluster_num = idx(1);
L = labimg(:,:,1);
blue_idx = find(pixel_labels == negative_cluster_num);
L_blue = L(blue_idx);
is_light_blue = imbinarize(rescale(L_blue));
nuclei_labels = repmat(uint8(0),[m n]);
nuclei_labels(blue_idx(is_light_blue==false)) = 1;
nuclei_labels = repmat(nuclei_labels,[1 1 3]);
negative_nuclei = Img;
negative_nuclei(nuclei_labels ~= 1) = 0;
% figure, imshow(negative_nuclei), title('Detected Nuclei(Negative cells)');
imwrite(negative_nuclei, 'F:\Projects\Identification and Quantification of Immune Stain TILs\output\images\Negative Nuclei.jpg');
%% POSITIVE FEATURE EXTRACTION
tpos_gray =rgb2gray(positive_nuclei);
tpos_bw = imbinarize(tpos_gray);
tpos_bwLabel = bwlabel(tpos_bw);
sp  = regionprops('table',tpos_bwLabel,'all');

redChannelP = positive_nuclei(:,:,1);
blueChannelP = positive_nuclei(:,:,3);
propsRedP = regionprops('table',tpos_bwLabel, redChannelP, 'MeanIntensity');
propsBlueP = regionprops('table',tpos_bwLabel, blueChannelP, 'MeanIntensity');
%% COMBINE POSITIVE FEATURES TABLE
propsBlueP.Properties.VariableNames{1} = 'blue_mean';
propsRedP.Properties.VariableNames{1} = 'red_mean';
ColorP = horzcat(propsRedP,propsBlueP);
Positive_Features = horzcat(sp,ColorP);
% Y=ones(height(Positive_Features),1);
% Positive_Features=addvars(Positive_Features, Y);
%% POSITIVE FEATURE REDUCTION
Positive_Features(Positive_Features.Area<50,:)=[];
Positive_Features= removevars(Positive_Features,{'ConvexHull','ConvexImage','SubarrayIdx','PixelIdxList','PixelList','Extrema','Image','FilledImage'});
%% NEGATIVE FEATURE EXTRACTION
tneg_gray =rgb2gray(negative_nuclei);
tneg_bw = imbinarize(tneg_gray);
tneg_bwLabel = bwlabel(tneg_bw);
cc = bwconncomp(tneg_bwLabel);
sn  = regionprops('table',tneg_bwLabel,'all');

redChannelN = negative_nuclei(:,:,1);
blueChannelN = negative_nuclei(:,:,3);
propsRedN = regionprops('table',tneg_bwLabel, redChannelN, 'MeanIntensity');
propsBlueN = regionprops('table',tneg_bwLabel, blueChannelN, 'MeanIntensity');
%% COMBINE NEGATIVE FEATURES TABLE
propsBlueN.Properties.VariableNames{1} = 'blue_mean';
propsRedN.Properties.VariableNames{1} = 'red_mean';
ColorN = horzcat(propsRedN,propsBlueN);
Negative_Features = horzcat(sn,ColorN);
% Y=zeros(height(Negative_Features),1);
% Negative_Features=addvars(Negative_Features, Y);
%% NEGATIVE FEATURE REDUCTION
Negative_Features(Negative_Features.Area<50,:)=[];
Negative_Features= removevars(Negative_Features,{'ConvexHull','ConvexImage','SubarrayIdx','PixelIdxList','PixelList','Extrema','Image','FilledImage'});
%% COMBINING BOTH TABLES
Feature_Vector=[Positive_Features;Negative_Features];
Feature_Vector_Final=[Feature_Vector_Final;Feature_Vector];
%% TABLE TO CSV
writetable(Feature_Vector_Final,'TestImage.csv')
