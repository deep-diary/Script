function uninstallSmartToolstrip
    slDestroyToolstripComponent("SmartToolstrip","RemoveFromPath",true);
    rootDir = fileparts(mfilename('fullpath'));
    path2remove = {};
    path2remove{end+1} = rootDir;
    path2remove{end+1} = fullfile(rootDir,'Add');
    path2remove{end+1} = fullfile(rootDir,'Align');
    path2remove{end+1} = fullfile(rootDir,'blue script');
    path2remove{end+1} = fullfile(rootDir,'ChangeStyle');
    path2remove{end+1} = fullfile(rootDir,'CheckModelingStandard');
    path2remove{end+1} = fullfile(rootDir,'DataDictionary');
    path2remove{end+1} = fullfile(rootDir,'SignalResolve');
    for i = 1:length(path2remove)
        rmpath(path2remove{i});
    end
    fprintf("已卸载Smart工具栏\n");
    restoredefaultpath
    savepath
end
