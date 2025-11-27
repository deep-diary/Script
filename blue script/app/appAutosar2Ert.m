function [success, errorMsg, codePaths, summary] = appAutosar2Ert(varargin)
%APPAUTOSAR2ERT 将AUTOSAR模型转换为ERT模型
%
%   [SUCCESS, ERRORMSG, CODEPATHS, SUMMARY] = APPAUTOSAR2ERT() 从当前目录的模型文件中自动提取模型名称并转换为ERT模型
%   [SUCCESS, ERRORMSG, CODEPATHS, SUMMARY] = APPAUTOSAR2ERT(Name, Value) 
%   使用一个或多个名称-值对参数指定转换选项。
%
%   说明:
%       函数会自动从当前目录的.slx文件中提取模型名称。当前目录应包含一个或两个模型文件。
%       如果存在以"_lib.slx"结尾的库文件，将提取主模型名称；否则从普通模型文件名中提取。
%
%   Name-Value Arguments:
%       'AutosarMode' - AUTOSAR信号名解析模式，指定为字符向量或字符串标量
%                      可选值: 'prefixHalf', 'deleteTail', 'halfTail', 'justHalf', 'modelHalf'
%                      默认值: 'prefixHalf'
%       'Combine'     - 是否合并所有代码文件到同一目录，指定为逻辑标量
%                       true: 合并到同一目录（默认）
%                       false: 保持原有目录结构
%
%   OUTPUTS:
%       SUCCESS      - 转换是否成功，返回为逻辑标量
%       ERRORMSG     - 错误信息，返回为字符向量（成功时为空）
%       CODEPATHS    - 代码文件路径信息，返回为结构体
%                      CODEPATHS.root - 代码根目录路径
%                      CODEPATHS.c    - C文件目录路径
%                      CODEPATHS.h    - H文件目录路径
%                      CODEPATHS.a2l  - A2L文件目录路径
%       SUMMARY      - 代码生成摘要，返回为结构体
%                      SUMMARY.modelName  - 模型名称
%                      SUMMARY.totalFiles - 总文件数
%                      SUMMARY.fileTypes  - 文件类型列表
%                      SUMMARY.fileCounts - 各类型文件数量
%                      SUMMARY.success    - 代码生成是否成功
%
%   PROCESS STEPS:
%       1. 初始化项目路径和配置
%       2. 加载相关文件
%       3. 更改模型配置
%       4. 为模型添加一层壳并对所有信号插入Signal Conversion模块（TODO）
%       5. 创建模型的输入输出信号解析
%       6. 导出解析信号到Excel模板
%       7. 更改原始枚举变量定义
%       8. 运行初始化函数导入相关变量
%       9. 导入Excel模板中的接口信号解析
%       10. 更改原始变量的头文件定义（包含仿真）
%       11. 生成代码
%       12. 提取代码到指定目录
%
%   EXAMPLES:
%       % 基本用法（从当前目录自动提取模型名称）
%       [success, errorMsg, codePaths, summary] = appAutosar2Ert();
%       
%       % 使用不同的AUTOSAR模式和合并设置
%       [success, errorMsg, codePaths, summary] = appAutosar2Ert( ...
%           'AutosarMode', 'prefixHalf', 'Combine', true, 'prefixName', 'Smart');
%       
%       % 检查结果
%       if success
%           fprintf('转换成功！\n');
%           fprintf('代码根目录: %s\n', codePaths.root);
%           fprintf('总文件数: %d\n', summary.totalFiles);
%       else
%           fprintf('转换失败: %s\n', errorMsg);
%       end
%
%   NOTES:
%       - 使用前需要确保配置文件存在
%       - 配置文件应为.mat格式
%       - 函数具有完整的错误处理，不会因单个步骤失败而崩溃
%       - 如果配置引用已存在，将更新其源文件
%       - 当前目录应包含一个或两个.slx模型文件
%
%   See also: SLBUILD, LOAD_SYSTEM, FINDSYSTEM
%
%   Author: Blue.ge (葛维冬 @ Smart)
%   Version: 2.1
%   Date: 2025-11-26

    %% 初始化和输入验证
    success = false;
    errorMsg = '';
    codePaths = struct();
    summary = struct();
    
    %% 从文件名提取模型名称
    try
        % 获取当前目录下的模型文件
        modelFiles = dir('*.slx');
        modelCount = length(modelFiles);
        
        if modelCount == 0
            errorMsg = '当前目录下未找到.slx模型文件';
            fprintf('错误: %s\n', errorMsg);
            return;
        elseif modelCount > 2
            errorMsg = sprintf('当前目录下找到 %d 个模型文件，正常只能有一个或两个模型文件，请检查模型路径', modelCount);
            fprintf('错误: %s\n', errorMsg);
            return;
        end
        
        % 提取模型名称
        % 优先查找库文件来确定主模型名称
        mdName = '';
        libFileFound = false;
        
        for i = 1:modelCount
            modelName = modelFiles(i).name;
            if endsWith(modelName, '_lib.slx')
                % 如果找到库文件，提取主模型名称
                mdName = modelName(1:end-8);
                libFileFound = true;
                break;
            end
        end
        
        % 如果没有找到库文件，从普通模型文件名中提取
        if ~libFileFound
            for i = 1:modelCount
                modelName = modelFiles(i).name;
                if ~endsWith(modelName, '_lib.slx')
                    % 从普通模型文件名中提取（去掉.slx扩展名）
                    mdName = modelName(1:end-4);
                    break;
                end
            end
        end
        
        if isempty(mdName)
            errorMsg = '无法从文件名中提取模型名称';
            fprintf('错误: %s\n', errorMsg);
            return;
        end
        
        % 验证模型文件是否存在（检查当前目录）
        if ~exist([mdName '.slx'], 'file')
            errorMsg = sprintf('模型文件 "%s.slx" 不存在于当前目录', mdName);
            fprintf('错误: %s\n', errorMsg);
            return;
        end
        
    catch ME
        errorMsg = sprintf('提取模型名称失败: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end
    
    %% 解析可选参数
    p = inputParser;
    p.FunctionName = mfilename;
    
    validModes = {'prefixHalf', 'deleteTail', 'halfTail', 'justHalf', 'modelHalf'};
    addParameter(p, 'enSigResolve', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'AutosarMode', 'deleteTail', @(x) any(validatestring(x, validModes)));
    addParameter(p, 'Combine', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'prefixName', 'CcmIF', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    
    parse(p, varargin{:});
    autosarMode = p.Results.AutosarMode;
    combine = p.Results.Combine;
    enSigResolve = p.Results.enSigResolve;
    prefixName = char(p.Results.prefixName);
    
    fprintf('========================================\n');
    fprintf('    开始AUTOSAR到ERT转换\n');
    fprintf('========================================\n');
    fprintf('模型名称: %s\n', mdName);
    fprintf('当前工作目录: %s\n', pwd);
    fprintf('AUTOSAR模式: %s\n', autosarMode);
    fprintf('合并模式: %s\n', mat2str(combine));
    fprintf('----------------------------------------\n');
    
    %% 1. 初始化配置
    try
        fprintf('步骤1: 初始化配置...\n');
        fprintf('  模型名称: %s\n', mdName);
        fprintf('  模型路径: %s\n', pwd);
        
    catch ME
        errorMsg = sprintf('步骤1失败 - 初始化配置: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end
    
    %% 2. 加载配置文件
    try
        fprintf('步骤2: 加载相关文件...\n');
        
        % 加载配置文件到基础工作区
        ConfigFile = 'Config_Climate';
        
        % 判断基础工作区是否已存在ConfigFile变量，如果不存在则加载ConfigFile
        if ~evalin('base', sprintf('exist(''%s'', ''var'')', ConfigFile))
            if exist([ConfigFile '.mat'], 'file')
                % 使用evalin将变量加载到基础工作区
                evalin('base', sprintf('load(''%s'', ''-mat'', ''%s'')', ConfigFile, ConfigFile));
                fprintf('  已将配置文件 "%s" 加载到基础工作区\n', ConfigFile);
            else
                error('  配置文件"%s.mat"未找到！', ConfigFile);
            end
        else
            fprintf('  配置文件 "%s" 已存在于基础工作区中\n', ConfigFile);
        end

        % 加载模型
        load_system(mdName);
        fprintf('  模型 "%s" 加载成功\n', mdName);
        
    catch ME
        errorMsg = sprintf('步骤2失败 - 加载配置文件: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end
    
    %% 3. 更改配置
    try
        fprintf('步骤3: 更改配置...\n');
            
        % 更改配置引用
        changeCfgRef(mdName,'ConfigFile',ConfigFile);
        % 更改代码映射属性
        changeCfgErtCcm(mdName);

        fprintf('  配置更改完成\n');
        
    catch ME
        errorMsg = sprintf('步骤3失败 - 更改配置: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end

    %% 4. 为模型添加一层壳并对所有信号插入Signal Conversion模块（TODO）
    try
        fprintf('步骤4: 为模型添加一层壳并对所有信号插入Signal Conversion模块（TODO）...\n');
        
    catch ME
        errorMsg = sprintf('步骤4失败 - 为模型添加一层壳并对所有信号插入Signal Conversion模块（TODO）: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end

    %% 5. 创建模型的输入输出信号解析
    try
        fprintf('步骤5: 创建模型的输入输出信号解析...\n');
        
        % 找到根路径下的子模型路径，根路径下只有一个子模型
        subModPath = find_system(mdName,'SearchDepth',1,'BlockType','SubSystem');
        
        if isempty(subModPath)
            errorMsg = sprintf('在模型 "%s" 中未找到子模型', mdName);
            fprintf('错误: %s\n', errorMsg);
            return;
        end
        
        fprintf('  找到子模型: %s\n', subModPath{1});
        
        % 创建模型信号
        % createModSig(subModPath{1},'isEnableIn',true,'resoveValue',true,'autosarMode',autosarMode); % 基于模型信号
        changeLinesPortAttr(mdName,...
            'enableIn',enSigResolve,...
            'enableOut',enSigResolve,...
            'resoveValue',true,...
            'autosarMode',autosarMode,...
            'prefixName', prefixName); % 基于端口信号
        fprintf('  信号解析完成\n');
        
    catch ME
        errorMsg = sprintf('步骤5失败 - 解析输出信号: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end
    
    %% 6. 导出解析信号到excel 模板
    try
        fprintf('步骤6: 导出信号到Excel模板...\n');
        
        % 导出到excel模板中
        outputFile = createSlddSigGee(mdName,...
            'autosarMode',autosarMode,...
            'prefixName', prefixName,...
            'ignoreInput',~enSigResolve,...
            'ignoreOutput',~enSigResolve);
        
        if isempty(outputFile)
            errorMsg = 'Excel文件导出失败';
            fprintf('错误: %s\n', errorMsg);
            return;
        end
        
        fprintf('  Excel文件导出成功: %s\n', outputFile);
        
    catch ME
        errorMsg = sprintf('步骤6失败 - 导出信号到Excel: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end

    %% 7. 更改原始枚举变量定义
    try
        fprintf('步骤7: 更改原始枚举变量定义...\n');
        enumFile = [mdName '_defineIntEnumTypes.m'];
        delText = "'HeaderFile', 'Rte_Type.h'";
        
        % 更改原始枚举变量定义
        [numDeleted, success] = delFileTargetLine(enumFile, delText, ...
            'Overwrite', true, 'CreateBackup', false);
        
        if success
            fprintf('  已删除 %d 行包含 "%s" 的内容\n', numDeleted, delText);
        else
            warning('  删除操作失败或未找到匹配内容');
        end
        
        fprintf('  原始枚举变量定义更改完成\n');


    catch ME
        errorMsg = sprintf('步骤7失败 - 更改原始枚举变量定义: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end

    %% 8. 运行初始化函数
    try
        fprintf('步骤8: 运行初始化函数...\n');
        
        % 运行初始化函数
        mod_init_file = [mdName '_init.m'];
        mod_init_path = which(mod_init_file);
        
        if ~isempty(mod_init_path)
            fprintf('  正在运行初始化函数: %s\n', mod_init_path);
            % 在基础工作区中运行初始化函数，确保变量加载到基础工作区
            evalin('base', sprintf('run(''%s'')', mod_init_path));
            fprintf('  初始化函数执行完成，变量已加载到基础工作区\n');
        else
            warning('  未找到初始化文件: %s', mod_init_file);
            fprintf('  跳过初始化函数执行\n');
        end
        
    catch ME
        errorMsg = sprintf('步骤8失败 - 运行初始化函数: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end

    %% 9. 导入excel 模板中的接口信号解析
    try
        fprintf('步骤9: 导入excel 模板中的接口信号解析...\n');
        
        % 根据excel模板加载对应的信号到工作区
        findSlddLoadGee(outputFile);
        fprintf('  信号加载到工作区完成\n');
        
    catch ME
        errorMsg = sprintf('步骤9失败 - 导入excel 模板中的接口信号解析: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end

    %% 10. 更改原始变量的头文件定义（包含仿真）
    try
        fprintf('步骤10: 更改原始变量的头文件定义...\n');
        
        % 首先检查模型编译状态
        fprintf('  检查模型编译状态...\n');
        % 尝试获取模型变量来检查编译状态
        testVars = Simulink.findVars(mdName, 'IncludeEnumTypes', true);
        fprintf('  模型编译状态正常，找到 %d 个变量\n', length(testVars));
        
        % 更改原始变量的头文件定义
        changeHeaderFile();
        fprintf('  原始变量的头文件定义更改完成\n');
        
    catch ME
        % 提供更详细的错误信息
        fprintf('\n========================================\n');
        fprintf('    步骤10执行失败 - 模型编译错误\n');
        fprintf('========================================\n');
        fprintf('错误信息: %s\n', ME.message);
        fprintf('错误标识符: %s\n', ME.identifier);
        if ~isempty(ME.stack)
            fprintf('错误位置: %s (第 %d 行)\n', ME.stack(1).name, ME.stack(1).line);
        end
        
        % 打开模型并执行仿真，便于查看具体错误
        fprintf('\n正在打开模型并执行仿真以查看具体错误...\n');
        try
            open_system(mdName);
            sim(mdName);
        catch simME
            fprintf('仿真执行失败: %s\n', simME.message);
        end
        
        fprintf('\n建议解决方案:\n');
        fprintf('1. 检查模型中的编译错误和警告\n');
        fprintf('2. 检查输出信号解析，是否不同的信号内部是连接到一起的，从而导致冲突，\n如果是，请使用Signal Conversion 模块进行隔离\n');
        fprintf('========================================\n');
        errorMsg = sprintf('步骤10失败 - 模型编译错误: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end
    
    %% 11.生成代码
    try
        fprintf('步骤11: 生成代码...\n');

        % 生成代码
        slbuild(bdroot,'OpenBuildStatusAutomatically',true);
        fprintf('  代码生成完成\n');
        
    catch ME
        errorMsg = sprintf('步骤11失败 - 生成代码: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end

    %% 12. 提取代码到指定目录
    try
        fprintf('步骤12: 提取代码到指定目录...\n');
        % 生成a2l
        % coder.asap2.export(mdName) % 默认路径是代码生成路径，更改了配置，生成的代码中已经包含a2l文件
        % 提取代码到指定目录
        appCopyCode();
        fprintf('  代码提取完成\n');
        
    catch ME
        errorMsg = sprintf('步骤12失败 - 提取代码: %s', ME.message);
        fprintf('错误: %s\n', errorMsg);
        return;
    end
    
    %% 转换成功完成
    success = true;
    errorMsg = '';
    fprintf('\n========================================\n');
    fprintf('    AUTOSAR到ERT转换成功完成\n');
    fprintf('========================================\n');
    fprintf('模型: %s\n', mdName);
    fprintf('AUTOSAR模式: %s\n', autosarMode);
    fprintf('合并模式: %s\n', mat2str(combine));
    fprintf('所有步骤执行成功！\n');
    fprintf('========================================\n');
    
end

