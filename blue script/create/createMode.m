function [createdInput, createdOutput] = createMode(path, varargin)
%CREATEMODE 统一函数用于模型相关的批量操作
%   [createdInput, createdOutput] = createMode(path) 对指定模型进行批量操作，
%   包括创建端口、Goto/From模块、接地等，同时支持信号解析。
%
%   输入参数:
%       path - 模型路径
%
%   可选参数:
%       基本参数:
%           'inType' - 输入类型，可选'port'（默认）、'ground'、'from'、'const'、'none'
%           'outType' - 输出类型，可选'port'（默认）、'term'、'goto'、'disp'、'none'
%           'wid' - 模型宽度，默认为400
%
%       createModPorts参数:
%           'mode' - 模式，默认为'both'
%           'suffixStr' - 后缀字符串，默认为''
%           'findType' - 查找类型，默认为'base'
%           'add' - 添加类型，默认为'None'
%           'enFirstTrig' - 是否启用首次触发，默认为false
%
%       信号解析参数:
%           'skipTrig' - 是否跳过触发，默认为false
%           'isEnableIn' - 是否启用输入，默认为true
%           'isEnableOut' - 是否启用输出，默认为true
%           'resoveValue' - 是否解析值，默认为true
%           'logValue' - 是否记录值，默认为false
%           'testValue' - 是否测试值，默认为false
%           'dispName' - 是否显示名称，默认为true
%
%       createModGoto参数:
%           'inList' - 输入信号列表，默认为{}
%           'outList' - 输出信号列表，默认为{}
%           'bkHalfLength' - 模块半长，默认为25
%
%   输出参数:
%       createdInput - 创建的输入信号列表
%       createdOutput - 创建的输出信号列表
%
%   示例:
%       [in, out] = createMode(gcb)
%       [in, out] = createMode(gcb, 'inType', 'ground', 'outType', 'port') % 可选'port'（默认）、'ground'、'from'、'const'、'none'
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-01-26
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 基本参数
        addParameter(p, 'inType', 'port', @(x) any(strcmp(x, {'port', 'ground', 'from', 'const', 'none'})));
        addParameter(p, 'outType', 'port', @(x) any(strcmp(x, {'port', 'term', 'goto', 'disp', 'none'})));
        addParameter(p, 'wid', 400, @(x) isnumeric(x) && x > 0);
        
        % createModPorts参数
        addParameter(p, 'mode', 'both', @ischar);
        addParameter(p, 'suffixStr', '', @ischar);
        addParameter(p, 'findType', 'base', @ischar);
        addParameter(p, 'add', 'None', @ischar);
        addParameter(p, 'enFirstTrig', false, @islogical);
        
        % 信号解析参数
        addParameter(p, 'skipTrig', false, @islogical);
        addParameter(p, 'isEnableIn', true, @islogical);
        addParameter(p, 'isEnableOut', true, @islogical);
        addParameter(p, 'resoveValue', false, @islogical);
        addParameter(p, 'logValue', false, @islogical);
        addParameter(p, 'testValue', false, @islogical);
        addParameter(p, 'dispName', false, @islogical);
        
        % createModGoto参数
        addParameter(p, 'inList', {}, @iscell);
        addParameter(p, 'outList', {}, @iscell);
        addParameter(p, 'bkHalfLength', 25, @(x) isnumeric(x) && x > 0);
        
        parse(p, varargin{:});
        
        % 获取参数值
        inType = p.Results.inType;
        outType = p.Results.outType;
        wid = p.Results.wid;
        mode = p.Results.mode;
        suffixStr = p.Results.suffixStr;
        findType = p.Results.findType;
        add = p.Results.add;
        enFirstTrig = p.Results.enFirstTrig;
        skipTrig = p.Results.skipTrig;
        isEnableIn = p.Results.isEnableIn;
        isEnableOut = p.Results.isEnableOut;
        resoveValue = p.Results.resoveValue;
        logValue = p.Results.logValue;
        testValue = p.Results.testValue;
        dispName = p.Results.dispName;
        inList = p.Results.inList;
        outList = p.Results.outList;
        bkHalfLength = p.Results.bkHalfLength;
        
        %% 处理输入
        fprintf('输入类型: %s\n', inType);
        switch inType
            case 'port'
                [createdInput, createdOutput] = createModPorts(path, ...
                    'mode', 'inport', ...
                    'findType', findType, ...
                    'add', add, ...
                    'suffixStr', suffixStr, ...
                    'enFirstTrig', enFirstTrig);
            case 'from'
                [createdInput, createdOutput] = createModGoto(path, ...
                    'mode', 'inport', ...
                    'suffixStr', suffixStr, ...
                    'inList', inList, ...
                    'outList', outList, ...
                    'bkHalfLength', bkHalfLength);
            case 'ground'
                [createdInput, createdOutput] = createModGroundTerm(path, ...
                    'mode', 'inport');
            case 'const'
                [createdInput, createdOutput] = createModConstDisp(path, ...
                    'mode', 'inport');
            case 'none'
                createdInput = {};
                createdOutput = {};
            otherwise
                error('不支持的输入类型: %s', inType);
        end
        
        %% 处理输出
        fprintf('输出类型: %s\n', outType);
        switch outType
            case 'port'
                [createdInput, createdOutput] = createModPorts(path, ...
                    'mode', 'outport', ...
                    'findType', findType, ...
                    'add', add, ...
                    'suffixStr', suffixStr, ...
                    'enFirstTrig', enFirstTrig);
            case 'goto'
                [createdInput, createdOutput] = createModGoto(path, ...
                    'mode', 'outport', ...
                    'suffixStr', suffixStr, ...
                    'inList', inList, ...
                    'outList', outList, ...
                    'bkHalfLength', bkHalfLength);
            case 'term'
                [createdInput, createdOutput] = createModGroundTerm(path, ...
                    'mode', 'outport');
            case 'disp'
                [createdInput, createdOutput] = createModConstDisp(path, ...
                    'mode', 'outport');
            case 'none'
                % 保持原有输出不变
            otherwise
                error('不支持的输出类型: %s', outType);
        end
        
        %% 解析信号
        createModSig(path, ...
            'skipTrig', skipTrig, ...
            'isEnableIn', isEnableIn, ...
            'isEnableOut', isEnableOut, ...
            'resoveValue', resoveValue, ...
            'logValue', logValue, ...
            'testValue', testValue, ...
            'dispName', dispName);
        
        %% 改变模型大小
        changeModSize(path, 'wid', wid);
        
        fprintf('模型操作完成\n');
        
    catch ME
        error('模型操作时发生错误: %s', ME.message);
    end
end

  