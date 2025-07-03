function installSmartToolstrip
    %% Add path
    % Get the current course folder
    rootDir = fileparts(mfilename('fullpath'));
    % Populate list of folders to add to path
    allSubfolders = genpath(rootDir);
    addpath(allSubfolders);  % 添加到 MATLAB 路径
    savepath; 
    fprintf("已添加路径:%s\n",rootDir);
%     path2add = {};
%     path2add{end+1} = rootDir;
%     path2add{end+1} = fullfile(rootDir,'CheckModelingStandard');
% 
%     path2add{end+1} = fullfile(rootDir,'resources');
%     path2add{end+1} = fullfile(rootDir,'resources/icons');
%     path2add{end+1} = fullfile(rootDir,'resources/icons');
%     addpath(path2add{:},'-end');
    %% install
    start_simulink
        slReloadToolstripConfig;
    fprintf("已安装Smart工具栏\n");
end