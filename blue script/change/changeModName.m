function changeModName(pathMd, prefix)
%%
% 目的: 为模型增加层级关系数字。
% 输入：
%       Null
% 返回：已经成功创建的端口列表
% 范例：changeModName(pathMd, prefix),
% 说明：1. 鼠标点击在子模型上，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 日期： 20230928
%%
    clc
    hMd=get_param(pathMd,'Handle');
    mdBlock = get(hMd);

%     如果是顶层，直接指定为SubSystem
    if strcmp(pathMd,bdroot)
        mdType='SubSystem';
    else
        mdType=mdBlock.BlockType;
    end
    
    if strcmp(mdType,'ModelReference')
        ModelName = mdBlock.ModelName;
    end

    if strcmp(mdType,'SubSystem')
        ModelName = mdBlock.Name;
    end
    
    subSystem = find_system(pathMd,'SearchDepth',1,'BlockType', 'SubSystem');
    for i=2:length(subSystem)
        name = get_param(subSystem{i}, 'Name')
        newName = [prefix, num2str(i-1,'%01d'),'_',name]  % %02d 前面补0
        set_param(subSystem{i}, 'Name', newName)
    end
end