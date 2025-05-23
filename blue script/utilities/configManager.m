function config = configManager(action, varargin)
% 目的: 配置文件管理
% 输入：
%       action: 动作类型
%       varargin: 输入参数
% 返回： config: 配置文件
% 范例： configManager('load')
% 范例： configManager('save', 'param', 'Signals')
% 作者： Blue.ge
% 日期： 20250523
%%
    %% 参数处理
     clc
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'param','');  % 是否需要指定需要加载的参数，如果为空，则加载所有参数
    addParameter(p,'fileName','config.mat');   % 文件名
   
    % 输入参数处理   
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    param = p.Results.param;
    fileName = p.Results.fileName;


end