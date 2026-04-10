function saveHarnessParams(varargin)
%SAVEHARNESSPARAMS 保存harness相关参数数据到本地文件
%   saveHarnessParams() 保存当前harness参数到默认文件'harness.mat'
%   saveHarnessParams('modelName', 'model1', 'PortsIn', {'port1', 'port2'}, ...)
%   保存指定参数到默认文件
%   saveHarnessParams(..., 'filename', 'custom.mat') 保存到指定文件
%
%   输入参数:
%       'modelName' - 模型名称
%       'PortsIn' - 输入端口列表
%       'PortsOut' - 输出端口列表
%       'lastStep' - 上一步信息
%       'nextStep' - 下一步信息
%       'lev1' - 第一层信息
%       'lev2' - 第二层信息
%       'inName' - 输入名称
%       'rstName' - 复位名称
%       'inValue' - 输入值
%       'rstValue' - 复位值
%       'filename' - 保存文件名，默认为'harness.mat'
%
%   示例:
%       saveHarnessParams('modelName', 'model1', 'PortsIn', {'port1'})
%       saveHarnessParams('modelName', 'model1', 'filename', 'custom.mat')
%
%   作者: Blue.ge
%   日期: 20240321

%% 参数解析
p = inputParser;
% 添加参数定义
addParameter(p, 'modelName', '', @ischar);
addParameter(p, 'PortsIn', '', @(x) iscell(x) || ischar(x));
addParameter(p, 'PortsOut', '', @(x) iscell(x) || ischar(x));
addParameter(p, 'lastStep', '', @ischar);
addParameter(p, 'nextStep', '', @ischar);
addParameter(p, 'lev1', '');
addParameter(p, 'lev2', '');
addParameter(p, 'inName', '');
addParameter(p, 'rstName', '');
addParameter(p, 'inValue', '');
addParameter(p, 'rstValue', '');
addParameter(p, 'filename', 'harness.mat', @ischar);

% 解析输入参数
parse(p, varargin{:});

%% 创建数据结构
% 确保所有字段都是cell数组格式
modelName = ensureCell(p.Results.modelName);
PortsIn = ensureCell(p.Results.PortsIn);
PortsOut = ensureCell(p.Results.PortsOut);
lastStep = ensureCell(p.Results.lastStep);
nextStep = ensureCell(p.Results.nextStep);
lev1 = ensureCell(p.Results.lev1);
lev2 = ensureCell(p.Results.lev2);
inName = ensureCell(p.Results.inName);
rstName = ensureCell(p.Results.rstName);
inValue = ensureCell(p.Results.inValue);
rstValue = ensureCell(p.Results.rstValue);

% 创建结构体
harnessData = struct(...
    'modelName', modelName, ...
    'PortsIn', PortsIn, ...
    'PortsOut', PortsOut, ...
    'lastStep', lastStep, ...
    'nextStep', nextStep, ...
    'lev1', lev1, ...
    'lev2', lev2, ...
    'inName', inName, ...
    'rstName', rstName, ...
    'inValue', inValue, ...
    'rstValue', rstValue);

% 辅助函数：确保输入是cell数组
function result = ensureCell(input)
    result = {input};
end

%% 保存数据
filename = p.Results.filename;
% 将文件名保存为路径
filename = which(filename);

try
    % 检查文件是否存在
    if exist(filename, 'file')
        % 加载现有数据
        load(filename);
        % 查找是否存在相同modelName的数据
        idx = find(strcmp({harnessDataArray.modelName}, harnessData.modelName));
        
        if ~isempty(idx)
            % 更新现有数据
            harnessDataArray(idx) = harnessData;
            fprintf('更新模型 "%s" 的数据\n', harnessData.modelName);
        else
            % 追加新数据
            harnessDataArray = [harnessDataArray harnessData];
            fprintf('添加新模型 "%s" 的数据\n', harnessData.modelName);
        end
    else
        % 创建新的数组
        harnessDataArray = harnessData;
        fprintf('创建新文件并保存模型 "%s" 的数据\n', harnessData.modelName);
    end
    
    % 保存更新后的数组到本地文件
    save(filename, 'harnessDataArray');
    fprintf('数据已成功保存到 "%s"\n', filename);
    
catch ME
    % 错误处理
    fprintf('保存数据时发生错误:\n%s\n', ME.message);
    rethrow(ME);
end

end