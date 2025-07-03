function [ModelName, validPath] = findValidPath(path)
%%
% 目的: 根据输入路径类型，返回有效的路径，便于find_system 函数使用
% 输入：
%       Null
% 返回： validPath: 可以用于find_system的有效路径
% 范例： [ModelName, validPath] = findValidPath(path)
% 作者： Blue.ge
% 日期： 20231114
%%
    clc
    hMd=get_param(path,'Handle');
    mdBlock = get(hMd);
    try
        mdType = mdBlock.BlockType;
    catch
        mdType = 'SubSystem';
    end
    
    if strcmp(mdType,'SubSystem')
        ModelName = mdBlock.Name;
        validPath = path;
    elseif strcmp(mdType,'ModelReference')
        ModelName = mdBlock.ModelName;
        load_system(ModelName);
        validPath = ModelName;
    else
        error('this is block type not belongs to SubSystem or ModelReference')
    end
    

end
