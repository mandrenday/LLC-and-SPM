function [database, lenStat] = Hog(rt_img_dir, rt_data_dir, gridSpacing, patchSize, maxImSize, nrml_threshold)
%==========================================================================
% usage: calculate the sift descriptors given the image directory
%
% inputs
% rt_img_dir    -image database root path
% rt_data_dir   -feature database root path
% gridSpacing   -spacing for sampling dense descriptors
% patchSize     -patch size for extracting sift feature
% maxImSize     -maximum size of the input image
% nrml_threshold    -low contrast normalization threshold
%
% outputs
% database      -directory for the calculated sift features
%
% Lazebnik's SIFT code is used.
%
% written by Jianchao Yang
% Mar. 2009, IFP, UIUC
%==========================================================================
% rt_img_dir='test';
% rt_data_dir='data';
% %dataSet='Caltech101';
% %rt_img_dir = fullfile(img_dir, dataSet);
% gridSpacing=8; 
% patchSize=16;
maxImSize=256;
% nrml_threshold=1;
disp('Extracting HOG features...');
subfolders = dir(rt_img_dir);

cellSize=4;
siftLens = [];

database = [];

database.imnum = 0; % total image number of the database
database.cname = {}; % name of each class
database.label = []; % label of each class
database.path = {}; % contain the pathes for each image of each class
database.nclass = 0;

for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    
    if ~strcmp(subname, '.') & ~strcmp(subname, '..'),
        database.nclass = database.nclass + 1;
        
        database.cname{database.nclass} = subname;
        
        frames = dir(fullfile(rt_img_dir, subname, '*.jpg'));
       %frames = dir(rt_img_dir);
        c_num = length(frames);           
        database.imnum = database.imnum + c_num;
        database.label = [database.label; ones(c_num, 1)*database.nclass];
        
        siftpath = fullfile(rt_data_dir, subname);        
        if ~isdir(siftpath),
            mkdir(siftpath);
        end;
        
        for jj = 1:c_num,
            imgpath = fullfile(rt_img_dir, subname, frames(jj).name);
            
            I = imread(imgpath);
            if ndims(I) == 3,
                %I = im2double(rgb2gray(I));
                I = im2single(rgb2gray(I));
            else
                I = im2single(I);
            end;
            

            I=imresize(I,[256,256],'bicubic');
            [im_h, im_w] = size(I);
            
        
            hog = vl_hog(I, cellSize, 'verbose', 'numOrientations', 9 ,'variant', 'dalaltriggs');
            
            [gridX,gridY] = meshgrid(8:8:im_w, 8:8:im_h);
            
            b=reshape(hog,1024,36);
            
            %Invert_Hog=hog';
            
            %from top to down,left to right 
        
            feaSet.feaArr=b';
            feaSet.x = gridX(:);
            feaSet.y = gridY(:);
            feaSet.width = im_w;
            feaSet.height = im_h;
            
            
            [pdir, fname] = fileparts(frames(jj).name);                        
            fpath = fullfile(rt_data_dir, subname, [fname, '.mat']);
            
            save(fpath, 'feaSet');
            database.path = [database.path, fpath];
        end;    
    end;
end;
    
lenStat = hist(siftLens, 100);







