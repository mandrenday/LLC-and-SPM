% ========================================================================
% Pooling the llc codes to form the image feature
% USAGE: [beta] = LLC_pooling(feaSet, B, pyramid, knn)
% Inputs
%       feaSet      -the coordinated local descriptors
%       B           -the codebook for llc coding
%       pyramid     -the spatial pyramid structure
%       knn         -the number of neighbors for llc coding
% Outputs
%       beta        -the output image feature
%
% Written by Jianchao Yang @ IFP UIUC
% May, 2010
% ========================================================================

function [beta] = LLC_edgepooling(feaSet, B, pyramid, knn,EdgeSet)
knn=5;
dSize = size(B, 2);
nSmp = size(feaSet.feaArr, 2);

img_width = feaSet.width;
img_height = feaSet.height;
idxBin = zeros(nSmp, 1);

% llc coding
llc_codes = LLC_coding_appr(B', feaSet.feaArr', knn);
llc_codes = llc_codes';

% spatial levels
pLevels = length(pyramid);
% spatial bins on each level
pBins = pyramid.^2;
% total spatial bins
tBins = sum(pBins);
%sumedgenumber=size(EdgeSet.x,1);
beta = zeros(dSize, tBins);
bId = 0;
%spm_weigh= [1/16,0.25,1];

for iter1 = 1:pLevels,
    
    nBins = pBins(iter1);
    
    wUnit = img_width / pyramid(iter1);
    hUnit = img_height / pyramid(iter1);
    
    % find to which spatial bin each local descriptor belongs
    
    EdgexBin=ceil(EdgeSet.x /wUnit);
    EdgeyBin=ceil(EdgeSet.y /hUnit);
    EdgeidxBin=(EdgeyBin - 1)*pyramid(iter1)+EdgexBin; 

    xBin = ceil(feaSet.x / wUnit);
    yBin = ceil(feaSet.y / hUnit);
    idxBin = (yBin - 1)*pyramid(iter1) + xBin;
    
    
    
    for iter2 = 1:nBins,     
        bId = bId + 1;
        sidxBin = find(idxBin == iter2);
        EdgesidxBin=find(EdgeidxBin==iter2);
        weight=length(EdgesidxBin);   
        if isempty(sidxBin),
            continue;
        end      
       beta(:, bId) =weight*max(llc_codes(:, sidxBin), [], 2);
      % beta(:, bId) = max(llc_codes(:, sidxBin), [], 2);
    end
end

if bId ~= tBins,
    error('Index number error!');
end

beta = beta(:);
beta = beta./sqrt(sum(beta.^2));

