function value = findSlddExcelValueByName(path, paramName)
%FINDSLDDEXCELVALUE 根据名字，找到对应sldd表格中的值
%
%   输入参数:
%       path - SLDD文件路径或模型名称
%       paramName - 参数名:
%
%   输出参数:
%       value - 根据名称找到的值
%
%   示例:
%       value = findSlddExcelValueByName('TmSovCtrl_DD_XCU.xlsx','cTmSovCtrl_t_s32CmprOffDly')
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2025-06-18
%   版本: 1.0

    try
        %% 输入参数处理
        dataTable = readSldd(path,'sheet','Parameters');
        idx = dataTable.Name == paramName;
        data = dataTable(idx,:);
        value = data.IniValue;
        
    catch ME
        % 错误处理
        error('findSlddExcelValue时发生错误: %s', ME.message);
    end
end
