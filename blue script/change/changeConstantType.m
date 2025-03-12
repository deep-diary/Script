function changedPath = changeConstantType(constantPath, typeOrg, typeTarget)
%%
% 目的: 根据常量路径，改变常量的数据类型
% 输入：
%       constantPath: 对应常量的路径
%       typeOrg: 对应常量源类型
%       typeTarget: 对应常量的目标类型
% 返回：changedPath: 变更过的路径列表
% 范例： changedPath = changeConstantType(constantPath, "Inherit: Inherit from 'Constant value'", 'single')
% 作者： Blue.ge
% 日期： 20230928
%%
    clc
    changedPath = {};
    for i =1:length(constantPath)
        type = get_param(constantPath{i}, 'OutDataTypeStr')
        if strcmp(type, typeOrg)
            changedPath{end+1}=constantPath{i};
            set_param(constantPath{i}, 'OutDataTypeStr', typeTarget)
        end
    end
    length(changedPath)
end