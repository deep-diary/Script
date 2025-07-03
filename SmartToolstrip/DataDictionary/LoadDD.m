%% 数据字典加载脚书本使用说明
% 功能: 将数据字典导入BaseWorkspace
% 输入：
%       运行后鼠标选择想要导入的DD文件
% 可选： mode: {'XCU','PCMU','VCU'} 默认为'VCU'
%       exclude: {'Inpout','Output',''}，默认为''表示Input&Output
%       type: {'Parameter','Signal',''},默认为''表是Parameter&Signals
% 返回： 无
% 范例： LoadDD('mode','VCU')
%        LoadDD('type','Parameter')
%        LoadDD('mode','PCMU','type','Signal','exclude','Input')
%        LoadDD()
% 作者： yuanfei.chen
% 日期： 20240223

function LoadDD(varargin)
%% 清空命令区
    clc
%% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'mode',{});      % 设置变量名和默认参数
    addParameter(p,'exclude',{});      % 设置变量名和默认参数
    addParameter(p,'type',{});
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    
    mode = p.Results.mode;
    exclude = p.Results.exclude;
    type = p.Results.type;

%% 选择路径加载DD文件
    fprintf('----Please select a DD file: ----');
    try
        % 获取当前活跃的Simulink模型名称
        modelName = bdroot;

        % 获取模型文件的完整路径
        modelPath = get_param(modelName, 'FileName');

        % 提取目录路径
        [modelDir, ~, ~] = fileparts(modelPath);

%         proj = currentProject;
%         rootPath = proj.RootFolder;
%         filePath = char(rootPath + '\DD');
        path = uigetfile({'*.xlsx';'*.xls'},...
            'Select a file',modelDir);
    catch
        path = uigetfile({'*.xlsx';'*.xls'});
    end

%% 校验路径
    % 检查文件扩展名是否为Excel格式

    isExcelFile = endsWith(char(path), '.xls') || endsWith(char(path), '.xlsx');
    
    % 显示结果
    if ~isExcelFile
        error('此文件不是 excel!');
    end

%% 检查DD文件名是PCMU 还是VCU
    if contains(path, 'PCMU')
        disp('此文件是 PCMU 数据字典格式.');
        mode = 'PCMU';
    elseif contains(path, 'VCU')
        disp('此文件是 VCU 数据字典格式.');
        mode = 'VCU';
    elseif contains(path, 'XCU')
        disp('此文件是 XCU 数据字典格式.');
        mode = 'XCU';
    else
        warning('此文件名不包含PCMU，VCU或XCU,将根据VCU数据字典格式尝试导入')
    end

%% 加载信号和参数
    if strcmp(mode,'PCMU')
        if strcmp(type,'Parameter')
            findSlddLoadParamPCMU(path);
        elseif strcmp(type,'Signal')
            findSlddLoadSigPCMU(path,'exclude',exclude)
        else
            findSlddLoadParamPCMU(path);
            findSlddLoadSigPCMU(path,'exclude',exclude)
        end

    elseif  strcmp(mode,'VCU')
        if strcmp(type,'Parameter')
            findSlddLoadParamVCU(path);
        elseif strcmp(type,'Signal')
            findSlddLoadSigVCU(path,'exclude',exclude);
        else
            findSlddLoadParamVCU(path);
            findSlddLoadSigVCU(path,'exclude',exclude);
        end

    elseif  strcmp(mode,'XCU')
        if strcmp(type,'Parameter')
            findSlddLoadParamXCU(path);
        elseif strcmp(type,'Signal')
            findSlddLoadSigXCU(path,'exclude',exclude);
        else
            findSlddLoadParamXCU(path);
            findSlddLoadSigXCU(path,'exclude',exclude);
        end

    end

    fprintf('----%s 导入完成!----\n',path);
%% 清楚临时变量
clear proj rootPath filePath path;

end