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

% -------------------------------------------------------------------------
% parameter setting
%pyramid = [1, 2, 4];                % spatial block structure for the SPM
pyramid = [2];
knn = 5;                            % number of neighbors for local coding
cbrave = 10;                             % regularization parameter for linear SVM
                                    % in Liblinear package

nRounds = 1;                       % number of random test on the dataset
%Ac_num=200;
%tr_num  = 0;                       % training examples per category
mem_block = 4000;                   % maxmum number of testing features loaded each time  
%gridSpacing = 28;
%patchSize = 56;
%maxImSize =256;
gridSpacing = 8;
patchSize = 16;
maxImSize =256;
nrml_threshold = 1;

% -------------------------------------------------------------------------
% set path
addpath('Liblinear/matlab');        % we use Liblinear package, you need 
addpath('sift');                               % download and compile the matlab codes

train_img_dir = '98train_image';       % directory for the image database
test_img_dir='98test_image';
dic_img_dir='150dic';

train_data_dir = 'train_data';       % directory for saving SIFT descriptors
test_data_dir='test_data';
%dic_data_dir='width256mex_hog_dictionarydata';

train_fea_dir = 'train_feature';    % directory for saving final image features
test_fea_dir='test_feature';

%train_edgedata_dir = 'sobel_traindata';       % directory for saving SIFT descriptors
%test_edgedata_dir='sobel_testdata';

dataset='Caltech101';
%feature_dir='features';
train_rt_img_dir=fullfile(train_img_dir,dataset);
test_rt_img_dir=fullfile(test_img_dir,dataset);
%dic_rt_img_dir=fullfile(dic_img_dir,dataset);
% -------------------------------------------------------------------------
% extract SIFT descriptors, we use Prof. Lazebnik's matlab codes in this package
% change the parameters for SIFT extraction inside function 'extr_sift'
% extr_sift(img_dir, data_dir);
%[train_database,lenStat] = CalculateSiftDescriptor(train_rt_img_dir, train_data_dir, gridSpacing, patchSize, maxImSize, nrml_threshold);
%[test_database,lenStat]= CalculateSiftDescriptor(test_rt_img_dir, test_data_dir, gridSpacing, patchSize, maxImSize, nrml_threshold);
[train_database,lenStat] = opencv_hog(train_rt_img_dir, train_data_dir, gridSpacing, patchSize, maxImSize, nrml_threshold);
[test_database,lenStat]= opencv_hog(test_rt_img_dir, test_data_dir, gridSpacing, patchSize, maxImSize, nrml_threshold);
%[dic_database] = opencv_hog(dic_rt_img_dir, dic_data_dir, gridSpacing, patchSize, maxImSize, nrml_threshold);
%[test_database] = opencv_hog(test_rt_img_dir, test_data_dir, gridSpacing, patchSize, maxImSize, nrml_threshold);
%[database, lenStat] = Hog(rt_img_dir, data_dir, gridSpacing, patchSize, maxImSize, nrml_threshold);
% -------------------------------------------------------------------------
% retrieve the directory of the database and load the codebook
 train_database = retr_database_dir(train_data_dir);
 test_database = retr_database_dir(test_data_dir);
% 
% %edgetraindata_database=retr_database_dir(train_edgedata_dir);
% %edgetestdata_database=retr_database_dir(test_edgedata_dir);
% 
% % if isempty(database),
% %     error('Data directory error!');
% % end
% 
 Bpath = ['dictionary/step8image256_mex_hog_1024.mat'];
% 
 load(Bpath);
 nCodebook = size(centers, 2);              % size of the codebook
% 
% %-------------------------------------------------------------------------
%extract image features

dFea = sum(nCodebook*pyramid.^2);
% dFea = nCodebook*16;
% nFea_train = length(train_database.path);
nFea_test=length(test_database.path);
% 
% nFea=nFea_train+nFea_test;
% 
% train_fdatabase = struct;
% train_fdatabase.path = cell(nFea_train, 1);         % path for each image feature
% train_fdatabase.label = zeros(nFea_train, 1);       % class label for each image feature
% 
test_fdatabase = struct;
test_fdatabase.path = cell(nFea_test, 1);         % path for each image feature
test_fdatabase.label = zeros(nFea_test, 1);       % class label for each image feature
% 
% 
for iter1 = 1:nFea_train,  
    if ~mod(iter1, 5),
       fprintf('.');
    end
    if ~mod(iter1, 100),
        fprintf(' %d images processed\n', iter1);
    end
    fpath = train_database.path{iter1};
    flabel = train_database.label(iter1);
    
    %edgepath=edgetraindata_database.path{iter1};
    
    %load(edgepath);
    load(fpath);
    [rtpath, fname] = fileparts(fpath);
    feaPath = fullfile(train_fea_dir, num2str(flabel), [fname '.mat']);
    
 
    fea = LLC_pooling(feaSet, centers, pyramid, knn);
    %fea=LLC_edgepooling(feaSet,centers,pyramid,knn,EdgeSet);
    label = train_database.label(iter1);

    if ~isdir(fullfile(train_fea_dir, num2str(flabel))),
        mkdir(fullfile(train_fea_dir, num2str(flabel)));
    end      
    %save(feaPath, 'fea', 'label');
    save(feaPath, 'fea');
    
    train_fdatabase.label(iter1) = flabel;
    train_fdatabase.path{iter1} = feaPath;
end
% 
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
% 
% 
% 
% % -------------------------------------------------------------------------
% % evaluate the performance of the image feature using linear SVM
% % we used Liblinear package in this example code
% 
% %fdatabase=dir_features(feature_dir);
% 
% train_fdatabase=dir_features(train_fea_dir,28011);
% test_fdatabase=dir_features(test_fea_dir,28816);
% 
% fprintf('\n Testing...\n');
% clabel = unique(train_fdatabase.label);
% nclass = length(clabel);
% accuracy = zeros(nRounds, 1);
% 
% 
% for ii = 1:nRounds,
%     fprintf('Round: %d...\n', ii);
%     tr_idx = [];
%     ts_idx = [];
%     
%     for jj = 1:nclass,
%         train_idx_label = find(train_fdatabase.label == clabel(jj));
%         test_idx_label=find(test_fdatabase.label==clabel(jj));
%         train_num = length(train_idx_label);
%         test_num=length(test_idx_label);
%              
%         %idx_rand = randperm(num);
%         
%         tr_idx = [tr_idx; train_idx_label(1:train_num)];
%         ts_idx = [ts_idx; test_idx_label(1:test_num)];
%     end
%     
%     fprintf('Training number: %d\n', length(tr_idx));
%     fprintf('Testing number:%d\n', length(ts_idx));
%     
%     % load the training features 
%     tr_fea = zeros(length(tr_idx), dFea);
%     tr_label = zeros(length(tr_idx), 1);
%     
%     for jj = 1:length(tr_idx),
%         fpath = train_fdatabase.path{tr_idx(jj)};
%         load(fpath, 'fea', 'label');
%         tr_fea(jj, :) = fea';
%         tr_label(jj) = label;
%     end
%     
%     options = ['-c ' num2str(cbrave)];
%     model = train(double(tr_label), sparse(tr_fea), options);
%     %load('C:\150classAutoSPMWeightedLLCSVMmodel','model');
%     
%     clear tr_fea;
% 
%     % load the testing features
%     ts_num = length(ts_idx);
%     ts_label = [];
%     
%     if ts_num < mem_block,
%         % load the testing features directly into memory for testing
%         ts_fea = zeros(length(ts_idx), dFea);
%         ts_label = zeros(length(ts_idx), 1);
% 
%         for jj = 1:length(ts_idx),
%             fpath = test_fdatabase.path{ts_idx(jj)};
%             load(fpath, 'fea', 'label');
%             ts_fea(jj, :) = fea';
%             ts_label(jj) = label;
%         end
% 
%         [C] = predict(ts_label, sparse(ts_fea), model);
%     else
%         % load the testing features block by block
%         num_block = floor(ts_num/mem_block);
%         rem_fea = rem(ts_num, mem_block);
%         
%         curr_ts_fea = zeros(mem_block, dFea);
%         curr_ts_label = zeros(mem_block, 1);
%         
%         C = [];
%         
%         for jj = 1:num_block,
%             block_idx = (jj-1)*mem_block + (1:mem_block);
%             curr_idx = ts_idx(block_idx); 
%             
%             % load the current block of features
%             for kk = 1:mem_block,
%                 fpath = test_fdatabase.path{curr_idx(kk)};
%                 load(fpath, 'fea', 'label');
%                 curr_ts_fea(kk, :) = fea';
%                 curr_ts_label(kk) = label;
%             end    
%             
%             % test the current block features
%             ts_label = [ts_label; curr_ts_label];
%             [curr_C] = predict(curr_ts_label, sparse(curr_ts_fea), model);
%             C = [C; curr_C];
%         end
%         
%         curr_ts_fea = zeros(rem_fea, dFea);
%         curr_ts_label = zeros(rem_fea, 1);
%         curr_idx = ts_idx(num_block*mem_block + (1:rem_fea));
%         
%         for kk = 1:rem_fea,
%            fpath = test_fdatabase.path{curr_idx(kk)};
%            load(fpath, 'fea', 'label');
%            curr_ts_fea(kk, :) = fea';
%            curr_ts_label(kk) = label;
%         end  
%         
%         ts_label = [ts_label; curr_ts_label];
%         [curr_C] = predict(curr_ts_label, sparse(curr_ts_fea), model); 
%         C = [C; curr_C];        
%     end
%     
%     % normalize the classification accuracy by averaging over different
%     % classes
%     acc = zeros(nclass, 1);
% 
%     for jj = 1 : nclass,
%         c = clabel(jj);
%         idx = find(ts_label == c);
%         curr_pred_label = C(idx);
%         curr_gnd_label = ts_label(idx);    
%         acc(jj) = length(find(curr_pred_label == curr_gnd_label))/length(idx);
%     end
% 
%     accuracy(ii) = mean(acc); 
%     fprintf('Classification accuracy for round %d: %f\n', ii, accuracy(ii));
% end
% 
% Ravg = mean(accuracy);                  % average recognition rate
% Rstd = std(accuracy);                   % standard deviation of the recognition rate
% 
% fprintf('===============================================');
% fprintf('Average classification accuracy: %f\n', Ravg);
% fprintf('Standard deviation: %f\n', Rstd);    
% fprintf('===============================================');
    
