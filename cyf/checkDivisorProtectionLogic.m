function checkDivisorProtectionLogic(divideBlock, divisorSrcBlock)
    % 检查除数源是否有防零保护逻辑
    
    divisorSrcType = get_param(divisorSrcBlock, 'BlockType');
    divisorSrcPath = get_param(divisorSrcBlock, 'Parent');
    
    % 检查常见保护模式
    parentBlocks = find_system(divisorSrcPath, 'LookUnderMasks', 'all', ...
        'FollowLinks', 'on', 'SearchDepth', 1);
    
    hasProtection = false;
    
    % 检查附近是否有比较、开关、最小值限制等保护逻辑
    for i = 1:length(parentBlocks)
        blockType = get_param(parentBlocks{i}, 'BlockType');
        
        % 检查常见保护模式
        if strcmp(blockType, 'RelationalOperator')
            op = get_param(parentBlocks{i}, 'Operator');
            if contains(op, '==') || contains(op, '~=')
                fprintf('  发现比较运算符(%s)，可能用于防零保护\n', op);
                hasProtection = true;
            end
        elseif strcmp(blockType, 'Switch')
            fprintf('  发现Switch模块，可能用于防零保护\n');
            hasProtection = true;
        elseif strcmp(blockType, 'MinMax')
            fprintf('  发现MinMax模块，可能用于限制除数最小值\n');
            hasProtection = true;
        elseif strcmp(blockType, 'Saturate')
            fprintf('  发现Saturate模块，可能用于限制除数范围\n');
            hasProtection = true;
        end
    end
    
    if ~hasProtection
        fprintf('  [警告] 没有明显的防除零保护逻辑!\n');
    end
end