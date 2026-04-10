function slddParamFlow = findParamFlow2Rpm(path)
%%
% 目的: 找到Flow2Rpm模块对应的标定量
% 输入：
%       path，模块路径
% 返回：所有的变量名
% 范例：alddParamFlow = findParamFlow2Rpm(path)
% 作者： Blue.ge
% 日期： 20240202
%%
    % 根据path判断该模块是否是Lookup_n-D， 如果不是，则直接返回
%     path=gcb; % for test only
    h = get_param(path, 'Handle');
    bk = get(h);

    %% 获取参数
    BlwHeatLevel_sw = bk.BlwHeatLevel_sw;
    BlwHeatLevel_db = bk.BlwHeatLevel_db;
    FFBlw1 = bk.FFBlw1;
    FFBlw3 = bk.FFBlw3;
    FFBlw5 = bk.FFBlw5;
    FFBlw7 = bk.FFBlw7;
    FFBlw9 = bk.FFBlw9;
    FFBlw1_X = bk.FFBlw1_X;
    FFBlw3_X = bk.FFBlw3_X;
    FFBlw5_X = bk.FFBlw5_X;
    FFBlw7_X = bk.FFBlw7_X;
    FFBlw9_X = bk.FFBlw9_X;
    FFBlw1_Y = bk.FFBlw1_Y;
    FFBlw3_Y = bk.FFBlw3_Y;
    FFBlw5_Y = bk.FFBlw5_Y;
    FFBlw7_Y = bk.FFBlw7_Y;
    FFBlw9_Y = bk.FFBlw9_Y;

    %% 尝试获取工作空间中的变量
%     try
% 
%         paramValue = evalin('base', BlwHeatLevel_sw);
%         paramValue = evalin('base', BlwHeatLevel_db);
%         paramValue = evalin('base', FFBlw1);
%         paramValue = evalin('base', FFBlw3);
%         paramValue = evalin('base', FFBlw5);
%         paramValue = evalin('base', FFBlw7);
%         paramValue = evalin('base', FFBlw9);
% 
%         paramValue = evalin('base', FFBlw1_X);
%         paramValue = evalin('base', FFBlw3_X);
%         paramValue = evalin('base', FFBlw5_X);
%         paramValue = evalin('base', FFBlw7_X);
%         paramValue = evalin('base', FFBlw9_X);
% 
%         paramValue = evalin('base', FFBlw1_Y);
%         paramValue = evalin('base', FFBlw3_Y);
%         paramValue = evalin('base', FFBlw5_Y);
%         paramValue = evalin('base', FFBlw7_Y);
%         paramValue = evalin('base', FFBlw9_Y);
% 
%     catch
%         % 如果参数不存在或发生其他错误，将会在这里处理
%         disp('参数不存在或发生错误');
%     end
    slddParamFlow = {BlwHeatLevel_sw, BlwHeatLevel_db, ...
        FFBlw1, FFBlw3,FFBlw5,FFBlw7,FFBlw9,...
        FFBlw1_X, FFBlw3_X,FFBlw5_X,FFBlw7_X,FFBlw9_X,...
        FFBlw1_Y, FFBlw3_Y,FFBlw5_Y,FFBlw7_Y,FFBlw9_Y};
    
end


