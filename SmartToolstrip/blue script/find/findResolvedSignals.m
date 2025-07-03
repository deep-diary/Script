function signalHandles = findResolvedSignals(pathMd)
%%
    % 目的: 找到当前模型路径下所有解析过的信号线
    % 输入：
    %       pathMd：当前模型路径
    % 返回： signalHandles： 解析过的信号线句柄，
    % 范例： signalHandles = findResolvedSignals(gcs)
    % 状态： 可以正常使用
    % 作者： Blue.ge
    % 日期： 20231031
%%
    clc

    % 打开模型，但不显示其GUI。如果模型已经打开，这将不会影响其可见性。
    
    % 查找模型中所有的信号线
    lines = find_system(pathMd, 'FindAll', 'on', 'Type', 'Line');

    % 初始化句柄数组
    signalHandles = [];

    % 遍历所有找到的线条
    for i = 1:length(lines)
        h = lines(i);
        if ~get(h).MustResolveToSignalObject
            continue
        end

        % 如果已经被解析
        signalHandles(end+1) = h;
        disp(get(h).Name)
        
    end
end
