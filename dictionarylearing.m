% =========================================================================
% An example code for the algorithm proposed in
%
%   Jinjun Wang, Jianchao Yang, Kai Yu, Fengjun Lv, Thomas Huang, and Yihong Gong.
%   "Locality-constrained Linear Coding for Image Classification", CVPR 2010.
%
%
% Written by Jianchao Yang @ IFP UIUC
% May, 2010.
% =========================================================================

clear all; close all; clc;


img_dir = 'G:\img';       % directory for the image database                             
data_dir = 'D:\Documents\Tencent Files\1432874755\FileRecv\程序\HOG\HOG_llc\features';       % directory for saving SIFT descriptors
center_dir='D:\Documents\Tencent Files\1432874755\FileRecv\程序\HOG\HOG_llc\dictionary';   %最终保存聚类结果的位置

% -------------------------------------------------------------------------
% extract SIFT descriptors, we use Prof. Lazebnik's matlab codes in this package
% change the parameters for SIFT extraction inside function 'extr_sift'
%extr_sift(img_dir, data_dir);

% -------------------------------------------------------------------------
% retrieve the directory of the database and load the codebook
database = retr_database_dir(data_dir);

if isempty(database),
    error('Data directory error!');
end

% Bpath = ['dictionary/dict_Caltech101_512.mat'];
% 
% load(Bpath);
% nCodebook = size(B, 2);              % size of the codebook

% -------------------------------------------------------------------------
% extract image features

%dFea = sum(nCodebook*pyramid.^2);
nFea = length(database.path);

%fdatabase = struct;
%fdatabase.path = cell(nFea, 1);         % path for each image feature
%fdatabase.label = zeros(nFea, 1);       % class label for each image feature
%Kdata=zeros(128,4556350);%4096
numClusters=128;
Kdata=zeros(128,1681000);
CoutNum=1;
for iter1=1:nFea,
    if ~mod(iter1, 5),
       fprintf('.');
    end
    if ~mod(iter1, 100),
        fprintf(' %d images processed\n', iter1);
    end
    fpath = database.path{iter1};
    flabel = database.label(iter1);
    
    load(fpath);
    A=size(feaSet.feaArr,2);
    Kdata(:,CoutNum:CoutNum+A-1)=feaSet.feaArr(:,1:A);
    CoutNum=CoutNum+A;
    %[rtpath, fname] = fileparts(fpath);
    %feaPath = fullfile(fea_dir, num2str(flabel), [fname '.mat']);
    
end
tic;
[centers, assignments] = vl_kmeans(Kdata, numClusters, 'Initialization', 'plusplus') ;
toc;

fpath = fullfile(center_dir, 'center.mat');
save(fpath,'centers');
%numData = 1000 ;
%dimension = 2 ;
%data = rand(dimension,numData) ;