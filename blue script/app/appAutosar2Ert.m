function [success, errorMsg, codePaths, summary] = appAutosar2Ert(mdName, varargin)
%APPAUTOSAR2ERT 将AUTOSAR模型转换为ERT模型
%   [SUCCESS, ERRORMSG, CODEPATHS, SUMMARY] = APPAUTOSAR2ERT(MDNAME) 将AUTOSAR模型转换为ERT模型
%   [SUCCESS, ERRORMSG, CODEPATHS, SUMMARY] = APPAUTOSAR2ERT(MDNAME, 'Parameter', Value, ...) 使用指定参数转换模型
%
%   输入参数:
%      mdName       - 模型名称 (字符串)
%
%   可选参数（名值对）:
%      'autosarMode' - AUTOSAR信号名解析模式，可选值: 'deleteTail', 'halfTail', 'justHalf', 'modelHalf'
%                      默认值: 'modelHalf'
%      'combine'     - 是否合并所有代码文件到同一目录，默认值: true
%
%   输出参数:
%      success      - 转换是否成功 (逻辑值)
%      errorMsg     - 错误信息 (字符串，如果成功则为空)
%      codePaths    - 代码文件路径信息 (结构体)
%                     codePaths.root - 代码根目录路径
%                     codePaths.c    - C文件目录路径
%                     codePaths.h    - H文件目录路径
%                     codePaths.a2l  - A2L文件目录路径
%      summary      - 代码生成摘要 (结构体)
%                     summary.modelName  - 模型名称
%                     summary.totalFiles - 总文件数
%                     summary.fileTypes  - 文件类型列表
%                     summary.fileCounts - 各类型文件数量
%                     summary.success    - 代码生成是否成功
%
%   功能描述:
%      1. 加载并改变模型配置为ERT 配置
%      2. 为根模型的输出信号进行解析
%      3. 将输出信号导出到excel模板中，并根据excel模板加载对应的信号到工作区
%      4. 运行原始初始化函数，加载必要的参数
%      5. 清空仿真和代码缓存目录
%      6. 仿真原始模型
%      7. 生成代码
%      8. 提取代码到指定目录
%
%   示例:
%      % 基本用法
%      [success, errorMsg, codePaths, summary] = appAutosar2Ert('PrkgClimaEgyMgr')
%      
%      % 使用不同的AUTOSAR模式和合并设置
%      [success, errorMsg, codePaths, summary] = appAutosar2Ert('PrkgClimaEgyMgr', 'autosarMode', 'halfTail', 'combine', false)
%      
%      % 检查结果
%      if success
%          fprintf('转换成功！\n');
%          fprintf('代码根目录: %s\n', codePaths.root);
%          fprintf('总文件数: %d\n', summary.totalFiles);
%      else
%          fprintf('转换失败: %s\n', errorMsg);
%      end
%
%   注意事项:
%      1. 使用前需要确保配置文件存在
%      2. 配置文件应为.mat格式
%      3. 函数具有完整的错误处理，不会因单个步骤失败而崩溃
%      4. 如果配置引用已存在，将更新其源文件
%
%   参见: TBD
%
%   作者: Blue.ge
%   版本: 2.0
%   日期: 20250911

    %% 初始化和输入验证
    success = false;
    errorMsg = '';
    codePaths = struct();
    summary = struct();
    
    % 输入参数验证
    if nargin < 1 || isempty(mdName)
        errorMsg = '模型名称不能为空';
        return;
    end
    
    % 确保输入为字符向量
    if isstring(mdName)
        mdName = char(mdName);
    end
    
    % 验证模型是否存在
    if isempty(which(mdName))
        errorMsg = sprintf('模型 "%s" 不存在或未在MATLAB路径中', mdName);
        return;
    end
    
    %% 解析可选参数
    p = inputParser;
    p.FunctionName = mfilename;
    
    validModes = {'deleteTail', 'halfTail', 'justHalf', 'modelHalf'};
    addParameter(p, 'autosarMode', 'modelHalf', @(x) any(validatestring(x, validModes)));
    addParameter(p, 'combine', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    parse(p, varargin{:});
    autosarMode = p.Results.autosarMode;
    combine = p.Results.combine;
    
    fprintf('=== 开始AUTOSAR到ERT转换 ===\n');
    fprintf('模型名称: %s\n', mdName);
    fprintf('AUTOSAR模式: %s\n', autosarMode);
    fprintf('合并模式: %s\n', mat2str(combine));
    
    %% 1. 初始化项目路径和配置
    try
        fprintf('步骤1: 初始化项目路径和配置...\n');
        
        % 获取项目路径
        proj = currentProject; 
        rootPath = proj.RootFolder;
        subPath = fullfile(rootPath,'SubModel');
        % codePath = fullfile(rootPath,'CodeGen');
        % simPath = fullfile(rootPath,'Sim');
        codePath = proj.SimulinkCodeGenFolder;
        simPath = proj.SimulinkCacheFolder;

        
        % 验证必要路径
        if ~exist(subPath, 'dir')
            errorMsg = sprintf('子模型路径不存在: %s', subPath);
            return;
        end
        
        fprintf('  项目根路径: %s\n', rootPath);
        fprintf('  子模型路径: %s\n', subPath);
        fprintf('  代码生成路径: %s\n', codePath);
        
    catch ME
        errorMsg = sprintf('步骤1失败 - 初始化项目路径: %s', ME.message);
        return;
    end
    
    %% 2. 加载配置文件
    try
        fprintf('步骤2: 加载配置文件...\n');
        
        % 加载配置文件到基础工作区
        ConfigFile = 'Config_Climate';
        
        % 判断基础工作区是否已存在ConfigFile变量，如果不存在则加载ConfigFile
        if ~evalin('base', sprintf('exist(''%s'', ''var'')', ConfigFile))
            if exist([ConfigFile '.mat'], 'file')
                % 使用evalin将变量加载到基础工作区
                evalin('base', sprintf('load(''%s'', ''-mat'', ''%s'')', ConfigFile, ConfigFile));
                fprintf('  已将配置文件 "%s" 加载到基础工作区\n', ConfigFile);
            else
                warning('  配置文件"%s.mat"未找到！', ConfigFile);
            end
        else
            fprintf('  配置文件 "%s" 已存在于基础工作区中\n', ConfigFile);
        end
        
    catch ME
        errorMsg = sprintf('步骤2失败 - 加载配置文件: %s', ME.message);
        return;
    end
    
    %% 3. 加载模型并更改配置
    try
        fprintf('步骤3: 加载模型并更改配置...\n');
        
        % 加载模型
        load_system(mdName);
        fprintf('  模型 "%s" 加载成功\n', mdName);
        
        % 更改配置引用
        changeCfgRef(mdName,'ConfigFile',ConfigFile);
        fprintf('  配置引用更改完成\n');
        
    catch ME
        errorMsg = sprintf('步骤3失败 - 加载模型并更改配置: %s', ME.message);
        return;
    end

    %% 4. 解析根模型的输出信号
    try
        fprintf('步骤4: 解析根模型的输出信号...\n');
        
        % 找到根路径下的子模型路径，根路径下只有一个子模型
        subModPath = find_system(mdName,'SearchDepth',1,'BlockType','SubSystem');
        
        if isempty(subModPath)
            errorMsg = sprintf('在模型 "%s" 中未找到子模型', mdName);
            return;
        end
        
        fprintf('  找到子模型: %s\n', subModPath{1});
        
        % 创建模型信号
        createModSig(subModPath{1},'isEnableIn',false,'resoveValue',true,'autosarMode',autosarMode);
        fprintf('  信号解析完成\n');
        
    catch ME
        errorMsg = sprintf('步骤4失败 - 解析输出信号: %s', ME.message);
        return;
    end
    
    %% 5. 导出信号到Excel模板
    try
        fprintf('步骤5: 导出信号到Excel模板...\n');
        
        % 导出到excel模板中
        outputFile = createSlddSigGee(mdName,'autosarMode',autosarMode);
        
        if isempty(outputFile)
            errorMsg = 'Excel文件导出失败';
            return;
        end
        
        fprintf('  Excel文件导出成功: %s\n', outputFile);
        
        % 根据excel模板加载对应的信号到工作区
        findSlddLoadGee(outputFile);
        fprintf('  信号加载到工作区完成\n');
        
    catch ME
        errorMsg = sprintf('步骤5失败 - 导出信号到Excel: %s', ME.message);
        return;
    end
    
    %% 6. 运行初始化函数
    try
        fprintf('步骤6: 运行初始化函数...\n');
        
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
        errorMsg = sprintf('步骤6失败 - 运行初始化函数: %s', ME.message);
        return;
    end

    %% 7. 清空仿真和代码缓存目录
    try
        fprintf('步骤7: 清空仿真和代码缓存目录...\n');
        
        % 清空仿真缓存目录
        if exist(simPath, 'dir')
            rmdir(simPath, 's');
            mkdir(simPath);
            fprintf('  已清空仿真缓存目录内容: %s\n', simPath);
        else
            mkdir(simPath);
            fprintf('  创建仿真缓存目录: %s\n', simPath);
        end
        
        % 清空代码缓存目录
        if exist(codePath, 'dir')
            rmdir(codePath, 's');
            mkdir(codePath);
            fprintf('  已清空代码缓存目录内容: %s\n', codePath);
        else
            mkdir(codePath);
            fprintf('  创建代码缓存目录: %s\n', codePath);
        end
        
    catch ME
        errorMsg = sprintf('步骤7失败 - 清空缓存目录: %s', ME.message);
        return;
    end

    %% 8. 仿真原始模型
    try
        fprintf('步骤8: 仿真原始模型...\n');
        
        % 仿真原始模型
        sim(mdName);
        fprintf('  仿真原始模型完成: %s\n', mdName);
        
    catch ME
        errorMsg = sprintf('步骤8失败 - 仿真原始模型: %s', ME.message);
        return;
    end
    
    %% 9. 生成代码
    try
        fprintf('步骤9: 生成代码...\n');
        
        % 生成代码
        slbuild(bdroot,'OpenBuildStatusAutomatically',true);
        fprintf('  代码生成完成\n');
        
    catch ME
        errorMsg = sprintf('步骤9失败 - 生成代码: %s', ME.message);
        return;
    end

    %% 10. 提取代码到指定目录
    try
        fprintf('步骤10: 提取代码到指定目录...\n');
        
        % 提取代码到指定目录
        [codePaths, summary] = createCodeMod(mdName,'type','ert', 'combine', combine);
        fprintf('  代码提取完成\n');
        fprintf('  代码根目录: %s\n', codePaths.root);
        fprintf('  总文件数: %d\n', summary.totalFiles);
        
    catch ME
        errorMsg = sprintf('步骤10失败 - 提取代码: %s', ME.message);
        return;
    end
    
    %% 转换成功完成
    success = true;
    errorMsg = '';
    fprintf('\n=== AUTOSAR到ERT转换成功完成 ===\n');
    fprintf('模型: %s\n', mdName);
    fprintf('AUTOSAR模式: %s\n', autosarMode);
    fprintf('合并模式: %s\n', mat2str(combine));
    fprintf('代码根目录: %s\n', codePaths.root);
    fprintf('总文件数: %d\n', summary.totalFiles);
    fprintf('所有步骤执行成功！\n');
    fprintf('================================\n');
    
end

