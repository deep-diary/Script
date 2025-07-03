function changeSlddTableByInitValue(slddPath)
%CHANGESLDDTABLEBYINITVALUE 根据SLDD初始值更新Excel表格
%   CHANGESLDDTABLEBYINITVALUE(SLDDPATH) 根据SLDD数据字典的初始值更新Excel表格
%
%   输入参数:
%      slddPath - SLDD Excel文件路径 (字符串)
%
%   功能描述:
%      1. 读取Excel文件中的Parameters表格
%      2. 根据初始值创建1维查找表
%      3. 根据初始值创建2维查找表
%
%   示例:
%      % 基本用法
%      changeSlddTableByInitValue('TmRefriVlvCtrl_DD_PCMU.xlsx')
%
%   注意事项:
%      1. Excel文件必须包含Parameters表格
%      2. 文件将被直接修改，请确保已备份
%      3. 支持1维和2维查找表的创建
%
%   作者: Blue.ge
%   版本: 1.1
%   日期: 20240802

    %% 参数检查
    if ~exist(slddPath, 'file')
        error('文件不存在: %s', slddPath);
    end

    %% 读取SLDD表格
    try
        % 配置Excel导入选项
        opts = detectImportOptions(slddPath, ...
            'ReadVariableNames', true, ...
            'Sheet', 'Parameters',...
            'VariableNamingRule','preserve');
        
        % 将所有列设置为字符类型
        opts.VariableTypes = repmat({'char'}, 1, length(opts.VariableTypes));
        
        % 读取Parameters表格
        slddTable = readtable(slddPath, opts, ...
            'ReadVariableNames', true, ...
            'Sheet', 'Parameters');
        
        % 只保留前14列
        slddTable = slddTable(:, 1:14);
    catch ME
        error('读取SLDD文件失败: %s', ME.message);
    end

    %% 创建1维查找表
    try
        saveSlddTableByInitValue(slddPath, slddTable, 'dataType', '1D');
    catch ME
        warning(ME.identifier, '创建1维查找表失败: %s', ME.message);
    end

    %% 创建2维查找表
    try
        saveSlddTableByInitValue(slddPath, slddTable, 'dataType', '2D');
    catch ME
        warning(ME.identifier, '创建2维查找表失败: %s', ME.message);
    end
end
