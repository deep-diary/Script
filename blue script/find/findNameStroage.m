function [dataType, ScSig, ScParam] = findNameStroage(name, varargin)
%FINDNAMESTROAGE 根据信号名获取对应的信号类型和存储类
%
%   [DATATYPE, SCSIG, SCPARAM] = FINDNAMESTROAGE(NAME) 根据信号名称返回对应的
%   数据类型和存储类信息。
%
%   [DATATYPE, SCSIG, SCPARAM] = FINDNAMESTROAGE(NAME, 'project', PROJECT) 
%   指定项目类型，返回对应的数据类型和存储类信息。
%
%   输入参数:
%       NAME    - 信号名称 (字符向量或字符串标量)
%       PROJECT - 项目类型，可选值: 'XCU', 'PCMU', 'VCU', 'CUSTOM'
%                 (默认值: 'XCU')
%
%   输出参数:
%       DATATYPE - 信号数据类型
%       SCSIG    - 信号存储类
%       SCPARAM  - 参数存储类
%
%   示例:
%       [dataType, ScSig, ScParam] = findNameStroage('sTmIn_X_s32EexvPosSts')
%       [dataType, ScSig, ScParam] = findNameStroage('sTmIn_X_s32EexvPosSts', 'project', 'VCU', 'portType', 'Input')
%
%   作者: Blue.ge
%   日期: 2025-06-06

% 验证输入参数
validateattributes(name, {'char', 'string'}, {'scalartext'}, mfilename, 'name');

% 创建输入解析器
p = inputParser;
addParameter(p, 'userDefedSigInStroage', ...
    {'Global1','Global1','Global1','Global1','Global1','Global1','Global1','Global1','Global1',''}, ...
    @iscell);
addParameter(p, 'userDefedSigOutStroage', ...
    {'Global3','Global3','Global3','Global3','Global3','Global3','Global3','Global3','Global3',''}, ...
    @iscell);
addParameter(p, 'userDefedParamStroage', ...
    {'DATA8BIT_APP','DATA16BIT_APP','DATA32BIT_APP','DATA8BIT_APP','DATA16BIT_APP', ...
    'DATA32BIT_APP','DATA32BIT_APP','DATABOOL_APP','DATA64BIT_APP',''}, ...
    @iscell);
addParameter(p, 'project', 'XCU', @(x) ismember(x, {'XCU', 'PCMU', 'VCU', 'CUSTOM'}));
addParameter(p, 'portType', 'Output', @(x) ismember(x, {'Input', 'Output'}));

parse(p, varargin{:});

% 获取解析后的参数
userDefedSigInStroage = p.Results.userDefedSigInStroage;
userDefedSigOutStroage = p.Results.userDefedSigOutStroage;
userDefedParamStroage = p.Results.userDefedParamStroage;
project = p.Results.project;
portType = p.Results.portType;

% 定义数据类型映射
shortTypes = {'i8','i16','i32','u8','u16','u32','s32','_B_','u64',''};
dataTypes = {'int8','int16','int32','uint8','uint16','uint32','single','boolean','uint64','Inherit: auto'};

% 定义各项目的存储类映射
ScSigInPCMUs = {'Global1','Global1','Global1','Global1','Global1','Global1','Global1','Global1','Global1',''};
ScSigOutPCMUs = {'Global3','Global3','Global3','Global3','Global3','Global3','Global3','Global3','Global3',''};
ScParamPCMUs = {'CAL_8BIT','CAL_16BIT','CAL_32BIT','CAL_8BIT','CAL_16BIT','CAL_32BIT','CAL_32BIT','CAL_8BIT','CAL_64BIT',''};

ScSigInVCUs = {'DATA8BIT_IMP','DATA16BIT_IMP','DATA32BIT_IMP','DATA8BIT_IMP','DATA16BIT_IMP','DATA32BIT_IMP','DATA32BIT_IMP','DATABOOL_IMP','DATA64BIT_IMP',''};
ScSigOutVCUs = {'DATA8BIT_APP','DATA16BIT_APP','DATA32BIT_APP','DATA8BIT_APP','DATA16BIT_APP','DATA32BIT_APP','DATA32BIT_APP','DATABOOL_APP','DATA64BIT_APP',''};
ScParamVCUs = {'CAL8BIT','CAL16BIT','CAL32BIT','CAL8BIT','CAL16BIT','CAL32BIT','CAL32BIT','CAL8BIT','CAL64BIT',''};

ScSigInXCUs = {'FastRam_8_XCU','FastRam_16_XCU','FastRam_32_XCU','FastRam_8_XCU','FastRam_16_XCU','FastRam_32_XCU','FastRam_32_XCU','FastRam_Boolean_XCU','FastRam_32_XCU',''};
ScSigOutXCUs = {'FastRam_8_XCU','FastRam_16_XCU','FastRam_32_XCU','FastRam_8_XCU','FastRam_16_XCU','FastRam_32_XCU','FastRam_32_XCU','FastRam_Boolean_XCU','FastRam_32_XCU',''};
ScParamXCUs = {'CalData_8_XCU','CalData_16_XCU','CalData_32_XCU','CalData_8_XCU','CalData_16_XCU','CalData_32_XCU','CalData_32_XCU','CalData_Boolean_XCU','CalData_32_XCU',''};

% 查找匹配的数据类型
idx = 0;
for j = 1:length(shortTypes)
    if contains(name, shortTypes{j})
        idx = j;
        break;
    end
end

% 获取数据类型
dataType = dataTypes{idx};

% 根据项目类型选择对应的存储类列表
switch project
    case 'XCU'
        if strcmp(portType, 'Input')
            ScSigList = ScSigInXCUs;
        else
            ScSigList = ScSigOutXCUs;
        end
        ScParamList = ScParamXCUs;
    case 'PCMU'
        if strcmp(portType, 'Input')
            ScSigList = ScSigInPCMUs;
        else
            ScSigList = ScSigOutPCMUs;
        end
        ScParamList = ScParamPCMUs;
    case 'VCU'
        if strcmp(portType, 'Input')
            ScSigList = ScSigInVCUs;
        else
            ScSigList = ScSigOutVCUs;
        end
        ScParamList = ScParamVCUs;
    case 'CUSTOM'
        if strcmp(portType, 'Input')
            ScSigList = userDefedSigInStroage;
        else
            ScSigList = userDefedSigOutStroage;
        end
        ScParamList = userDefedParamStroage;
end

% 返回存储类信息
ScSig = ScSigList{idx};
ScParam = ScParamList{idx};

end