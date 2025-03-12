function names = findDCMNamesChanges(filepath1, filepath2)
%%
    % 目的: 解析DCM文件
    % 输入：
    %       filepath： DCM 文件路径
    % 返回： DCM 各种数据类型结构体
    % 范例： names = findDCMNamesChanges('HY11_PCMU_Tm_J1_V2140912_Change.DCM', 'HY11_PCMU_Tm_J1_V2140912_Change2.DCM')
    % 作者： Blue.ge
    % 日期： 20240910
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器

    addParameter(p,'mode','setdiff');      % setdiff, union

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    mode = p.Results.mode;


    mode = 'union'
    filepath1 = 'HY11_PCMU_Tm_J1_0925_change_LIYANG.DCM'
    filepath2 = 'HY11_PCMU_Tm_J1_V2150925_Change0925.DCM'

    names1 = findDCMNames(filepath1);
    names2 = findDCMNames(filepath2);
    if strcmp(mode,'setdiff')
        names = setdiff(names2,names1)
    elseif strcmp(mode,'union')
        names = union(names2,names1)
    else
        error('the mode could only be: setdiff or union')
    end

end
