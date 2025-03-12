function changeRefModUpdate(varargin)
%%
    % 目的: 如果子模型进行了变更，比如端口数量等，需要重新加载下
    % 输入：
    %        pos： 新位置起始点 
    % 返回： newPos: 模型新位置
    % 范例： changeRefModUpdate('model',{})
    % 状态： 这个用于不太属于改变，后续尝试归于创建模块中
    % 作者： Blue.ge
    % 日期： 20231113
    %%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'model',{});      % 设置变量名和默认参数
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    model = p.Results.model;

    %% 子模型名称及位置
    subMods = {
        'TmRefriModeMgr','TmColtModeMgr','TmHvchCtrl',...   % 远飞
        'TmComprCtrl','TmRefriVlvCtrl','TmSovCtrl',...      % Blue
        'TmSigProces','TmPumpCtrl','TmColtVlvCtrl','TmEnergyMgr'...  % 江敏
        'TmDiag','TmAfCtrl'                                 % 冬清
        };
    %% 获取子模型位置信息
    stpX = 1500;
    stpY = 2500;
    posOrg=[0 0 500 5000];
    row = 2;
    col = length(subMods)/2;
    root = gcs;
    subPos = {};
    for i=1:row
        for j=1:col
            pos=posOrg+[stpX * (j), stpY * (i-1), stpX * (j),  stpY * (i-1)];
            subPos = [subPos, pos];
        end
    end

    %% 更新子模型
    for i=1:length(model)
        name = model{i};
        [~, idx]=find(strcmp(subMods, 'TmComprCtrl') ==1);
        pos = subPos{idx};
        path = [root '/' name];
        bk = add_block('built-in/ModelReference', path, ...
         'ModelName', name, 'Position', pos);  
        changeModPos(path, pos(1:2))
        createModGoto(path, 'mode','both');
    end
end