function createMerge(varargin)
%%
    % 目的: 对当前路径下的，使能子系统或switch case输出的信号，自动生成Merge
    % 输入：
    %       信号列表
    % 返回： None
    % 范例： createMerge('step',400,'sigList',{'rTmComprCtrl_B_RdyToChange'})
    % 作者： Blue.ge
    % 日期： 20231009
%%
    
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'sigList',...
        {'rTmComprCtrl_Te_s32TempError','rTmComprCtrl_n_u16ComprRpmFF',...
        'rTmComprCtrl_n_u16ComprRpmKp','rTmComprCtrl_n_u16ComprRpmKi',...
        'rTmComprCtrl_Te_s32UpErrStop','rTmComprCtrl_Te_s32LowErrStop',...
        'rTmComprCtrl_n_u16KpUpLimit','rTmComprCtrl_n_u16KpLowLimit',...
        'rTmComprCtrl_n_u16KiUpLimit','rTmComprCtrl_n_u16KiLowLimit',...
        'rTmComprCtrl_n_u16DisOverrideValue','rTmComprCtrl_t_u8PIPeriod',...
        'rTmComprCtrl_B_Enable'
        } ...
        );                                      % 设置变量名
    addParameter(p,'resovleSig',true);          % 是否需要解析merge的信号


    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    sigList = p.Results.sigList;
    resovleSig = p.Results.resovleSig;

    %% 检查sigList 信号前缀是否一致
        % 遍历信号
    sig = sigList{1};
    sigParts = split(sig,'_');
    RootName = sigParts{1}(2:end);
    for i=1: length(sigList)  % 信号列表
        sig = sigList{i};
        sigParts = split(sig,'_');
        RootNameTemp = sigParts{1}(2:end);
        if ~strcmp(RootNameTemp,RootName)
            error('all the signals in sigList should have the same prefix, e.g. "TmComprCtrl" in "rTmComprCtrl_Te_s32TempError","rTmComprCtrl_n_u16ComprRpmFF",')
        end
    end
    %% 
    switchSubPaths = {};
    switchSubNames = {};

    % 找到包含Action Port 的子系统， 将找到的模型路径保存到switchSub变量中
    subs = find_system(gcs, 'SearchDepth',1,'BlockType','SubSystem');
    subs = subs(2:end);  % 去掉本身的子系统
    for i=1:length(subs)
        ports=get_param(subs{i}, 'Ports');
        if ports(8)||ports(3)  % 8: witch case port, 3: enable port
            switchSubPaths = [switchSubPaths, subs{i}];
            switchSubNames= [switchSubNames,get_param(subs{i}, 'Name')];
        end
    end

    %% 改变模型输出端口的名字
%     [~,~,OrgSigList] = findModPorts(switchSubPaths{1}, 'getType', 'Name');
% 
%     % 根据 switchSubPath, 找到对应的 switchSubName
% 
%     for i=1: length(switchSubPaths)
%         path = switchSubPaths{i};
%         switchSubName = get_param(path, 'Name');
%         changeModPortName(path, 'TmComprCtrl', switchSubName)
% %         sigList = changeModPortName(path, 'TmComprCtrl', switchSubName)
%     end

    %% 遍历原始信号
    nums = length(switchSubNames);
    step = (nums+2) * 30; % merge 信号数量+两边留白， 每个信号间距30
    pos = get_param(switchSubPaths{1}, 'Position');
    posBase = [pos(3)+600 pos(2) pos(3)+630 pos(2) + 30*nums];

    % 遍历信号
    for i=1: length(sigList)  % 信号列表
        pos = posBase + [0 (i-1)*step 0 (i-1)*step];
%         pathMerg = [gcs '/' , sig];
        h = add_block('built-in/Merge', [gcs '/Merge'], 'MakeNameUnique','on',...
                              'Position', pos, 'Inputs', num2str(nums));
        % 遍历模型
        sigs =cell(1,nums);
        for j=1:length(switchSubNames)
            mdName = switchSubNames{j};
            sigs{j} = strrep(sig, RootName, mdName);
        end
        % 创建From    
        createMergeFrom(h, sigs, sig, 'resovleSig',resovleSig)
    end

    
end

