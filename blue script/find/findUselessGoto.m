function uselessGoto = findUselessGoto(varargin)
%%
% 目的: 找到没有用的Goto模块。
% 输入：
%       None
% 返回：
%       uselessGoto: 无用goto的路径 
% 范例：uselessGoto = findUselessGoto(),
% 说明：
% 作者： Blue.ge
% 日期： 20231031
%%
    % 获取选中的模型
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'path',gcs);      % 默认参数为当前路径
    
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    path = p.Results.path;

    %% 


    fprintf('-----------start deal with checkUselessGoto------------')
    % 指定模型的名称
%     modelName = 'new_model';
  
    % 获取模型中的所有 From 模块
    gotoBlocks = find_system(path, 'SearchDepth',1,'BlockType', 'Goto');
    
    % 遍历 From 模块，检查是否存在对应的 Goto 模块
    uselessGoto={};
    j=1;
    for i = 1:length(gotoBlocks)
        gotoBlock = gotoBlocks{i};
        
        % 获取 From 模块的 GotoTag 属性值
        gotoTag = get_param(gotoBlock, 'GotoTag');
    
        % 对应Goto 模块已经存在
        if ~isempty(find_system(path, 'SearchDepth',1,'GotoTag', gotoTag, 'BlockType', 'From'))
            continue
        end
        uselessGoto{j} = gotoBlock;
        j=j+1;
    end

end