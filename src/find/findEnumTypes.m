function enumInfo = findEnumTypes(varargin)
%FINDENUMTYPES 扫描当前 MATLAB 会话中已加载的枚举类并返回明细
%
% 语法:
%   enumInfo = findEnumTypes()
%   enumInfo = findEnumTypes(displaySetting)
%   enumInfo = findEnumTypes('className', className)
%   enumInfo = findEnumTypes(..., 'Name', Value, ...)
%
% 功能描述:
%   在当前 MATLAB 会话中遍历已加载类（meta.class.getAllClasses），筛选包含
%   EnumeratedValues 的枚举类，并汇总:
%   1) 枚举类名称列表；
%   2) 每个枚举类的“枚举值 -> 枚举名”文本明细（保持原实现的 int32 映射方式）。
%   当 displaySetting='displayOn' 时，额外在命令行打印同样内容。
%
% 输入参数:
%   displaySetting - 可选显示模式 (char/string)，可选值:
%                    'displayOn'  (默认)  打印命令行信息
%                    'displayOff' 不打印命令行信息
%
% 可选参数（Name-Value）:
%   'className'      - 枚举类名过滤条件 (char/string)，默认: ''（不过滤）
%                      当传入非空时，仅返回命中的枚举类
%   'classMatchMode' - 类名匹配方式: 'contains'|'exact'，默认: 'contains'
%   'ignoreCase'     - 类名匹配是否忽略大小写 (logical)，默认: true
%
% 输出参数:
%   enumInfo - 结构体，字段:
%              enumClassNames - 枚举类名称（string 列向量）
%              enumCount      - 枚举类个数（double）
%              details        - 枚举类明细结构体数组，字段:
%                               ClassName / EnumNames / EnumValues / DisplayText
%              displayText    - 可直接用于日志显示的汇总文本（char）
%
% 异常与边界行为:
%   - displaySetting 非 {'displayOn','displayOff'} 时 error。
%   - classMatchMode 非 {'contains','exact'} 时 error。
%   - 某个类的枚举值读取失败时，继续处理其它类，并在 details 中保留可用信息。
%
% 示例:
%   % 示例1：命令行打印并获取结构化结果
%   info = findEnumTypes();
%
%   % 示例2：仅获取结果，不在命令行打印
%   info = findEnumTypes('displayOff');
%
%   % 示例3：快速过滤指定类名（包含匹配）
%   info = findEnumTypes('className', 'Veh');
%
%   % 示例4：精确匹配某个枚举类，并关闭命令行输出
%   info = findEnumTypes('displayOff', 'className', 'E_MyEnum', 'classMatchMode', 'exact');
%
% 参见: META.CLASS.GETALLCLASSES
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.2
% 日期: 2026-04-10
% 变更记录:
%   2026-04-10 v1.2 新增 className/classMatchMode/ignoreCase，可快速过滤指定枚举类。
%   2026-04-10 v1.1 补齐规范文档并提供结构化返回值 enumInfo，便于 GUI 复用。
%   2025-07-03 v1.0 初版（扫描已加载枚举类并打印）。

displaySetting = 'displayOn';
rawArgs = varargin;

allowedStrings = {'displayOff', 'displayOn'};
if ~isempty(rawArgs) && (ischar(rawArgs{1}) || isstring(rawArgs{1}))
    token = char(string(rawArgs{1}));
    if any(strcmp(token, allowedStrings))
        displaySetting = token;
        rawArgs = rawArgs(2:end);
    elseif numel(rawArgs) == 1
        % 兼容快捷调用：findEnumTypes('MyEnum') 等价于 className 过滤
        rawArgs = {'className', token};
    end
end

if all(~strcmp(displaySetting, allowedStrings))
    error('%s: displaySetting 仅支持 ''displayOff'' 或 ''displayOn''。', mfilename);
end

p = inputParser;
addParameter(p, 'className', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'classMatchMode', 'contains', ...
    @(x) any(strcmpi(char(string(x)), {'contains', 'exact'})));
addParameter(p, 'ignoreCase', true, @islogical);
parse(p, rawArgs{:});

classNameFilter = char(string(p.Results.className));
classMatchMode = lower(char(string(p.Results.classMatchMode)));
ignoreCase = p.Results.ignoreCase;

allClasses = meta.class.getAllClasses;
allClasses = [allClasses{:}];

enumClassNames = strings(0, 1);
details = repmat(struct( ...
    'ClassName', '', ...
    'EnumNames', strings(0, 1), ...
    'EnumValues', zeros(0, 1), ...
    'DisplayText', ''), 0, 1);
displayText = '';

for i = 1:length(allClasses)
    if ~isempty(allClasses(i).EnumeratedValues) && ...
            i_isClassMatched(allClasses(i).Name, classNameFilter, classMatchMode, ignoreCase)
        [classText, className, enumNames, enumValues] = i_enumList(allClasses(i));
        enumClassNames(end+1, 1) = string(className); %#ok<AGROW>
        details(end+1, 1) = struct( ... %#ok<AGROW>
            'ClassName', className, ...
            'EnumNames', enumNames, ...
            'EnumValues', enumValues, ...
            'DisplayText', classText);
        displayText = sprintf('%s\n- %s\t%s\n', displayText, allClasses(i).Name, classText);
    end
end

enumInfo = struct();
enumInfo.enumClassNames = enumClassNames;
enumInfo.enumCount = numel(enumClassNames);
enumInfo.details = details;
enumInfo.displayText = displayText;

if strcmp(displaySetting, 'displayOn')
    if isempty(displayText)
        fprintf(1, '\n\tNO ENUM TYPE DEFINED\n\n');
    else
        fprintf(1, 'Currently loaded Enum Types are: \n');
        fprintf(1, '%s\n\n', displayText);
    end
end

end

function tf = i_isClassMatched(className, classNameFilter, classMatchMode, ignoreCase)
if isempty(classNameFilter)
    tf = true;
    return;
end
src = string(className);
flt = string(classNameFilter);
if ignoreCase
    src = lower(src);
    flt = lower(flt);
end
switch classMatchMode
    case 'exact'
        tf = (src == flt);
    otherwise % contains
        tf = contains(src, flt);
end
end

function [listText, className, enumNames, enumValues] = i_enumList(enumClass)
enums = enumClass.EnumeratedValues;
className = enumClass.Name;
listText = sprintf('\t');
enumNames = strings(0, 1);
enumValues = zeros(0, 1);
try
    for e = [enums{:}]
        v = eval(['int32(' enumClass.Name '.' e.Name ')']); %#ok<EVLDIR>
        listText = sprintf('%s\n\t%i\t->\t%s', listText, v, e.Name);
        enumNames(end+1, 1) = string(e.Name); %#ok<AGROW>
        enumValues(end+1, 1) = double(v); %#ok<AGROW>
    end
catch
    fprintf(1, 'Error displaying enumerated values for class %s\n', enumClass.Name);
end
end
