clear all; close all; clc;

% -------------------------------------------------------------------------
% parameter setting
pyramid = [1, 2, 4];                % spatial block structure for the SPM
%pyramid = [2];
knn = 5;                            % number of neighbors for local coding

test_data_dir='D:\Documents\Tencent Files\1432874755\FileRecv\程序\HOG\HOG_llc\features';
%特征所在的文件夹
test_fea_dir='D:\Documents\Tencent Files\1432874755\FileRecv\程序\HOG\HOG_llc\feature';
%LLC和加权SPM后得到的最终特征存放的文件夹
test_database = retr_database_dir(test_data_dir);
Bpath = ['D:\Documents\Tencent Files\1432874755\FileRecv\程序\HOG\HOG_llc\dictionary\center.mat'];
%聚类结果所存放的mat文件
load(Bpath);
nCodebook = size(centers, 2);              % size of the codebook
dFea = sum(nCodebook*pyramid.^2);
% dFea = nCodebook*16;
% nFea_train = length(train_database.path);
nFea_test=length(test_database.path);
test_fdatabase = struct;
test_fdatabase.path = cell(nFea_test, 1);         % path for each image feature
test_fdatabase.label = zeros(nFea_test, 1);       % class label for each image feature
for iter1 = 1:nFea_test,  
    if ~mod(iter1, 5),
       fprintf('.');
    end
    if ~mod(iter1, 100),
        fprintf(' %d images processed\n', iter1);
    end
    fpath = test_database.path{iter1};
    flabel = test_database.label(iter1);
    
    %edgepath=edgetestdata_database.path{iter1};
    
    %load(edgepath);
    
    load(fpath);
    [rtpath, fname] = fileparts(fpath);
    feaPath = fullfile(test_fea_dir, num2str(flabel), [fname '.mat']);
    
 
    fea = LLC_pooling(feaSet, centers, pyramid, knn);
    label = test_database.label(iter1);

    if ~isdir(fullfile(test_fea_dir, num2str(flabel))),
        mkdir(fullfile(test_fea_dir, num2str(flabel)));
    end      
    %save(feaPath, 'fea', 'label');
    save(feaPath, 'fea');

    
    test_fdatabase.label(iter1) = flabel;
    test_fdatabase.path{iter1} = feaPath;
end