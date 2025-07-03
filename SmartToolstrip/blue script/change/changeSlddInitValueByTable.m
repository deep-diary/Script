function changeSlddInitValueByTable(slddPath)
%CHANGESLDDINITVALUEBYTABLE 根据Excel表格更新SLDD数据字典的初始值
%   CHANGESLDDINITVALUEBYTABLE(SLDDPATH) 根据指定Excel文件更新SLDD数据字典
%
%   输入参数:
%      slddPath - SLDD Excel文件路径 (字符串)
%
%   功能描述:
%      1. 读取Excel文件中的Parameters表格
%      2. 处理1维查找表数据
%      3. 处理2维查找表数据
%      4. 更新并保存修改后的SLDD文件
%
%   示例:
%      % 基本用法
%      changeSlddInitValueByTable('TmRefriVlvCtrl_DD_PCMU.xlsx')
%
%   注意事项:
%      1. Excel文件必须包含Parameters表格
%      2. 1维查找表数据将更新为[表名]和[表名_X]
%      3. 2维查找表数据将更新为[表名]、[表名_X]和[表名_Y]
%      4. 文件将被直接覆盖，请确保已备份
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
            'Sheet', 'Parameters');
        
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

    %% 处理1维查找表
    try
        [data, X, ~] = findExcel1DLutData(slddPath);
        for i = 1:length(data)
            % 更新数据表
            slddTable = changeSlddInitValueByName(slddTable, ...
                data(i).Name, ...
                mat2str(data(i).Data));
            
            % 更新X轴数据
            slddTable = changeSlddInitValueByName(slddTable, ...
                [data(i).Name '_X'], ...
                mat2str(X(i).Data));
        end
    catch ME
        warning('处理1维查找表时出错: %s', ME.message);
    end

    %% 处理2维查找表
    try
        [data, X, Y, ~] = findExcel2DLutData(slddPath);
        for i = 1:length(data)
            % 更新数据表
            slddTable = changeSlddInitValueByName(slddTable, ...
                data(i).Name, ...
                mat2str(data(i).Data));
            
            % 更新X轴数据
            slddTable = changeSlddInitValueByName(slddTable, ...
                [data(i).Name '_X'], ...
                mat2str(X(i).Data));
            
            % 更新Y轴数据
            slddTable = changeSlddInitValueByName(slddTable, ...
                [data(i).Name '_Y'], ...
                mat2str(Y(i).Data));
        end
    catch ME
        warning('处理2维查找表时出错: %s', ME.message);
    end

    %% 保存更新后的SLDD
    try
        writetable(slddTable, ...
            which(slddPath), ...
            'Sheet', 'Parameters', ...
            'WriteMode', 'overwrite');
    catch ME
        error('保存SLDD文件失败: %s', ME.message);
    end
end
