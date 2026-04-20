function [PathConst, ParamConst] = findParamConstant(path)
%FINDPARAMCONSTANT 查找 Constant 块中引用到的“简单工作区名”标定量候选
%
% 仅收集 Value 为单个合法 MATLAB 标识符（无点号、非纯数值）的 Constant，
% 用于与枚举字面量（如 LockSt3.LockLockd、OnOff1.On）区分。
%
% 输入:
%   path - gcs、子系统路径或 bdroot
% 输出:
%   PathConst  - 对应 Constant 块路径（cellstr）
%   ParamConst - Value 字符串（cellstr，已去重）
%
% 示例:
%   [p, n] = findParamConstant(gcs);
%
% 作者: Blue.ge
% 日期: 20231027
% 变更: 2026-04-20 去掉 clc；数值判断改用 str2double；带点限定名跳过

PathConst = {};
ParamConst = {};

valuePath = find_system(path, 'FollowLinks', 'on', 'BlockType', 'Constant');
for i = 1:numel(valuePath)
    try
        value = strtrim(char(get_param(valuePath{i}, 'Value')));
        if isempty(value)
            continue;
        end
        % 纯数值字面量（含 0、科学计数法等）
        if ~isnan(str2double(value))
            continue;
        end
        % 枚举/结构体域等限定名，非简单标定名
        if contains(value, '.')
            continue;
        end
        if isvarname(value)
            ParamConst{end+1} = value; %#ok<AGROW>
            PathConst{end+1} = valuePath{i}; %#ok<AGROW>
        end
    catch
    end
end
[ParamConst, ia] = unique(ParamConst, 'stable');
PathConst = PathConst(ia);
end
