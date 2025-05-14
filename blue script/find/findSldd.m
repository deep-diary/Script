function [fPCMU, fVCU] = findSldd(pathMd)
%FINDSLDD 查找模型中的SLDD数据
%   [fPCMU, fVCU] = findSldd(pathMd) 查找指定模型中的SLDD数据，
%   包括信号和参数，并将结果保存到Excel文件中。
%
%   输入参数:
%       pathMd - 模型路径，可以是模型名称或路径字符串
%
%   输出参数:
%       fPCMU - PCMU输出路径
%       fVCU - VCU输出路径
%
%   示例:
%       [fPCMU, fVCU] = findSldd(bdroot)
%       [fPCMU, fVCU] = findSldd(gcs)
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
        [fPCMU, fVCU] = findSlddSig(pathMd);
        
        % 查找SLDD参数
        [fPCMU, fVCU] = findSlddParam(pathMd);
        
    catch ME
        % 错误处理
        error('查找SLDD数据时发生错误: %s', ME.message);
    end
end
