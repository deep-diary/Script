function outPath = changeArchSldd(dcmPath, slddPath, varargin)
%CHANGEARCHSLDD 根据DCM数据更新SLDD文件中的参数值
%   OUTPATH = CHANGEARCHSLDD(DCMPATH, SLDDPATH) 使用默认参数更新SLDD文件
%   OUTPATH = CHANGEARCHSLDD(DCMPATH, SLDDPATH, 'Parameter', Value, ...) 使用指定参数更新
%
%   输入参数:
%      dcmPath      - DCM文件路径 (字符串)
%      slddPath     - SLDD文件路径 (字符串)
%
%   可选参数（名值对）:
%      'Sheet'      - Excel表格名称, 默认值: 'Parameters'
%
%   输出参数:
%      outPath      - 更新后的SLDD文件路径 (字符串)
%
%   功能描述:
%      1. 读取SLDD文件中的参数表格
%      2. 从DCM文件中提取参数值
%      3. 更新SLDD文件中的参数初始值
%      4. 保存更新后的SLDD文件
%      5. 创建1D和2D参数表格
%
%   示例:
%      % 基本用法
%      outPath = changeArchSldd('HY11_PCMU_Tm_OTA3_V6050327_All.DCM', 'PCMU_SLDD_All.xlsx')
%
%      % 指定表格名称
%      outPath = changeArchSldd('HY11_PCMU_Tm_OTA3_V6050327_All.DCM', ...
%          'PCMU_SLDD_All.xlsx', 'Sheet', 'MyParameters')
%
%   注意事项:
%      1. DCM文件必须包含有效的参数定义
%      2. SLDD文件必须包含正确的表格结构
%      3. 参数类型支持: const, axis, wert, tab, map
%      4. 更新后的文件会覆盖原文件
%
%   参见: FINDDCMPARAM, CHANGESLDDINITVALUE, SAVESLDDTABLEBYINITVALUE
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20240124

    %% 参数解析
    p = inputParser;
    addParameter(p, 'Sheet', 'Parameters');
    parse(p, varargin{:});
    Sheet = p.Results.Sheet;

    %% 读取sldd
    % 配置Excel导入选项
    opts = detectImportOptions(slddPath, 'ReadVariableNames', true, 'Sheet', Sheet);
    for j=1:length(opts.VariableTypes)
        opts.VariableTypes{j} = 'char';
    end
    
    % 读取参数表格
    parametersTable = readtable(slddPath, opts, 'ReadVariableNames', true, 'Sheet', Sheet);
    parametersTable = parametersTable(:,1:14);

    %% 读取DCM
    paramsArr = findDCMParam(dcmPath);

    %% 更新sldd
    updatedParametersTable = changeSlddInitValue(parametersTable, ...
        paramsArr,...
        'type', {'const','axis','wert','tab','map'});

    %% 保存sldd
    outPath = which(slddPath);
    writetable(updatedParametersTable, outPath, 'Sheet', Sheet, 'WriteMode', 'overwrite');

    %% 创建1D,2D表格
    saveSlddTableByInitValue(outPath, updatedParametersTable, 'dataType', '1D');
    saveSlddTableByInitValue(outPath, updatedParametersTable, 'dataType', '2D');
end

