function value = findDCMValueByNameCache(paramsArr,name)
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
%      value = findDCMValueByNameCache(paramsArr,'cTmAfCtrl_t_u16DeicingTime')
%
%   参见: FINDDCMPARAM, FINDDCMNAMESCHANGES
%
%   作者: Blue.ge
%   版本: 2.0
%   日期: 20250618

    
    % 提取所有参数名称
    value = '';
    for i = 1:length(paramsArr)
        param = paramsArr{i};
        if ~isempty(param)
            for j = 1:length(param)
                if strcmp(name,param(j).name)
                    value = param(j).wert;
                    return
                end
            end
        end
    end
end





