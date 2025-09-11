function appAutosar2Ert(mdName)
%APPAUTOSAR2ERT 将AUTOSAR模型转换为ERT模型
%   APPAUTOSAR2ERT(MDNAME) 将AUTOSAR模型转换为ERT模型
%
%   必需参数:
%      mdName       - 模型名称 (字符串)
%
%   可选参数 (名称-值对):
%
%   功能描述:
%      1. 加载并改变模型配置为ERT 配置
%      2. 为根模型的输出信号进行解析
%      3. 将输出信号导出到excel模板中，并根据excel模板加载对应的信号到工作区
%      4. 运行原始初始化函数，加载必要的参数
%      6. 清空代码缓存目录，打开Embedded Coder app，并生成代码
%      7. 保存模型并关闭, 提取代码到指定目录
%
%   示例:
%      % 基本用法
%      appAutosar2Ert('PrkgClimaEgyMgr')
%
%   注意事项:
%      1. 使用前需要确保配置文件存在
%      2. 配置文件应为.mat格式
%      3. 如果CloseModel为true，函数会自动保存并关闭模型
%      4. 如果配置引用已存在，将更新其源文件
%
%   参见: TBD
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20250911

    %% 1. 加载并改变模型配置为ERT 配置
%     mdName = 'PrkgClimaEgyMgr'
    % 如果未提供模型名称，使用默认值进行测试
%     if nargin < 1 || isempty(mdName)
%         mdName = 'PrkgClimaEgyMgr';
%         fprintf('警告: 未提供模型名称，使用默认模型: %s\n', mdName);
%     end
    % 加载配置文件到基础工作区
    ConfigFile = 'Config_Climate';
    % 判断基础工作区是否已存在ConfigFile变量，如果不存在则加载ConfigFile
    if ~evalin('base', sprintf('exist(''%s'', ''var'')', ConfigFile))
        if exist([ConfigFile '.mat'], 'file')
            % 方法1：使用evalin将变量加载到基础工作区
            evalin('base', sprintf('load(''%s'', ''-mat'', ''%s'')', ConfigFile, ConfigFile));
            fprintf('已将配置文件 "%s" 加载到基础工作区。\n', ConfigFile);
        else
            warning('配置文件"%s.mat"未找到！', ConfigFile);
        end
    else
        fprintf('配置文件 "%s" 已存在于基础工作区中。\n', ConfigFile);
    end
    % 加载模型s
    load_system(mdName);
    changeCfgRef(mdName,'ConfigFile',ConfigFile);

    %% 2. 为根模型的输出信号进行解析
    % 找到根路径下的子模型路径，根路径下只有一个子模型
    subModPath = find_system(mdName,'SearchDepth',1,'BlockType','SubSystem');
    createModSig(subModPath{1},'isEnableIn',false,'truncateSignal',true,'resoveValue',true);
    
    %% 3. 将输出信号导出到excel模板中
    % 导出到excel模板中
    outputFile = createSlddSigGee(mdName,'truncateSignal', true);
    % 根据excel模板加载对应的信号到工作区
    findSlddLoadGee(outputFile);
    
    %% 4. 运行原始初始化函数，加载必要的参数
    % 运行PrkgClimaEgyMgr_init.m函数
    mod_init_file = [mdName '_init.m'];
    mod_init_path = which(mod_init_file);
    
    if ~isempty(mod_init_path)
        fprintf('正在运行初始化函数: %s\n', mod_init_path);
        % 在基础工作区中运行初始化函数，确保变量加载到基础工作区
        evalin('base', sprintf('run(''%s'')', mod_init_path));
        fprintf('初始化函数执行完成，变量已加载到基础工作区。\n');
    else
        warning('未找到初始化文件: %s', mod_init_file);
    end
    
    %% 5. 清空代码缓存目录，打开Embedded Coder app，并生成代码
    % 清空代码缓存目录（更简洁写法，使用matlab内置函数）
    code_path = fullfile(pwd, 'Code');
    if exist(code_path, 'dir')
        % rmdir可以直接递归删除整个目录，然后再新建
        rmdir(code_path, 's');
        mkdir(code_path);
        fprintf('已清空代码缓存目录内容: %s\n', code_path);
    end
    % 打开Embedded Coder app
    open_system(mdName);
    % 使用脚本打开Embedded Coder App（暂时无法使用脚本实现，请手动在Simulink工具条点击"Embedded Coder"）
    
end

