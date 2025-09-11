function [sigCnts, paramCnts] = findSlddLoad(path, varargin)
%FINDSLDDLOAD 导入SLDD数据到工作空间
%   [sigCnts, paramCnts] = findSlddLoad(path, varargin) 从Excel文件或模型导入SLDD数据
%   到工作空间，支持PCMU和VCU两种模式。
%
%   输入参数:
%       path - SLDD文件路径或模型名称
%       varargin - 可选参数对，包括:
%           'mode' - 模式选择，'PCMU'或'VCU'，默认为'PCMU'
%           'exclude' - 需要排除的模块类型，默认为空
%
%   输出参数:
%       sigCnts - 成功导入的信号数量
%       paramCnts - 成功导入的参数数量
%
%   示例:
%       [sigCnts, paramCnts] = findSlddLoad('TmComprCtrl_DD_PCMU.xlsx')
%       [sigCnts, paramCnts] = findSlddLoad('TmComprCtrl', 'mode', 'PCMU')
%       [sigCnts, paramCnts] = findSlddLoad('TmComprCtrl', 'mode', 'PCMU', 'exclude', {'Input', 'Output'})
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-02-05
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        addParameter(p, 'mode', 'XCU', @(x) any(validatestring(x, {'PCMU', 'VCU', 'XCU'})));
        addParameter(p, 'exclude', {}, @(x) iscell(x) || ischar(x));
        parse(p, varargin{:});
        
        mode = p.Results.mode;
        exclude = p.Results.exclude;
        
        % 确保exclude是元胞数组
        if ischar(exclude)
            exclude = {exclude};
        end
        
        %% 校验路径
        % 检查文件扩展名
        isExcelFile = endsWith(path, '.xls') || endsWith(path, '.xlsx');
        
        if isExcelFile
            fprintf('正在处理Excel文件: %s\n', path);
        else
            fprintf('正在处理模型: %s\n', path);
            path = [path, '_DD_', mode, '.xlsx'];
        end
        
        % 检查文件是否存在
        if isempty(path) || ~(isfile(which(path)) || isfile(path))
            error('文件未包含在项目中，请先将SLDD路径添加到项目中');
        end
        
        %% 确定SLDD类型
        if contains(path, 'PCMU')
            fprintf('检测到PCMU格式的SLDD文件\n');
            mode = 'PCMU';
        elseif contains(path, 'VCU')
            fprintf('检测到VCU格式的SLDD文件\n');
            mode = 'VCU';
        elseif contains(path, 'XCU')
            fprintf('检测到XCU格式的SLDD文件\n');
            mode = 'XCU';
        else
            error('文件名必须包含PCMU或VCU标识');
        end
        
        %% 加载SLDD数据
        switch mode
            case 'PCMU'
                sigCnts = findSlddLoadSigPCMU(path, 'exclude', exclude);
                paramCnts = findSlddLoadParamPCMU(path, 'exclude', exclude);
            case 'VCU'
                sigCnts = findSlddLoadSigVCU(path, 'exclude', exclude);
                paramCnts = findSlddLoadParamVCU(path, 'exclude', exclude);
            case 'XCU'
                sigCnts = findSlddLoadSigXCU(path, 'exclude', exclude);
                paramCnts = findSlddLoadParamXCU(path, 'exclude', exclude);
            otherwise
                error('模式参数必须是PCMU或VCU');
        end
        
        % 输出导入结果
        fprintf('成功导入 %d 个信号和 %d 个参数\n', sigCnts, paramCnts);
        
    catch ME
        % 错误处理
        error('导入SLDD数据时发生错误: %s', ME.message);
    end
end
