function DataPCMU = findSlddDebugTemp(path,varargin)
% 目的: 构建Debug Parameter 表格，便于保存到excel
% 输入：
%       path: 表格路径
% 返回： null
% 范例： DataPCMU = findSlddDebugTemp('Template_Interface.xlsx')
% 作者： Blue.ge
% 日期： 20231026
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    
    addParameter(p,'sheetName',{'Inports Common','Inports Diag','Inports 2F'}); 
    addParameter(p,'mode','inport');      % 设置变量名和默认参数 可选 in, out
    addParameter(p,'modeName','TmIn');      % 设置变量名和默认参数 可选 in, out

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    sheetName = p.Results.sheetName;
    modeName = p.Results.modeName;
    mode = p.Results.mode;

    DataPCMU={};
    DataVCU={};

    % Debug 标定量
    % 1 构建标定量 sldd 数据矩阵
    for i=1:length(sheetName)
        [dataTable,~,~] = readExcelInterface(path, sheetName{i});
        data = findSlddDebugTempData(modeName, dataTable, mode);
        DataPCMU = [DataPCMU;data];
    end

    % 2. 将数据保存到excel中

    % 使用cellfun检查每个单元是否为空
    isEmptyRow = cellfun('isempty', DataPCMU(:, 1)) & cellfun('isempty', DataPCMU(:, 2));
    % 使用逻辑索引删除包含空行的行
    DataPCMU = DataPCMU(~isEmptyRow, :);

    saveSldd(modeName, DataPCMU, DataVCU,'dataType','Parameters');
end