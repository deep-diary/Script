function createIntegration(softversion,varargin)
%CREATEINTEGRATION 创建并配置 Thermal PCMU 集成环境
%
%   createIntegration(SOFTVERSION) 使用指定的软件版本创建集成环境
%
%   createIntegration(SOFTVERSION,Name,Value) 使用指定的软件版本和名称-值对参数创建集成环境
%
%   输入参数:
%       SOFTVERSION - 软件版本号，字符串类型，例如 '7070416'
%
%   可选名称-值对参数:
%       STAGE - 项目阶段，默认为 '23N7'
%       INTERFACE_VERISON - 接口版本，默认为 'V136'
%       CAL_VERSION - 标定版本，默认为 '666666'
%       DCM_NAME - DCM文件名，默认为 'HY11_PCMU_Tm_OTA3_V6060416_All.DCM'
%       SLDD_NAME - SLDD文件名，默认为 'PCMU_SLDD_All.xlsx'
%       ARCH_NAME - 架构模型名称，默认为 'TmSwArch'
%
%   功能说明:
%       1. 配置集成参数
%       2. 加载SLDD文件
%       3. 配置软件版本
%       4. 配置架构模型
%       5. 加载IDT配置
%       6. 创建架构
%       7. 将base复制到autosar架构模型中
%       8. 清理代码生成目录
%
%   示例:
%       % 使用默认参数创建集成环境
%       createIntegration('7070416')
%
%       % 使用自定义参数创建集成环境
%       createIntegration('7070416', 'STAGE', '23N7', 'INTERFACE_VERISON', 'V136')
%
%   注意事项:
%       - 确保所有必需的文件和目录都存在
%       - 确保有足够的权限访问相关文件
%       - 建议在执行前备份重要文件
%
%   作者: [Blue.ge]
%   创建日期: [2025.4.28]
%   最后修改: [2025.4.28]

    %% 参数处理
    p = inputParser;            % 函数的输入解析器
    addRequired(p, 'softversion', @(x) validateattributes(x, {'char'}, {'nonempty'}));
    addParameter(p,'STAGE','23N7', @(x) validateattributes(x, {'char'}, {'nonempty'}));  
    addParameter(p,'INTERFACE_VERISON','V136', @(x) validateattributes(x, {'char'}, {'nonempty'}));  
    addParameter(p,'CAL_VERSION','666666', @(x) validateattributes(x, {'char'}, {'nonempty'}));  
    addParameter(p,'DCM_NAME','HY11_PCMU_Tm_OTA3_V6060416_All.DCM', @(x) validateattributes(x, {'char'}, {'nonempty'}));  
    addParameter(p,'SLDD_NAME','PCMU_SLDD_All.xlsx', @(x) validateattributes(x, {'char'}, {'nonempty'}));  
    addParameter(p,'ARCH_NAME','TmSwArch', @(x) validateattributes(x, {'char'}, {'nonempty'}));   
   
    % 输入参数处理   
    try
        parse(p,softversion,varargin{:});       % 对输入变量进行解析
    catch ME
        error('参数解析错误: %s', ME.message);
    end

    % 提取参数
    STAGE = p.Results.STAGE;
    INTERFACE_VERISON = p.Results.INTERFACE_VERISON;
    CAL_VERSION = p.Results.CAL_VERSION;
    DCM_NAME = p.Results.DCM_NAME;
    SLDD_NAME = p.Results.SLDD_NAME;
    ARCH_NAME = p.Results.ARCH_NAME;
    SOFT_VERSION = softversion;

    %% 1. 配置集成参数
    ARCH_BASE = ['VcThermal_' STAGE '_' INTERFACE_VERISON '_base_1227.slx'];
    
    %% 2. 加载sldd
    try
        proj = currentProject; 
        rootPath = proj.RootFolder;
        subPath = fullfile(rootPath,'SubModel');
        
        if ~exist(subPath, 'dir')
            error('子模型路径不存在: %s', subPath);
        end
        
        outPath = findSlddCombine(subPath, SLDD_NAME);
        if isempty(outPath)
            error('无法找到SLDD文件: %s', SLDD_NAME);
        end
        % 目的: 根据DCM数据，改变模型sldd
        outPath = changeArchSldd(DCM_NAME, SLDD_NAME);
        findSlddLoad(SLDD_NAME);
    catch ME
        error('SLDD加载失败: %s', ME.message);
    end
    
    %% 3. 配置软件版本
    try
        if ~exist(ARCH_NAME, 'file')
            error('架构模型文件不存在: %s', ARCH_NAME);
        end
        
        open_system(ARCH_NAME);
        set_param('TmSwArch/SoftVersion','Value',SOFT_VERSION);
        
        save_system(ARCH_NAME);
    catch ME
        error('软件版本配置失败: %s', ME.message);
    end
    
    %% 4. 配置架构模型
    try
        changeRefModStat(); % 刷新子模型
        createModBusAll(ARCH_NAME); % 模型信号重新mapping
        changeCfgRefAll();  % 更改子模型配置文件
    catch ME
        error('架构模型配置失败: %s', ME.message);
    end
    
    %% 5. 加载IDT配置
    try
        IDTName = ['VcThermal_IDT_' STAGE '_' INTERFACE_VERISON '.m'];
        IDTPath = ['interface/' STAGE '_' INTERFACE_VERISON '/' IDTName];
        
        if ~exist(IDTName, 'file')
            error('IDT配置文件不存在: %s', IDTPath);
        end
        
        run(IDTName);
    catch ME
        error('IDT配置加载失败: %s', ME.message);
    end
    
    %% 6. 创建架构
    try
        verName = ['VcThermal_' STAGE '_' INTERFACE_VERISON '_' SOFT_VERSION];
        ARCH_PAHT = 'PCMUArch';
        ARCH_TARGET = [verName, '.slx'];
        
        if ~exist(fullfile(ARCH_PAHT,ARCH_BASE), 'file')
            error('基础架构文件不存在: %s', fullfile(ARCH_PAHT,ARCH_BASE));
        end
        
        copyfile(fullfile(ARCH_PAHT,ARCH_BASE), fullfile(ARCH_PAHT,ARCH_TARGET));
        load_system(verName);
        open_system([verName,'/VcThermal_50ms_sys/VcThermal_50ms_sys']);
    catch ME
        error('架构创建失败: %s', ME.message);
    end
    
    %% 7. 将base复制到autosar架构模型中
    try
        creatTmBaseArch('mod','sub');
        save_system(ARCH_NAME);
        close_system(ARCH_NAME);
    catch ME
        error('Autosar架构模型创建失败: %s', ME.message);
    end
    
    %% 8. 清理代码生成目录
    try
        codeFold = 'CodeGen';
        if exist(codeFold, 'dir')
            fLists = dir(codeFold);
            for i=3:length(fLists)
                T = fLists(i);
                path = fullfile(rootPath,codeFold,T.name);
                if T.isdir
                    rmdir(path,'s');
                else
                    delete(path);
                end
            end
        end
    catch ME
        warning(ME.identifier, '代码生成目录清理失败: %s', ME.message);
    end
    
    disp('集成过程完成！');
end

