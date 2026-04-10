function names = findDCMNames(filepath)
%FINDDCMNAMES 提取DCM文件中的所有参数名称
%   NAMES = FINDDCMNAMES(FILEPATH) 从指定的DCM文件中提取所有参数名称
%
%   输入参数:
%      filepath     - DCM文件的完整路径
%
%   输出参数:
%      names        - 包含所有参数名称的列向量元胞数组
%
%   示例:
%      paramNames = findDCMNames('HY11_PCMU_Tm_OTA3_V6030303_Change.DCM');
%      disp(paramNames);  % 显示所有参数名称
%
%   参见: FINDDCMPARAM, FINDDCMNAMESCHANGES
%
%   作者: Blue.ge
%   版本: 2.0
%   日期: 20250320

    % 检查文件是否存在
    if ~exist(filepath, 'file')
        error('文件不存在: %s', filepath);
    end
    
    % 解析DCM文件获取参数
    try
        paramsArr = findDCMParam(filepath);
    catch ME
        error('解析DCM文件时出错: %s', ME.message);
    end
    
    % 提取所有参数名称
    names = {};
    for i = 1:length(paramsArr)
        param = paramsArr{i};
        if ~isempty(param)
            for j = 1:length(param)
                names{end+1, 1} = param(j).name;
            end
        end
    end
end





