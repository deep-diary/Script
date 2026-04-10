function [inList, outList] = createPortsGotoUpdateLoop(varargin)
%CREATEPORTSGOTOUPDATELOOP 循环创建From模块对应的Inport和Goto模块
%   [inList, outList] = createPortsGotoUpdateLoop() 当系统使用From方式新增信号后，
%   循环创建对应的Inport和Goto模块，直到根路径。
%
%   可选参数:
%       'path' - 当前路径，默认为gcs
%       'topLev' - 循环结束的模型层，默认为bdroot
%       'resoveValue' - 是否解析信号，默认为true
%
%   输出参数:
%       inList - 创建的输入信号列表
%       outList - 创建的输出信号列表
%
%   示例:
%       [inList, outList] = createPortsGotoUpdateLoop() % 迭代循环一直到顶层
%       [inList, outList] = createPortsGotoUpdateLoop('topLev', 'After')
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2023-11-14
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'path', gcs, @ischar);
        addParameter(p, 'topLev', bdroot, @ischar);
        addParameter(p, 'resoveValue', true, @islogical);
        
        parse(p, varargin{:});
        
        % 获取参数值
        path = p.Results.path;
        topLev = p.Results.topLev;
        resoveValue = p.Results.resoveValue;
        
        %% 循环处理模型层级
        inList = [];
        outList = [];
        modelName = get_param(path, 'Name');
        fprintf('开始处理模型层级:\n');
        
        while ~strcmp(modelName, topLev)
            try
                % 打开并处理当前模型
                open_system(path);
                fprintf('处理模型: %s\n', modelName);
                
                % 更新端口和Goto模块
                [inList, outList] = createPortsGotoUpdate('path', path);
                
                % 获取父模型
                parent = get_param(path, 'Parent');
                modelName = get_param(parent, 'Name');
                
                % 打开并处理父模型
                open_system(parent);
                
                if strcmp(modelName, topLev)
                    % 顶层模型处理
                    fprintf('到达顶层模型 %s，创建端口并解析信号\n', modelName);
                    createModPorts(path, 'mode', 'both');
                    createModSig(path, 'resoveValue', resoveValue);
                else
                    % 中间层级处理
                    fprintf('处理中间层级 %s，创建Goto模块\n', modelName);
                    createModGoto(path, 'mode', 'both');
                end
                
                % 更新路径为父模型
                path = parent;
                
            catch ME
                error('处理模型 %s 时发生错误: %s', modelName, ME.message);
            end
        end
        
        fprintf('模型层级处理完成\n');
        
    catch ME
        error('循环更新端口和Goto模块时发生错误: %s', ME.message);
    end
end

