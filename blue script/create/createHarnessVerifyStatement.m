function outAction = createHarnessVerifyStatement(harnessName,names,values,varargin)
%%
% 目的: 为模块追加测试用例
% 输入：
% 返回：None
% 范例： outAction = createHarnessVerifyStatement('demoHarness',{'SM11', 'SM12'},{10, 5.0})
% 作者： Blue.ge
% 日期： 20240410
%%
    % 设置默认端口间距
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器


    addParameter(p,'mask',0);      % 设置变量名和默认参数
    addParameter(p,'tolerance',0.01);      % 设置变量名和默认参数
    addParameter(p,'waitTime',0.1);      % 设置变量名和默认参数
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    mask = p.Results.mask;
    tolerance = p.Results.tolerance;
    waitTime = p.Results.waitTime;

    %%  合并输入
%     harnessName = 'demoHarness'
%     names = {'SM11'};
%     mask = [0x01 0 1]
%     values = {10, 5.0};
    len = length(names);
    maskFlag = true;
    if len~=length(mask) || (numel(mask)==1&&mask==0)
        maskFlag = false;
    end
    outAction = sprintf('%% verify statement\n');
    for i = 1:len
        outputName = names{i};
        outputValue = values{i};
        % 判断变量是否是数字
        if isnumeric(outputValue)
            % 将数字转换成字符串
            outputValue = num2str(outputValue);
        end

        % 判断变量是否是逻辑
        if islogical(outputValue)
            % 将数字转换成字符串
            if outputValue
                outputValue = 'true';
            else
                outputValue = 'false';
            end
        end
        
        if maskFlag==false || mask(i) == 0  % there is no need to mask
            verify = sprintf([...
                'verify(et<%f||et>%f||abs(%s-single(%s))<%f,' ...
                '''SimulinkTest:%s'',' ...
                '''the result is %%f'',single(%s));\n'],waitTime,waitTime, outputValue, outputName,tolerance, harnessName,outputName);
        else
            verify = sprintf([...
                'verify(et<%f||et>%f||abs(%s - bitand(%s,%d))<%f,' ...
                '''SimulinkTest:%s'',' ...
                '''the result is %%f'',single(%s));\n'],waitTime,waitTime, outputValue, outputName,mask(i), tolerance, harnessName,outputName);
        end
        outAction = [outAction verify];
    end
    disp(outAction);
    
end
