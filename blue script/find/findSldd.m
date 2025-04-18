function [SignalPCMU, SignalVCU, ParamPCMU, ParamVCU] = findSldd(pathMd)
%FINDSLDD 查找模型中的SLDD数据
%   [SignalPCMU, SignalVCU, ParamPCMU, ParamVCU] = findSldd(pathMd) 查找指定模型中的SLDD数据，
%   包括信号和参数，并将结果保存到Excel文件中。
%
%   输入参数:
%       pathMd - 模型路径，可以是模型名称或路径字符串
%
%   输出参数:
%       SignalPCMU - PCMU相关的SLDD数据
%       SignalVCU - VCU相关的SLDD数据
%       ParamPCMU - PCMU相关的SLDD数据
%       ParamVCU - VCU相关的SLDD数据
%
%   示例:
%       [SignalPCMU, SignalVCU, ParamPCMU, ParamVCU] = findSldd(bdroot)
%       [SignalPCMU, SignalVCU, ParamPCMU, ParamVCU] = findSldd(gcs)
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2023-10-26
%   版本: 1.1

    
    try
        % 检查输入参数
        if nargin < 1
            error('必须提供模型路径作为输入参数');
        end
        
        % 查找SLDD信号
        [SignalPCMU, SignalVCU] = findSlddSig(pathMd);
        
        % 查找SLDD参数
        [ParamPCMU, ParamVCU] = findSlddParam(pathMd);
        
    catch ME
        % 错误处理
        error('查找SLDD数据时发生错误: %s', ME.message);
    end
end
