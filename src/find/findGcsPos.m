function position = findGcsPos()
%%
% 目的: 让模型铺满窗口，然后找到窗口对应的坐标并返回。
% 输入：
%       Null
% 返回：模型4个点的坐标
% 范例： position = findGcsPos()
% 作者： Blue.ge
% 日期： 20230928
%%
    clc
    set_param(gcs, 'ZoomFactor', 'FitSystem')
    % 获取模型的位置信息
    % 获取当前打开模型的句柄
    modelHandle = get_param(gcs, 'Handle');
    
    % 获取模型中的所有块
    blocks = find_system(gcs, 'SearchDepth', 1, 'Type', 'Block');
    
    % 初始化边界坐标
    leftBoundary = inf;
    topBoundary = inf;
    rightBoundary = -inf;
    bottomBoundary = -inf;
    
    % 遍历所有块并更新边界坐标, 第一个模块，对用的是模型本身，应该去掉
    for i = 2:length(blocks)
        blockHandle = get_param(blocks{i}, 'Handle');
        blockPosition = get_param(blockHandle, 'Position');
        
        leftBoundary = min(leftBoundary, blockPosition(1));
        topBoundary = min(topBoundary, blockPosition(2));
        rightBoundary = max(rightBoundary, blockPosition(3));
        bottomBoundary = max(bottomBoundary, blockPosition(4));
    end
    
    % 显示边界坐标
    fprintf('最左边坐标：(%f, %f)\n', leftBoundary, topBoundary);
    fprintf('最右边坐标：(%f, %f)\n', rightBoundary, bottomBoundary);
    position=[leftBoundary,topBoundary,rightBoundary,bottomBoundary];

end
