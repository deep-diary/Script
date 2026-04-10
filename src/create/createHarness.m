function createHarness(path, varargin)
%CREATEHARNESS 为模块创建测试用例
%   createHarness(path) 为指定路径下的模块创建测试用例，支持新建、追加和插入三种模式。
%
%   输入参数:
%       path - 模型路径，例如 gcb
%
%   可选参数:
%       'lev1' - 第一层级模块名称，默认为 {'SM123','SM456'}
%       'lev2' - 第二层级模块名称，默认为 {{'SM1','SM2'},{'SM4','SM5','SM6'}}
%       'inName' - 输入端口名称，默认为 {{'SM11','SM12'},{'SM14','SM15','SM16'}}
%       'inValue' - 输入值，默认为 {{{10, 5},{8, 3, 2}},{6, 4},{4, 5, 8}}
%       'rstName' - 结果端口名称，默认为 {{'SM1','SM2'},{'SM4','SM5','SM6'}}
%       'rstValue' - 结果值，默认为 {{{10,20},{10,20,20}},{{10,20},{10,20,20}}}
%       'mask' - 掩码值，默认为0
%       'lastStep' - 上一步操作，默认为'Initialize'
%       'nextStep' - 下一步操作，默认为'None'
%       'tolerance' - 容差值，默认为0.01
%       'waitTime' - 等待时间，默认为0.05
%       'usingAllPorts' - 是否使用所有端口，默认为false
%       'logValue' - 是否记录值，默认为false
%
%   示例:
%       createHarness(gcb)
%       createHarness(gcb, 'lev1', {'SM123'}, 'tolerance', 0.02)
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-03-29
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'lev1', {'SM123','SM456'}, @iscell);
        addParameter(p, 'lev2', {{'SM1','SM2'},{'SM4','SM5','SM6'}}, @iscell);
        addParameter(p, 'inName', {{'SM11','SM12'},{'SM14','SM15','SM16'}}, @iscell);
        addParameter(p, 'inValue', {{{10, 5},{8, 3, 2}},{6, 4},{4, 5, 8}}, @iscell);
        addParameter(p, 'rstName', {{'SM1','SM2'},{'SM4','SM5','SM6'}}, @iscell);
        addParameter(p, 'rstValue', {{{10,20},{10,20,20}},{{10,20},{10,20,20}}}, @iscell);
        addParameter(p, 'mask', 0, @isnumeric);
        addParameter(p, 'lastStep', 'Initialize', @ischar);
        addParameter(p, 'nextStep', 'None', @ischar);
        addParameter(p, 'tolerance', 0.01, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'waitTime', 0.05, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'usingAllPorts', false, @islogical);
        addParameter(p, 'logValue', true, @islogical);
        
        parse(p, varargin{:});
        
        % 获取参数值
        mask = p.Results.mask;
        inName = p.Results.inName;
        inValue = p.Results.inValue;
        lev1Arry = p.Results.lev1;
        lev2Arry = p.Results.lev2;
        rstName = p.Results.rstName;
        rstValue = p.Results.rstValue;
        lastStep = p.Results.lastStep;
        nextStep = p.Results.nextStep;
        tolerance = p.Results.tolerance;
        waitTime = p.Results.waitTime;
        usingAllPorts = p.Results.usingAllPorts;
        logValue = p.Results.logValue;

        %% 输入数值转换
        % 字符串转换成数值
        for i=1:length(inValue)
            lev1Value = inValue{i}
            for j=1:length(lev1Value)
                lev2Value = lev1Value{j}
                for k=1:length(lev2Value)
                    if ischar(lev2Value{k})
                        inValue{i}{j}{k} = str2num(lev2Value{k});
                    end
                end
            end
        end
        
        %% 使用自带的端口信息
        if usingAllPorts
            [modelName, portsIn, portsOut] = findModPorts(path, 'getType', 'Name');
            for i = 1:length(inName{1})
                inName{i} = portsIn;
                rstName{i} = portsOut;
            end
        end
        
        %% 根据操作类型选择不同的创建方式
        if strcmp(lastStep, 'Initialize')
            % 新创建测试用例
            createHarnessNew(path, ...
                'mask', mask, ...
                'tolerance', tolerance, ...
                'waitTime', waitTime, ...
                'lev1', lev1Arry, ...
                'lev2', lev2Arry, ...
                'inName', inName, ...
                'rstName', rstName, ...
                'inValue', inValue, ...
                'rstValue', rstValue, ...
                'logValue', logValue);
                
        elseif strcmp(nextStep, 'None')
            % 追加测试用例
            createHarnessAppendV2(path, lastStep, ...
                'mask', mask, ...
                'tolerance', tolerance, ...
                'waitTime', waitTime, ...
                'lev1', lev1Arry, ...
                'lev2', lev2Arry, ...
                'inName', inName, ...
                'rstName', rstName, ...
                'inValue', inValue, ...
                'rstValue', rstValue);
                
        else
            % 插入测试用例
            createHarnessInsert(path, lastStep, nextStep, ...
                'mask', mask, ...
                'lev1', lev1Arry, ...
                'lev2', lev2Arry, ...
                'inName', inName, ...
                'rstName', rstName, ...
                'inValue', inValue, ...
                'rstValue', rstValue);
        end
        
        fprintf('测试用例创建完成\n');
        
    catch ME
        error('创建测试用例时发生错误: %s', ME.message);
    end
end

  