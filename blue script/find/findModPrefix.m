function [foldName,prefix] = findModPrefix(mdName, varargin)
%%
% 目的: 根据模型，找到模型所有文件夹前缀编号
% 输入：
%       Null
% 返回：mdName: 模型名
% 范例：[foldName,prefix] = findModPrefix('TmComprCtrl')
% 说明：找到路径中模型的输入输出端口
% 作者： Blue.ge
% 日期： 20231020
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'numList',{'01_','02_','03_','04_','05_','06_','07_','08_','09_','10_','11_','12_','13_'});      % 设置变量名和默认参数
    addParameter(p,'mdList',{'TmSwArch','TmSigProces','TmRefriModeMgr','TmRefriVlvCtrl', ...
        'TmSovCtrl','TmComprCtrl','TmColtModeMgr','TmColtVlvCtrl', ...
        'TmPumpCtrl','TmHvchCtrl','TmAfCtrl','TmEnergyMgr','TmDiag'});      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    numList = p.Results.numList;
    mdList = p.Results.mdList;
    
    %% 查询模型
%     idx = strcmp(mdList,mdName) == 1;
%     prefix = numList{idx};
%     foldName = [prefix mdName];

    %% 遍历模式
    prefix = '';
    foldName = '';
    foldList = dir('SubModel')
    for i=1:length(foldList)
        name = foldList(i).name;
        if contains(name,mdName)
            foldName = name;
            prefix = name(1:3);
            break
        end
    end

end
