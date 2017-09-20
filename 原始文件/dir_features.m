function [database] = dir_features(rt_data_dir,nFea)
%=========================================================================
% inputs
% rt_data_dir   -the rootpath for the database. e.g. '../data/caltech101'
% outputs
% database      -a tructure of the dir
%                   .path   pathes for each image file
%                   .label  label for each image file
% written by Jianchao Yang
% Mar. 2009, IFP, UIUC
%=========================================================================

fprintf('dir the database...');
subfolders = dir(rt_data_dir);

% database = [];
% database.label = []; % label of each class
% database.path = {}; % contain the pathes for each image of each class
 database = struct;
 database.path = cell(nFea, 1);         % path for each image feature
 database.label = zeros(nFea, 1);       % class label for each image feature
iter1=1;
for ii = 1:length(subfolders),
    subname = subfolders(ii).name;
    
    if ~strcmp(subname, '.') & ~strcmp(subname, '..'),        
        %database.cname{database.nclass} = subname;
       
        frames = dir(fullfile(rt_data_dir, subname, '*.mat'));
        c_num = length(frames);
                    
        %database.imnum = database.imnum + c_num;
        %database.label = [database.label; ones(c_num, 1)*database.nclass];
        
        for jj = 1:c_num,
            c_path = fullfile(rt_data_dir, subname, frames(jj).name);
            %database.path = [database.path, c_path];
            
            database.path{iter1}=c_path;
            database.label(iter1)=str2num(subname);
            %database.label(iter1)=
            %database.label=[database.label, subname];
            iter1=iter1+1;
        end;    
    end;
end;
disp('done!');