function [PathAll, ParamAll] = findParameters(path)
%FINDPARAMETERS 查找模型中所有的标定量
%   [PathAll, ParamAll] = findParameters(path) 查找指定路径下模型中所有的标定量，
%   包括常量、1维表、2维表等。
%
%   输入参数:
%       path - 模型路径，可以是模型名称或路径字符串
%
%   输出参数:
%       PathAll - 所有标定量的路径
%       ParamAll - 所有标定量的名称
%
%   示例:
%       [PathAll, ParamAll] = findParameters(bdroot)
%       [PathAll, ParamAll] = findParameters(gcs)
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2023-10-27
%   版本: 1.1

    % 初始化输出变量
    PathAll = {};
    ParamAll = {};
    
    try
        % 检查输入参数
        if nargin < 1
            error('必须提供模型路径作为输入参数');
        end
        
%         % 检查模型是否已加载
%         if ~bdIsLoaded(path)
%             error('指定的模型未加载');
%         end
        
        % 查找常量标定量
        [PathConst, ParamConst] = findParamConstant(path);
        
        % 查找Compare To标定量
        [PathCompTo, ParamCompTo] = findParamCompTo(path);
        
        % 查找table标定量
        [PathLookup1D, PathLookup2D, Param1DLoopUp, Param2DLoopUp] = findParamLookupAll(path);
        
        % 查找ParamFlow2Rpm标定量
        [PathFlow, ParamFlow] = findParamFlow2RpmAll(path);
        
        % 查找Relay标定量
        [PathRelay, ParamRelay] = findParamRelayAll(path);
        
        % 查找Saturate标定量
        [PathSatur, ParamSatur] = findParamSaturateAll(path);
        
        % 查找debug标定量
        [PathDebug, ParamDebug] = findParamDebug(path);
        
        % 查找周期性脉冲标定量
        [PathCnt, ParamCnt] = findParamCnt(path);
        
        % 查找Bias标定量
        [PathBias, ParamBias] = findParamBias(path);
        
        % 合并所有标定量名称
        ParamAll = [ParamConst, ParamCompTo, ...
                   Param1DLoopUp, Param2DLoopUp, ParamFlow, ...
                   ParamRelay, ParamSatur, ParamDebug, ParamCnt, ParamBias];
        ParamAll = unique(ParamAll', 'stable');
        
        % 合并所有路径
        PathAll = [PathConst, PathCompTo, PathLookup1D, PathLookup2D, ...
                  PathFlow, PathRelay, PathSatur, PathDebug, PathCnt, PathBias];
        PathAll = PathAll';
        
    catch ME
        % 错误处理
        error('查找标定量时发生错误: %s', ME.message);
    end
end
