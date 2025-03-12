function  creatTmBase(varargin)
%%
% 目的: 将外部信号转换为base模块的输入信号，1. 信号名的转变； 2. 增加data storage 模块，用于信号隔离
% 输入：
%       NA
% 返回：NA
% 范例：creatTmBase()
% 说明：1. 打开根路径，然后执行此函数
% 作者： Blue.ge
% 日期： 20231030
%%
    clc
    %% 初始化
     clc
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'stpX',1500);  
    addParameter(p,'stpY',2500);      % 设置变量名和默认参数 [9000 0]
    addParameter(p,'posOrg',[0 0 500 5000]);      % 设置变量名和默认参数 [9000 0]
    % 输入参数处理   
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    stpX = p.Results.stpX;
    stpY = p.Results.stpY;
    posOrg = p.Results.posOrg;

    %%
       
    subMods = {
        'TmRefriModeMgr','TmColtModeMgr','TmHvchCtrl',...   % 远飞
        'TmComprCtrl','TmRefriVlvCtrl','TmSovCtrl',...      % Blue
        'TmSigProces','TmPumpCtrl','TmColtVlvCtrl','TmEnergyMgr'...  % 江敏
        'TmDiag','TmAfCtrl'                                 % 冬清
        };
    row = 2;
    col = length(subMods)/2;
    root = gcs;

    %% 获取子模型位置
    subPos = {};
    for i=1:row
        for j=1:col
            pos=posOrg+[stpX * (j), stpY * (i-1), stpX * (j),  stpY * (i-1)];
            subPos = [subPos, pos];
        end
    end
    %% 生成子模型
    for i=1:row
        for j=1:col
            idx = col * (i-1) + j;
            name = subMods{idx};
            path = [root '/' name];
            pos=posOrg+[stpX * (j), stpY * (i-1), stpX * (j),  stpY * (i-1)];
            bk = add_block('built-in/ModelReference', path, ...
             'ModelName', name, 'Position', pos);  
            changeModSize(path)
            createModGoto(path, 'mode','both');  % 创建输入输出端口
        end
    end
end
