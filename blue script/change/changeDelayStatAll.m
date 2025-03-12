function changeDelayStatAll(path, type)
%%
% 目的: 改变模型或者子模型delay属性
% 输入：
%       pathMd: 模型路径
%       type: 注释属性：type could be on, off, through
% 返回：None
% 范例： changeDelayStatAll(bdroot, 'through') type could be on, off, through
% 状态：使用范围不大，临时脚本
% 作者： Blue.ge
% 日期： 20230928
%%
    clc

    ModelReference = find_system(path,'SearchDepth',1,'BlockType','ModelReference');
    
    % 为所有次层模型解析信号
    for i=1:length(ModelReference)
        changeDelayStat(ModelReference{i}, type)
    end
        
end
