function [numGoto, numFrom] = createGotoUseless(varargin)
%CREATEGOTOUSELESS 为无用的Goto和From模块创建匹配模块
%   [numGoto, numFrom] = createGotoUseless() 为模型中未匹配的Goto和From模块
%   创建对应的匹配模块，并连接到Ground或Terminator。
%
%   可选参数:
%       'posGotoBase' - Goto模块的起始位置，默认为[12500,0]
%       'posFromBase' - From模块的起始位置，默认为[12000,0]
%       'step' - 模块之间的垂直间距，默认为30
%       'createGoto' - 是否创建Goto模块，默认为true
%       'createFrom' - 是否创建From模块，默认为true
%
%   输出参数:
%       numGoto - 创建的Goto模块数量
%       numFrom - 创建的From模块数量
%
%   示例:
%       [numGoto, numFrom] = createGotoUseless()
%       [numGoto, numFrom] = createGotoUseless('posGotoBase', [14000,0], 'step', 40)
%       [numGoto, numFrom] = createGotoUseless('createGoto', false) % 只创建From模块
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-06-28
%   版本: 1.0

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'posGotoBase', [2500,0], @(x) isnumeric(x) && numel(x) == 2);
        addParameter(p, 'posFromBase', [2000,0], @(x) isnumeric(x) && numel(x) == 2);
        addParameter(p, 'step', 30, @isnumeric);
        addParameter(p, 'createGoto', true, @islogical);
        addParameter(p, 'createFrom', true, @islogical);
        addParameter(p, 'path', gcs);
        
        parse(p, varargin{:});
        
        % 获取参数值
        posGotoBase = p.Results.posGotoBase;
        posFromBase = p.Results.posFromBase;
        step = p.Results.step;
        createGoto = p.Results.createGoto;
        createFrom = p.Results.createFrom;
        path = p.Results.path;

        %% 确认goto from 位置
        pos = findGcsPos();
        posGotoBase = [pos(3) + 200,pos(2)];          
        posFromBase = [pos(3) + 1000, pos(2)];     
        
        %% 创建Goto模块
        numGoto = 0;
        if createGoto
            try
                fprintf('开始创建Goto模块...\n');
                numGoto = creatGotoBasedOnUselessFrom('path',path,'posBase', posGotoBase, 'step', step);
                fprintf('成功创建 %d 个Goto模块\n', numGoto);
            catch ME
                warning(ME.identifier, '创建Goto模块时发生错误: %s', ME.message);
            end
        end
        
        %% 创建From模块
        numFrom = 0;
        if createFrom
            try
                fprintf('开始创建From模块...\n');
                numFrom = creatFromBasedOnUselessGoto('path',path,'posBase', posFromBase, 'step', step);
                fprintf('成功创建 %d 个From模块\n', numFrom);
            catch ME
                warning(ME.identifier, '创建From模块时发生错误: %s', ME.message);
            end
        end
        
        %% 显示总结信息
        if createGoto && createFrom
            fprintf('完成创建，共创建 %d 个Goto模块和 %d 个From模块\n', numGoto, numFrom);
        elseif createGoto
            fprintf('完成创建，共创建 %d 个Goto模块\n', numGoto);
        elseif createFrom
            fprintf('完成创建，共创建 %d 个From模块\n', numFrom);
        end
        
    catch ME
        error('创建模块过程中发生错误: %s', ME.message);
    end
end 