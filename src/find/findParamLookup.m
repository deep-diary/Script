function [PathLookup1D, PathLookup2D, ParamLookup1D, ParamLookup2D] = findParamLookup(path)
%%
% 目的: 为lookup table表，根据 Table data 的变量名，创建对应坐标轴的变量名
% 输入：
%       Null
% 返回：所有的变量名
% 范例：[PathLookup1D, PathLookup2D, ParamLookup1D, ParamLookup2D] = findParamLookup(path)
% 作者： Blue.ge
% 日期： 20231027
%%
    % 根据path判断该模块是否是Lookup_n-D， 如果不是，则直接返回
%     path=gcb; % for test only
    h = get_param(path, 'Handle');
    bk = get(h);
    NumberOfTableDimensions = bk.NumberOfTableDimensions;
    tableName = bk.Table;
    % 根据NumberOfTableDimensions属性判断表格维度

%%
    % NumberOfTableDimensions ==1
    % 根据Table属性获取表格数据的变量名tableName, 并且这个变量确实是个变量，则执行如下逻辑
    % 根据tableName, 设置BreakpointsForDimension1 为 tableNameX = [tableName, '_X']
    % 将tableName, tableNameX, tableNameY 添加到ParamLookup1D变量中
    PathLookup1D = {};
    PathLookup2D = {};
    ParamLookup1D = {};
    ParamLookup2D = {};

    if NumberOfTableDimensions == '1' && isvarname(tableName)
        tableNameX = [tableName, '_X'];
        PathLookup1D = {path};
        set_param(h, 'BreakpointsForDimension1', tableNameX)
        set_param(h, 'ExtrapMethod', 'Clip')
        set_param(h, 'BreakpointsForDimension1DataTypeStr', "Inherit: Inherit from 'Breakpoint data'")
        set_param(h, 'TableDataTypeStr', "Inherit: Inherit from 'Table data'")
        set_param(h, 'OutDataTypeStr', "Inherit: Inherit via back propagation")
        set_param(h, 'InputSameDT', "off")

        [X,~] = findTableInputType(path);
        % 根据输入信号，设置tableNameY的数据类型
        try
            % 尝试从 base 工作空间中获取参数
%             paramValue = evalin('base', tableName);
%             paramValue.DataType='auto';
            paramValue = evalin('base', tableNameX);
            paramValue.DataType=X.dataType;
        catch
            % 如果参数不存在或发生其他错误，将会在这里处理
            disp('参数不存在或发生错误');
        end
        ParamLookup1D = [ParamLookup1D, tableName, tableNameX];
    end
    
%%
    % NumberOfTableDimensions ==2
    % 根据Table属性获取表格数据的变量名tableName，并且这个变量确实是个变量，则执行如下逻辑
    % 根据tableName, 设置BreakpointsForDimension1 为 tableNameX = [tableName, '_X']
    % 根据tableName, 设置BreakpointsForDimension2 为 tableNameY = [tableName, '_Y']
    % 将tableName, tableNameX, tableNameY 添加到ParamLookup2D变量中
    % 

    if NumberOfTableDimensions == '2' && isvarname(tableName)
        tableName = bk.Table;
        tableNameX = [tableName, '_X'];
        tableNameY = [tableName, '_Y'];
        PathLookup2D = {path};

        set_param(h, 'BreakpointsForDimension1', tableNameY)
        set_param(h, 'BreakpointsForDimension2', tableNameX)
        set_param(h, 'ExtrapMethod', 'Clip')
        set_param(h, 'BreakpointsForDimension1DataTypeStr', "Inherit: Inherit from 'Breakpoint data'")
        set_param(h, 'BreakpointsForDimension2DataTypeStr', "Inherit: Inherit from 'Breakpoint data'")
        set_param(h, 'TableDataTypeStr', "Inherit: Inherit from 'Table data'")
        set_param(h, 'OutDataTypeStr', "Inherit: Inherit via back propagation")
        set_param(h, 'InputSameDT', "off")
        
        [X,Y] = findTableInputType(path);
        % 根据输入信号，设置tableNameY的数据类型
        % 根据输入信号，设置tableNameX的数据类型
        try
            % 尝试从 base 工作空间中获取参数
%             paramValue = evalin('base', tableName);
%             paramValue.DataType='auto';
            paramValue = evalin('base', tableNameY);
            paramValue.DataType=Y.dataType;
            paramValue = evalin('base', tableNameX);
            paramValue.DataType=X.dataType;
        catch
            % 如果参数不存在或发生其他错误，将会在这里处理
            disp('参数不存在或发生错误');
        end
        ParamLookup2D = [ParamLookup2D, tableName, tableNameX, tableNameY];
    end
    
end


