%% 创建CCM AUTOSAR软件架构
%APPCREATECCMARCH 创建完整的CCM AUTOSAR软件架构
%
% 描述:
%   此脚本用于自动化创建CCM AUTOSAR软件架构，包括以下步骤：
%   1. 从Excel模板获取SWC清单及周期属性，创建架构SWC
%   2. 将AUTOSAR模型的端口转换成Bus类型
%   3. 将AUTOSAR SWC链接到对应的Simulink模型
%   4. 为非AUTOSAR SWC创建新的Simulink模型
%   5. 创建架构的输入输出端口
%   6. 自动连接架构中的组件
%   7. 创建Interface Dictionary并为端口配置Bus数据类型
%   8. 导出架构代码及ARXML文件
%
% 功能清单:
%   [x] 获取SWC清单及周期属性并创建架构SWC
%   [x] 将AUTOSAR的模型端口转换成Bus
%   [x] 对AUTOSAR SWC进行链接到模型
%   [x] 对非AUTOSAR SWC创建新模型
%   [x] 创建输入输出端口
%   [x] 自动连线
%   [x] 根据模型，创建架构Interface Dictionary，为每个端口配置Bus数据类型
%   [x] 生成架构代码及ARXML
%
% 作者: Auto-generated
% 日期: 2024

%% 初始化
fprintf('========================================\n');
fprintf('开始创建CCM AUTOSAR软件架构\n');
fprintf('========================================\n\n');
tic;

%% ========================================================================
% 步骤1: 获取SWC清单及周期属性并创建架构SWC
% ========================================================================
fprintf('步骤 1/8: 获取SWC清单及周期属性并创建架构SWC\n');
fprintf('------------------------------------------------\n');

% 配置参数
ArchName = 'CcmArch';
templateFile = 'CCMtaskmappingV2.0.xlsx';

% 从Excel模板创建架构SWC
try
    [Tb_autosarSWC, Tb_ertSWC, ArchModel] = createArchSWC(templateFile, ArchName);
    fprintf('  成功创建架构模型: %s\n', ArchName);
    fprintf('  AUTOSAR SWC数量: %d\n', height(Tb_autosarSWC));
    fprintf('  ERT SWC数量: %d\n', height(Tb_ertSWC));
catch ME
    error('MATLAB:appCreateCcmArch:CreateArchSWCFailed', ...
        '创建架构SWC失败: %s', ME.message);
end

% 获取AUTOSAR组件和ERT组合
autosarSwcs = ArchModel.Components;
numAutosarSwcs = numel(autosarSwcs);
ertComposition = find(ArchModel, 'Composition', 'Name', 'ERT');

fprintf('  完成步骤 1\n\n');

%% ========================================================================
% 步骤2: 将AUTOSAR模型的端口转换成Bus类型
% ========================================================================
fprintf('步骤 2/8: 将AUTOSAR模型的端口转换成Bus类型\n');
fprintf('------------------------------------------------\n');

if numAutosarSwcs > 0
    successCount = 0;
    for iSwc = 1:numAutosarSwcs
        swcName = autosarSwcs(iSwc).Name;
        fprintf('  处理AUTOSAR SWC (%d/%d): %s\n', iSwc, numAutosarSwcs, swcName);
        
        try
            changeAutosarPortToBus(swcName);
            successCount = successCount + 1;
            fprintf('    ✓ 成功转换端口为Bus类型\n');
        catch ME
            warning('MATLAB:appCreateCcmArch:ChangeAutosarPortToBusFailed', ...
                '将AUTOSAR模型 %s 的端口转换成Bus失败: %s', swcName, ME.message);
        end
    end
    fprintf('  完成: 成功转换 %d/%d 个SWC\n', successCount, numAutosarSwcs);
else
    fprintf('  警告: 未找到AUTOSAR SWC\n');
end

fprintf('  完成步骤 2\n\n');

%% ========================================================================
% 步骤3: 将AUTOSAR SWC链接到对应的Simulink模型
% ========================================================================
fprintf('步骤 3/8: 将AUTOSAR SWC链接到对应的Simulink模型\n');
fprintf('------------------------------------------------\n');

if numAutosarSwcs > 0
    successCount = 0;
    for iSwc = 1:numAutosarSwcs
        swcComponent = autosarSwcs(iSwc);
        swcName = swcComponent.Name;
        fprintf('  链接AUTOSAR SWC (%d/%d): %s\n', iSwc, numAutosarSwcs, swcName);
        
        try
            % 检查是否已有引用模型
            if isempty(swcComponent.ReferenceName)
                % 链接到Simulink实现模型并继承其接口
                linkToModel(swcComponent, swcName);
                successCount = successCount + 1;
                fprintf('    ✓ 成功链接到模型: %s\n', swcName);
            else
                fprintf('    → 已有引用模型: %s，跳过\n', swcComponent.ReferenceName);
                successCount = successCount + 1;
            end
        catch ME
            warning('MATLAB:appCreateCcmArch:LinkToModelFailed', ...
                '链接AUTOSAR模型 %s 到Simulink模型失败: %s', swcName, ME.message);
        end
    end
    fprintf('  完成: 成功链接 %d/%d 个SWC\n', successCount, numAutosarSwcs);
    
    % 自动布局并保存模型
    try
        layout(ArchModel);
        save(ArchModel);
        fprintf('  已保存架构模型并自动布局\n');
    catch ME
        warning('MATLAB:appCreateCcmArch:SaveFailed', ...
            '保存架构模型失败: %s', ME.message);
    end
else
    fprintf('  警告: 未找到AUTOSAR SWC\n');
end

% 备用代码: unlinkFromModel(component) % 用于取消链接

fprintf('  完成步骤 3\n\n');

%% ========================================================================
% 步骤4: 为非AUTOSAR SWC创建新的Simulink模型
% ========================================================================
fprintf('步骤 4/8: 为非AUTOSAR SWC创建新的Simulink模型\n');
fprintf('------------------------------------------------\n');

% 验证ERT组合是否存在
if isempty(ertComposition)
    error('MATLAB:appCreateCcmArch:ERTCompositionNotFound', ...
        '未找到ERT组合，无法继续创建非AUTOSAR SWC模型');
end

numErtSwcs = height(Tb_ertSWC);
if numErtSwcs > 0
    createdCount = 0;
    linkedCount = 0;
    
    for iErt = 1:numErtSwcs
        % 获取SWC信息
        swcName = Tb_ertSWC(iErt, :).SWCName{1};
        periodic = Tb_ertSWC(iErt, :).Periodic;
        
        fprintf('  处理ERT SWC (%d/%d): %s (周期: %.1f ms)\n', ...
            iErt, numErtSwcs, swcName, periodic);
        
        % 查找对应的组件
        component = find(ertComposition, 'Component', 'Name', swcName);
        if isempty(component)
            error('MATLAB:appCreateCcmArch:ComponentNotFound', ...
                '未找到对应的组件: %s', swcName);
        end
        
        % 检查工作空间中是否存在对应的模型
        modelPath = which(swcName);
        if isempty(modelPath)
            % 创建新的ERT组件模型
            fprintf('    → 创建新模型: %s\n', swcName);
            try
                createModExportFun(swcName, ...
                    'Periodic', periodic, ...
                    'TargetFolder', 'ModelErt', ...
                    'ModelType', 'autosar');
                
                % 配置AUTOSAR Runnable属性
                changeAutosarRunnable(swcName, ...
                    'AutoBuild', false, ...
                    'RunnablePeriod', periodic);
                
                createdCount = createdCount + 1;
                fprintf('    ✓ 成功创建模型\n');
            catch ME
                warning('MATLAB:appCreateCcmArch:CreateModelFailed', ...
                    '创建ERT组件模型 %s 失败: %s', swcName, ME.message);
                continue;
            end
        else
            fprintf('    → 模型已存在: %s\n', modelPath);
        end
        
        % 链接模型到组件
        try
            if isempty(component.ReferenceName)
                modelPath = which(swcName);
                linkToModel(component, modelPath);
                linkedCount = linkedCount + 1;
                fprintf('    ✓ 成功链接模型\n');
            else
                fprintf('    → 已有引用模型: %s，跳过\n', component.ReferenceName);
                linkedCount = linkedCount + 1;
            end
        catch ME
            warning('MATLAB:appCreateCcmArch:LinkERTModelFailed', ...
                '链接ERT组件模型 %s 失败: %s', swcName, ME.message);
        end
    end
    
    fprintf('  完成: 创建 %d 个新模型，链接 %d/%d 个SWC\n', ...
        createdCount, linkedCount, numErtSwcs);
    
    % 保存架构模型
    try
        save(ArchModel);
        fprintf('  已保存架构模型\n');
    catch ME
        warning('MATLAB:appCreateCcmArch:SaveFailed', ...
            '保存架构模型失败: %s', ME.message);
    end
else
    fprintf('  警告: 未找到ERT SWC\n');
end

fprintf('  完成步骤 4\n\n');

%% ========================================================================
% 步骤5: 创建架构的输入输出端口
% ========================================================================
fprintf('步骤 5/8: 创建架构的输入输出端口\n');
fprintf('------------------------------------------------\n');

try
    [inport, outport] = createArchPort(ArchModel);
    fprintf('  成功创建架构输入输出端口\n');
catch ME
    warning('MATLAB:appCreateCcmArch:CreateArchPortFailed', ...
        '创建架构端口失败: %s', ME.message);
end

fprintf('  完成步骤 5\n\n');

%% ========================================================================
% 步骤6: 自动连接架构中的组件
% ========================================================================
fprintf('步骤 6/8: 自动连接架构中的组件\n');
fprintf('------------------------------------------------\n');

try
    createArchLines(ArchModel);
    fprintf('  成功完成自动连线\n');
catch ME
    warning('MATLAB:appCreateCcmArch:CreateArchLinesFailed', ...
        '自动连线失败: %s', ME.message);
end

fprintf('  完成步骤 6\n\n');

%% ========================================================================
% 步骤7: 创建Interface Dictionary并为端口配置Bus数据类型
% ========================================================================
fprintf('步骤 7/8: 创建Interface Dictionary并为端口配置Bus数据类型\n');
fprintf('------------------------------------------------\n');

% 创建或链接Interface Dictionary
archSldd = [ArchModel.Name, '.sldd'];
if isempty(ArchModel.Interfaces)
    try
        linkDictionary(ArchModel, archSldd);
        fprintf('  成功链接Interface Dictionary: %s\n', archSldd);
    catch ME
        warning('MATLAB:appCreateCcmArch:LinkDictionaryFailed', ...
            '链接Interface Dictionary失败: %s', ME.message);
    end
else
    fprintf('  Interface Dictionary已存在\n');
end

% 保存架构模型
try
    save(ArchModel);
catch ME
    warning('MATLAB:appCreateCcmArch:SaveFailed', ...
        '保存架构模型失败: %s', ME.message);
end

% 备用代码: unlinkDictionary(ArchModel) % 用于取消链接字典

% 打开Interface Dictionary并创建接口
try
    interfaceDict = Simulink.interface.dictionary.open(archSldd);
    fprintf('  已打开Interface Dictionary\n');
    
    [successPort, failPort] = createArchInterface(ArchModel, interfaceDict);
    
    fprintf('  接口创建完成: 成功 %d 个，失败 %d 个\n', ...
        numel(successPort), numel(failPort));
catch ME
    warning('MATLAB:appCreateCcmArch:CreateInterfaceFailed', ...
        '创建Interface失败: %s', ME.message);
end

fprintf('  完成步骤 7\n\n');

%% ========================================================================
% 步骤8: 导出架构代码及ARXML文件
% ========================================================================
fprintf('步骤 8/8: 导出架构代码及ARXML文件\n');
fprintf('------------------------------------------------\n');

try
    export(ArchModel);
    fprintf('  成功导出架构代码及ARXML文件\n');
catch ME
    warning('MATLAB:appCreateCcmArch:ExportFailed', ...
        '导出架构代码及ARXML失败: %s', ME.message);
end

fprintf('  完成步骤 8\n\n');

%% ========================================================================
% 完成
% ========================================================================
elapsedTime = toc;
fprintf('========================================\n');
fprintf('CCM AUTOSAR软件架构创建完成！\n');
fprintf('总耗时: %.2f 秒\n', elapsedTime);
fprintf('========================================\n');
