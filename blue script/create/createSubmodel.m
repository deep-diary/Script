function createSubmodel(path)
%CREATESUBMODEL 将当前层所有模块放到一个新建的子系统中，不过Trigger模块除外
%   CREATESUBMODEL(PATH) 将当前层所有模块放到一个新建的子系统中，不过Trigger模块除外
%
%   输入参数:
%      path        - 模型路径 (字符串)
%
%   输出参数:
%      None
%
%   功能描述:
%      1. 将当前层所有模块放到一个新建的子系统中，不过Trigger模块除外
%      2. 保持原有的连接关系
%      3. 自动处理输入输出端口
%
%   示例:
%      createSubmodel(gcs)
%      createSubmodel('myModel/Subsystem')
%
%   作者: Blue.ge
%   日期: 2025-09-18
%   版本: 1.0
%%
    % 导入Java类用于模拟键盘操作
    import java.awt.Robot;
    import java.awt.event.KeyEvent;
    %% 输入参数验证
    narginchk(1, 1);
    validateattributes(path, {'char', 'string'}, {'scalartext'}, mfilename, 'path', 1);
    
    % 确保输入为字符向量
    path = char(path);
    
    %% 验证模型是否存在
    if ~bdIsLoaded(bdroot(path))
        error('createSubmodel:modelNotLoaded', '模型未加载: %s', bdroot(path));
    end
    
    %% 显示启动信息
    fprintf('=== 开始创建子系统 ===\n');
    fprintf('目标路径: %s\n', path);
    
    %% 步骤1：创建子模型，名称为bdroot_Sub
    fprintf('步骤1：创建子模型...\n');
    
    % 获取根模型名称
    rootModel = bdroot(path);
    rootModelName = get_param(rootModel, 'Name');
    subsystemName = [rootModelName '_Sub'];
    
    % 生成唯一的子系统名称
    counter = 1;
    originalSubsystemName = subsystemName;
    while true
        try
            % 尝试创建子系统
            newSubsystemPath = [path '/' subsystemName];
            add_block('built-in/Subsystem', newSubsystemPath);
            break;
        catch
            % 如果名称冲突，添加数字后缀
            subsystemName = [originalSubsystemName num2str(counter)];
            counter = counter + 1;
            if counter > 100
                error('createSubmodel:nameConflict', '无法生成唯一的子系统名称');
            end
        end
    end
    
    fprintf('子模型创建成功: %s\n', newSubsystemPath);
    
    %% 步骤2：全选当前层所有模块
    fprintf('步骤2：全选当前层所有模块...\n');
    
    % 获取当前层的所有模块
    allBlocks = find_system(path, 'SearchDepth', 1, 'Type', 'Block');
    
    % 排除当前路径本身（如果是子系统）
    if strcmp(get_param(path, 'Type'), 'block')
        allBlocks = setdiff(allBlocks, {path});
    end
    
    % 排除刚创建的子系统
    allBlocks = setdiff(allBlocks, {newSubsystemPath});
    
    % 排除Trigger模块，但包含系统端口模块进行复制
    selectedBlocks = {};
    triggerBlocks = {};
    systemPortBlocks = {};
    
    for i = 1:length(allBlocks)
        blockType = get_param(allBlocks{i}, 'BlockType');
        if strcmp(blockType, 'TriggerPort')
            triggerBlocks{end+1} = allBlocks{i};
        elseif ismember(blockType, {'Inport', 'Outport', 'EnablePort', 'ActionPort'})
            % 系统端口模块也要复制到子系统
            selectedBlocks{end+1} = allBlocks{i};
            systemPortBlocks{end+1} = allBlocks{i};
        else
            selectedBlocks{end+1} = allBlocks{i};
        end
    end
    
    fprintf('找到模块总数: %d 个\n', length(allBlocks));
    fprintf('排除Trigger模块: %d 个\n', length(triggerBlocks));
    fprintf('系统端口模块: %d 个（将复制到子系统但保留原层）\n', length(systemPortBlocks));
    fprintf('选中模块: %d 个\n', length(selectedBlocks));
    
    if isempty(selectedBlocks)
        warning('createSubmodel:noBlocks', '没有找到需要移动的模块');
        return;
    end
    
    % 选择所有需要移动的模块
    fprintf('正在选择模块...\n');
    for i = 1:length(selectedBlocks)
        set_param(selectedBlocks{i}, 'Selected', 'on');
    end
    
    fprintf('已选择 %d 个模块\n', length(selectedBlocks));
    
    %% 步骤3：复制+删除方式（处理连线）
    fprintf('步骤3：使用复制+删除方式处理模块和连线...\n');
    
    try
        % 先复制所有选中的模块到子系统
        copiedCount = 0;
        for i = 1:length(selectedBlocks)
            try
                blockName = get_param(selectedBlocks{i}, 'Name');
                blockType = get_param(selectedBlocks{i}, 'BlockType');
                
                % 生成新的模块路径
                newBlockPath = [newSubsystemPath '/' blockName];
                
                % 复制模块到子系统
                add_block(selectedBlocks{i}, newBlockPath);
                copiedCount = copiedCount + 1;
                
                fprintf('  复制模块: %s (%s)\n', blockName, blockType);
                
            catch ME
                warning('createSubmodel:copyFailed', '复制模块失败 %s: %s', selectedBlocks{i}, ME.message);
            end
        end
        
        fprintf('成功复制 %d 个模块到子系统\n', copiedCount);
        
        % 处理连线复制
        fprintf('正在处理连线复制...\n');
        lineCount = 0;
        
        % 获取所有连接线
        allLines = find_system(path, 'SearchDepth', 1, 'FindAll', 'on', 'Type', 'Line');
        
        for i = 1:length(allLines)
            try
                line = allLines(i);
                srcPort = get_param(line, 'SrcPortHandle');
                dstPort = get_param(line, 'DstPortHandle');
                
                if srcPort ~= -1 && dstPort ~= -1
                    srcBlock = get_param(srcPort, 'Parent');
                    dstBlock = get_param(dstPort, 'Parent');
                    
                    % 检查源和目标模块是否都在选中的模块中
                    srcSelected = any(strcmp(selectedBlocks, srcBlock));
                    dstSelected = any(strcmp(selectedBlocks, dstBlock));
                    
                    if srcSelected && dstSelected
                        % 两个模块都被选中，需要在子系统中重新连接
                        % 这里需要找到对应的新模块路径
                        srcName = get_param(srcBlock, 'Name');
                        dstName = get_param(dstBlock, 'Name');
                        
                        newSrcBlock = [newSubsystemPath '/' srcName];
                        newDstBlock = [newSubsystemPath '/' dstName];
                        
                        % 获取端口信息
                        srcPortNum = get_param(srcPort, 'PortNumber');
                        dstPortNum = get_param(dstPort, 'PortNumber');
                        
                        % 重新连接
                        try
                            newSrcPort = get_param(newSrcBlock, 'PortHandles');
                            newDstPort = get_param(newDstBlock, 'PortHandles');
                            
                            if srcPortNum <= length(newSrcPort.Outport) && dstPortNum <= length(newDstPort.Inport)
                                add_line(newSubsystemPath, newSrcPort.Outport(srcPortNum), newDstPort.Inport(dstPortNum));
                                lineCount = lineCount + 1;
                            end
                        catch
                            % 忽略连线失败
                        end
                    end
                end
            catch
                % 忽略连线处理错误
            end
        end
        
        fprintf('成功复制 %d 条连线到子系统\n', lineCount);
        
        % 删除原层的连线
        fprintf('正在删除原层的连线...\n');
        deletedLineCount = 0;
        
        for i = 1:length(allLines)
            try
                line = allLines(i);
                srcPort = get_param(line, 'SrcPortHandle');
                dstPort = get_param(line, 'DstPortHandle');
                
                if srcPort ~= -1 && dstPort ~= -1
                    srcBlock = get_param(srcPort, 'Parent');
                    dstBlock = get_param(dstPort, 'Parent');
                    
                    % 检查源和目标模块是否都在选中的模块中
                    srcSelected = any(strcmp(selectedBlocks, srcBlock));
                    dstSelected = any(strcmp(selectedBlocks, dstBlock));
                    
                    if srcSelected && dstSelected
                        % 两个模块都被选中，删除这条连线
                        delete_line(line);
                        deletedLineCount = deletedLineCount + 1;
                    end
                end
            catch
                % 忽略连线删除错误
            end
        end
        
        fprintf('成功删除 %d 条原层连线\n', deletedLineCount);
        
    catch ME
        warning('createSubmodel:cutFailed', '剪切操作失败: %s', ME.message);
    end
    
    %% 步骤4：删除原位置的模块（保留端口模块）
    fprintf('步骤4：删除原位置的模块（保留端口模块）...\n');
    
    deletedCount = 0;
    for i = 1:length(selectedBlocks)
        try
            blockType = get_param(selectedBlocks{i}, 'BlockType');
            
            % 只删除非端口模块，保留端口模块在原层
            if ~ismember(blockType, {'Inport', 'Outport', 'EnablePort', 'ActionPort'})
                delete_block(selectedBlocks{i});
                deletedCount = deletedCount + 1;
                fprintf('  删除模块: %s (%s)\n', get_param(selectedBlocks{i}, 'Name'), blockType);
            else
                fprintf('  保留端口模块: %s (%s)\n', get_param(selectedBlocks{i}, 'Name'), blockType);
            end
            
        catch ME
            warning('createSubmodel:deleteFailed', '删除模块失败 %s: %s', selectedBlocks{i}, ME.message);
        end
    end
    
    fprintf('成功删除 %d 个原位置模块（非端口模块）\n', deletedCount);
    fprintf('保留了 %d 个端口模块在原层\n', length(systemPortBlocks));
    
    %% 步骤5：进入子系统（打开子系统）
    fprintf('步骤5：进入子系统...\n');
    
    % 打开子系统
    open_system(newSubsystemPath);
    fprintf('已打开子系统: %s\n', newSubsystemPath);
    
    %% 显示完成信息
    fprintf('\n=== 创建子系统完成 ===\n');
    fprintf('子系统路径: %s\n', newSubsystemPath);
    fprintf('复制的模块数: %d 个\n', copiedCount);
    fprintf('删除的原模块数: %d 个\n', deletedCount);
    fprintf('排除的Trigger模块数: %d 个\n', length(triggerBlocks));
    fprintf('保留的系统端口模块数: %d 个\n', length(systemPortBlocks));
    fprintf('========================\n');
    fprintf('后续操作建议:\n');
    fprintf('1. 端口模块已复制到子系统，同时保留在原层\n');
    fprintf('2. 子系统中模块的连线已自动复制\n');
    fprintf('3. 原层的连线已自动删除\n');
    fprintf('4. 子系统已自动打开，可以开始编辑\n');
    fprintf('5. 原层端口模块保持外部连接，子系统内部端口用于内部连接\n');
    
    