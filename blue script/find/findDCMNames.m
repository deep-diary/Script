function names = findDCMNames(filepath)
%%
    % 目的: 解析DCM文件
    % 输入：
    %       filepath： DCM 文件路径
    % 返回： DCM 各种数据类型结构体
    % 范例： names = findDCMNames('HY11_PCMU_Tm_OTA2_V5010212_Change.DCM')
    % 作者： Blue.ge
    % 日期： 20240910
%%
    clc
%     paramsArr = findDCMParam('HY11_PCMU_Tm_J1_V2130906_DifferChange.DCM')
    paramsArr = findDCMParam(filepath);
    names = {};
    cnt = 1;
    for i=1:5
        param = paramsArr{i};
        for j=1:length(param)
            names{cnt} = param(j).name;
            cnt = cnt+1;
        end
    end
    names = names';
end





