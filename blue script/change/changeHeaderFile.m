function varargout = changeHeaderFile(varargin)
%CHANGEHEADERFILE 清空工作空间中所有变量的HeaderFile属性
%   CHANGEHEADERFILE() 清空当前工作空间中所有变量的HeaderFile属性
%   CHANGEHEADERFILE('Parameter', Value, ...) 使用指定参数
%
%   输入参数:
%      无必需参数
%
%   可选参数（名值对）:
%      'modelName'     - 指定模型名称，默认使用bdroot
%      'verbose'       - 是否显示详细信息，默认值: true
%      'dryRun'        - 是否只显示将要修改的变量而不实际修改，默认值: false
%      'dataScope'     - 设置DataScope属性，默认值: 'Auto'
%
%   功能描述:
%      1. 遍历工作空间中所有变量
%      2. 检查变量是否有HeaderFile属性
%      3. 将HeaderFile属性设置为空字符串
%      4. 同时修改DataScope属性以避免Imported错误
%      5. 支持参数、信号、枚举类型、Bus对象等所有Simulink对象
%      6. 确保修改后的变量正确保存到工作空间
%      7. 特别处理Simulink枚举类型
%
%   示例:
%      % 基本用法
%      changeHeaderFile()
%
%      % 指定模型并显示详细信息
%      changeHeaderFile('modelName', 'MyModel', 'verbose', true)
%
%      % 预览模式，不实际修改
%      changeHeaderFile('dryRun', true)
%
%      % 设置DataScope为Auto
%      changeHeaderFile('dataScope', 'Auto')
%
%   注意事项:
%      1. 使用前需要确保模型已打开
%      2. 修改会立即生效，建议先备份
%      3. 只处理有HeaderFile属性的变量
%      4. 支持所有Simulink对象类型
%      5. 修改后的变量会正确保存到工作空间
%      6. 枚举类型需要重新定义来修改HeaderFile属性
%      7. 同时修改DataScope属性以避免Imported错误
%
%   作者: Blue.ge
%   版本: 1.7
%   日期: 2024-12-19

    %% 参数解析
    p = inputParser;
    addParameter(p, 'modelName', bdroot, @ischar);
    addParameter(p, 'verbose', true, @islogical);
    addParameter(p, 'dryRun', false, @islogical);
    addParameter(p, 'dataScope', 'Auto', @ischar);
    
    parse(p, varargin{:});
    
    modelName = p.Results.modelName;
    verbose = p.Results.verbose;
    dryRun = p.Results.dryRun;
    dataScope = p.Results.dataScope;

    %% 验证模型
    if ~bdIsLoaded(modelName)
        error('模型 %s 未加载', modelName);
    end

    if verbose
        fprintf('开始处理模型 %s 的HeaderFile属性\n', modelName);
        fprintf('DataScope将设置为: %s\n', dataScope);
        if dryRun
            fprintf('*** 预览模式：不会实际修改任何属性 ***\n');
        end
    end

    %% 获取工作空间中的所有变量
    try
        % 获取基础工作空间中的所有变量
        baseVars = evalin('base', 'who');
        
        % 获取模型使用的变量（包括数据字典中的变量）
        usedVars = Simulink.findVars(modelName, 'IncludeEnumTypes', true);
        
        % 合并所有变量名
        allVarNames = unique([baseVars; {usedVars.Name}']);
        
        if verbose
            fprintf('找到 %d 个变量需要检查\n', length(allVarNames));
        end
        
    catch ME
        error('获取变量列表时发生错误: %s', ME.message);
    end

    %% 处理每个变量
    modifiedCount = 0;
    errorCount = 0;
    modifiedVars = {}; % 记录修改的变量名
    
    for i = 1:length(allVarNames)
        varName = allVarNames{i};
        
        try
            % 获取变量对象
            if ismember(varName, baseVars)
                varObj = evalin('base', varName);
                isBaseVar = true;
            else
                % 从数据字典中获取
                dataDictPath = get_param(modelName, 'DataDictionary');
                if ~isempty(dataDictPath)
                    dictObj = Simulink.data.dictionary.open(dataDictPath);
                    varObj = getVariable(dictObj, varName);
                    isBaseVar = false;
                else
                    continue;
                end
            end
            
            % 检查是否有HeaderFile属性
            if isprop(varObj, 'HeaderFile')
                currentHeaderFile = get(varObj, 'HeaderFile');
                currentDataScope = '';
                if isprop(varObj, 'DataScope')
                    currentDataScope = get(varObj, 'DataScope');
                end
                
                % 如果HeaderFile不为空，或者DataScope为Imported，则需要修改
                if ~isempty(currentHeaderFile) || strcmp(currentDataScope, 'Imported')
                    if verbose
                        if ~isempty(currentHeaderFile) && strcmp(currentDataScope, 'Imported')
                            fprintf('变量 %s: HeaderFile = "%s", DataScope = "%s" -> HeaderFile = "", DataScope = "%s"\n', ...
                                varName, currentHeaderFile, currentDataScope, dataScope);
                        elseif ~isempty(currentHeaderFile)
                            fprintf('变量 %s: HeaderFile = "%s" -> ""\n', varName, currentHeaderFile);
                        elseif strcmp(currentDataScope, 'Imported')
                            fprintf('变量 %s: DataScope = "%s" -> "%s"\n', varName, currentDataScope, dataScope);
                        end
                    end
                    
                    if ~dryRun
                        % 根据对象类型使用不同的方法设置属性，并返回修改后的对象
                        [success, modifiedVarObj] = setHeaderFileProperty(varObj, varName, dataScope, verbose);
                        if success
                            modifiedCount = modifiedCount + 1;
                            modifiedVars{end+1} = varName; % 记录修改的变量
                            
                            % 如果是基础工作空间变量，需要重新赋值到工作空间
                            if isBaseVar
                                % 使用更可靠的方法更新工作空间变量
                                try
                                    % 先清除原变量
                                    evalin('base', ['clear ' varName]);
                                    % 重新赋值修改后的对象
                                    assignin('base', varName, modifiedVarObj);
                                    
                                    % 验证修改是否成功
                                    verifyObj = evalin('base', varName);
                                    if isprop(verifyObj, 'HeaderFile')
                                        verifyHeaderFile = get(verifyObj, 'HeaderFile');
                                        verifyDataScope = '';
                                        if isprop(verifyObj, 'DataScope')
                                            verifyDataScope = get(verifyObj, 'DataScope');
                                        end
                                        
                                        if isempty(verifyHeaderFile) && (~strcmp(verifyDataScope, 'Imported') || strcmp(verifyDataScope, dataScope))
                                            if verbose
                                                fprintf('  ✓ 已成功更新基础工作空间中的变量 %s\n', varName);
                                            end
                                        else
                                            if verbose
                                                fprintf('  ✗ 变量 %s 更新失败，HeaderFile = "%s", DataScope = "%s"\n', ...
                                                    varName, verifyHeaderFile, verifyDataScope);
                                            end
                                        end
                                    end
                                catch ME
                                    if verbose
                                        warning(ME.identifier, '更新变量 %s 到工作空间时发生错误: %s', varName, ME.message);
                                    end
                                end
                            end
                        else
                            errorCount = errorCount + 1;
                        end
                    else
                        modifiedCount = modifiedCount + 1;
                    end
                elseif verbose
                    fprintf('变量 %s: HeaderFile 已为空，DataScope 已为 %s，跳过\n', varName, currentDataScope);
                end
            elseif verbose
                fprintf('变量 %s: 无HeaderFile属性，跳过\n', varName);
            end
            
        catch ME
            errorCount = errorCount + 1;
            if verbose
                warning('处理变量 %s 时发生错误: %s', varName, ME.message);
            end
        end
    end

    %% 处理枚举类型
    % if ~dryRun
    %     try
    %         enumModifiedCount = processEnumTypes(modelName, verbose);
    %         modifiedCount = modifiedCount + enumModifiedCount;
    %     catch ME
    %         if verbose
    %             warning(ME.identifier, '处理枚举类型时发生错误: %s', ME.message);
    %         end
    %     end
    % end

    %% 保存更改
    if ~dryRun && modifiedCount > 0
        try
            % 如果有数据字典，保存数据字典
            dataDictPath = get_param(modelName, 'DataDictionary');
            if ~isempty(dataDictPath)
                dictObj = Simulink.data.dictionary.open(dataDictPath);
                saveChanges(dictObj);
                if verbose
                    fprintf('数据字典已保存\n');
                end
            end
            
            % 保存模型
            save_system(modelName);
            if verbose
                fprintf('模型已保存\n');
            end
            
            % 显示修改的变量列表
            if verbose && ~isempty(modifiedVars)
                fprintf('\n已修改的变量列表:\n');
                for j = 1:length(modifiedVars)
                    fprintf('  - %s\n', modifiedVars{j});
                end
            end
            
        catch ME
            warning(ME.identifier, '保存更改时发生错误: %s', ME.message);
        end
    end

    %% 输出结果
    if verbose
        fprintf('\n=== 处理完成 ===\n');
        if dryRun
            fprintf('预览模式：将修改 %d 个变量\n', modifiedCount);
        else
            fprintf('已修改 %d 个变量的HeaderFile属性\n', modifiedCount);
        end
        if errorCount > 0
            fprintf('处理过程中发生 %d 个错误\n', errorCount);
        end
    end

    %% 返回结果
    if nargout > 0
        varargout{1} = modifiedCount;
    end
    if nargout > 1
        varargout{2} = errorCount;
    end
    if nargout > 2
        varargout{3} = modifiedVars;
    end
end

%% 辅助函数：根据对象类型设置HeaderFile属性
function [success, modifiedVarObj] = setHeaderFileProperty(varObj, varName, dataScope, verbose)
%SETHEADERFILEPROPERTY 根据对象类型设置HeaderFile属性
%   使用MATLAB官方推荐的方法设置不同Simulink对象的HeaderFile属性
%   返回修改后的对象

    success = false;
    modifiedVarObj = varObj; % 默认返回原对象
    
    try
        % 获取对象类型
        objClass = class(varObj);
        
        switch objClass
            case {'Simulink.Bus', 'Simulink.AliasType', 'Simulink.NumericType'}
                % 对于Bus、AliasType、NumericType对象，使用点号语法
                varObj.HeaderFile = '';
                if isprop(varObj, 'DataScope')
                    varObj.DataScope = dataScope;
                end
                modifiedVarObj = varObj; % 返回修改后的对象
                success = true;
                
            case {'Simulink.Parameter', 'Simulink.Signal'}
                % 对于Parameter、Signal对象，使用set函数
                set(varObj, 'HeaderFile', '');
                if isprop(varObj, 'DataScope')
                    set(varObj, 'DataScope', dataScope);
                end
                modifiedVarObj = varObj; % 返回修改后的对象
                success = true;
                
            case {'Simulink.ValueType'}
                % 对于ValueType对象，使用点号语法
                varObj.HeaderFile = '';
                if isprop(varObj, 'DataScope')
                    varObj.DataScope = dataScope;
                end
                modifiedVarObj = varObj; % 返回修改后的对象
                success = true;
                
            otherwise
                % 对于其他类型，尝试使用点号语法
                try
                    varObj.HeaderFile = '';
                    if isprop(varObj, 'DataScope')
                        varObj.DataScope = dataScope;
                    end
                    modifiedVarObj = varObj; % 返回修改后的对象
                    success = true;
                catch
                    % 如果点号语法失败，尝试set函数
                    try
                        set(varObj, 'HeaderFile', '');
                        if isprop(varObj, 'DataScope')
                            set(varObj, 'DataScope', dataScope);
                        end
                        modifiedVarObj = varObj; % 返回修改后的对象
                        success = true;
                    catch
                        if verbose
                            warning('变量 %s (类型: %s) 不支持HeaderFile属性修改', varName, objClass);
                        end
                    end
                end
        end
        
    catch ME
        if verbose
            warning(ME.identifier, '设置变量 %s 的HeaderFile属性时发生错误: %s', varName, ME.message);
        end
    end
end
