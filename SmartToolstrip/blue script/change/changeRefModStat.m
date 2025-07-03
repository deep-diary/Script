function changeRefModStat()
%%
% 目的: 刷新当前路径下的所有子模型
% 输入：
%       Null
% 返回：Null
% 范例：changeRefModStat(gcs)
% 作者： Blue.ge
% 日期： 20231020
%%
    clc
    ModelReference = find_system(gcs,'SearchDepth',1,'BlockType','ModelReference');
    for i=1:length(ModelReference)
        Simulink.ModelReference.refresh(ModelReference{i});
    end
end