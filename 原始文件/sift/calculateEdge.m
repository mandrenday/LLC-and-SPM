function [database, lenStat] = calculateEdge(rt_img_dir,rt_data_dir)
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
% img_dir = 'image';       % directory for the image database                             
% dataSet='Caltech101';
% rt_img_dir = fullfile(img_dir, dataSet);
% rt_data_dir='Edgedata';
maxImSize=256;
% nrml_threshold=1;
disp('Extracting EdgeSIFT features...');
subfolders = dir(rt_img_dir);

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
            tic;
            [I,gridX,gridY] = mexEdge(imgpath);
           toc;
            im_h=256;
            im_w=256;
            %[gridY,gridX] = meshgrid(1:im_h,1:im_w);
            
            EdgeSet.x=gridX;
            EdgeSet.y=gridY;
            EdgeSet.width = im_w;
            EdgeSet.height = im_h;
            EdgeSet.feaArr=I;

          
             
            [pdir, fname] = fileparts(frames(jj).name);                        
            fpath = fullfile(rt_data_dir, subname, [fname, '.mat']);
            fprintf('Processing %s: wid %d, hgt %d, grid size: %d x %d, %d patches\n', ...
                     frames(jj).name, im_w, im_h, size(gridX, 2), size(gridX, 1), numel(gridX));
            save(fpath, 'EdgeSet');
            database.path = [database.path, fpath];
        end;    
    end;
end;
    
lenStat = hist(siftLens, 100);
