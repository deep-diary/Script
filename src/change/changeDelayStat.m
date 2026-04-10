function changeDelayStat(pathMd, type)
%%
% 目的: 改变模型或者子模型delay属性
% 输入：
%       pathMd: 模型路径
%       type: 注释属性：type could be on, off, through
% 返回：None
% 范例： changeDelayStat(bdroot, 'through') type could be on, off, through
% 状态：使用范围不大，临时脚本
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
    
    load_system(ModelName);
    delays = find_system(ModelName,'SearchDepth',1,'BlockType', 'UnitDelay');
    for i=1:length(delays)
        set_param(delays{i}, 'Commented', type)
    end
end