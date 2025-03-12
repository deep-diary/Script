function createSwitchCase(varargin)
%%
    % 目的: 对当前路径下的，创建switch case 模块
    % 输入：
    %       信号列表
    % 返回： None
    % 范例： createSwitchCase('caseIn','Demo','caseList','{1,2,3,[4 5 6]}','caseNames',{'A','B','C','D'},'sigNames',{'demo1','demo2'})
    % 作者： Blue.ge
    % 日期： 20240517
%%
    
    clc
    %% 输入参数处理
    p = inputParser;                                    % 函数的输入解析器
    addParameter(p,'caseList','{1,2,3,[4 5 6]}');       % case 的输入值
    addParameter(p,'caseIn','Demo');                    % case 输入信号
    addParameter(p,'caseNames',...
        {'rTmComprCtrl_Te_s32TempError','rTmComprCtrl_n_u16ComprRpmFF',...
        'rTmComprCtrl_n_u16ComprRpmKp','rTmComprCtrl_n_u16ComprRpmKi',...
        });                                              % case 具体名称列表
    addParameter(p,'sigNames',...
        {'demo1','demo2'});                                              % switch 的输出信号
    addParameter(p,'actionPosYShift',50);               % 每个case 的偏移值
    addParameter(p,'caseGap',30);                      % switch case 的间距
    addParameter(p,'caseStp',1);                        % switch case 间距放大系数
    addParameter(p,'resovleSig',true);                  % 经过merge后，是否需要解析信号

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    caseList = p.Results.caseList;  %  需要转换成字符串
%     caseList = '{1,2,3,[4 5 6]}';
    caseNames = p.Results.caseNames;
    caseIn = p.Results.caseIn;
    sigNames = p.Results.sigNames;
    actionPosYShift = p.Results.actionPosYShift;
    caseStp = p.Results.caseStp;   % 2 倍（模型高度 + actionPosYShift）
    caseGap = p.Results.caseGap;
    resovleSig = p.Results.resovleSig;
    %% 创建swich case
    pos = [0 0 400 (length(caseNames)+1)*30];
    swCase = add_block('built-in/SwitchCase', [gcs '/Switch Case'], 'MakeNameUnique','on', ...
                           'Position', pos, 'CaseConditions', caseList);

    %% 获取端口句柄
    PortHandles = get_param(swCase,'PortHandles');
    PortInH = PortHandles.Inport;
    PortOutH = PortHandles.Outport;

    %% 创建输入from
    pos = get(PortInH).Position;
    posFrom = pos - [200 0];
    posFrom = [posFrom posFrom] + [-30 -7 30 7]
        % signal is belongs to interface signal，创建模块
    bk = add_block('built-in/From', [gcs '/From'], 'MakeNameUnique','on', ...
              'Position', posFrom);
    set_param(bk, 'GotoTag', caseIn);

    % 创建连线
    creatLines([bk, swCase])

    %% 创建输出goto
    caseNames{end+1} = 'Default';
    for i=1:length(caseNames)
        hPort = PortOutH(i);
        sigName = caseNames{i};
        pos = get(hPort).Position;
        posGoto = pos + [200 0];
        posGoto = [posGoto posGoto] + [-30 -7 30 7]
            % signal is belongs to interface signal，创建模块
        bk = add_block('built-in/Goto', [gcs '/Goto'], 'MakeNameUnique','on', ...
                  'Position', posGoto);
        set_param(bk, 'GotoTag', sigName);
    
        % 创建连线
        creatLines([swCase bk])

    end

    %% 循环创建各个子Case 条件
    height = max(30*length(sigNames),60);
    posSubCaseBase = [ 1000 0 1400 height];
    for i=1:length(caseNames)
        %% 创建SwitchCaseActionSubsystem
        YShift = caseStp * (height + actionPosYShift + caseGap) * (i-1);  % 30 is gap
        pos = posSubCaseBase + [0 YShift 0 YShift];
        caseName = caseNames{i};
        bk = add_block('simulink/Ports & Subsystems/Switch Case Action Subsystem', [gcs '/' caseName], 'MakeNameUnique','on', ...
                      'Position', pos);
        delete_block(find_system(bk,'BlockType', 'Inport'))
        delete_block(find_system(bk,'BlockType', 'Outport'))
        delete_line(find_system(bk,'findall','on','Type','Line','Connected','off'))
    
        path = [get(bk).Path '/' get(bk).Name];
    %     CasePath = find_system(gcs, 'Name',sigName)
    %     path = CasePath{1}
    %     path = gcb
    %     bk = gcbh
        %% 添加输出信号
        posBase = [0 0 0 0];
        rootName = '';
        
        for j=1:length(sigNames)  % xTmComprCtrl_B_RdyToChange
            sig = sigNames{j};
            sigList = split(sig, '_');  % {'xTmComprCtrl'}  {'B'           }  {'RdyToChange' }
            sigPrefix = sigList{1}(1);
            rootName = sigList{1}(2:end);
            name = [sigPrefix caseName erase(sig,sigList{1})];
            
            difY = 30 * (j-1);
            pos = posBase + [0 difY 0 difY];
            posOut = pos + [-15 -7 15 7];
            bkOut = add_block('built-in/Outport', [path '/' name ], ...
                              'Position', posOut);
        end
    
        %% 添加Action From
        PortHandles = get_param(bk,'PortHandles');
        IfactionH = PortHandles.Ifaction;
        pos = get_param(IfactionH,'Position') + [-150 -actionPosYShift];
        posActionFrom = [pos pos] + [-30 -7 30 7];
        bkFrom = add_block('built-in/From', [gcs '/From'], 'MakeNameUnique','on', ...
              'Position', posActionFrom);
        set_param(bkFrom, 'GotoTag', caseName);
    
        % 创建连线
        portHFrom = get(bkFrom).PortHandles.Outport;
        portHMod = get(bk).PortHandles.Ifaction;
        add_line(gcs, portHFrom, portHMod, 'autorouting', 'on');

    end
    %% 创建goto from
    createModGotoAll('mode','both');

    %% 创建merge
    step = (length(caseNames)+2) * 30
    if ~isempty(sigNames)
        createMerge( ...
        'sigList', sigNames,...
        'step',step, ...
        'resovleSig',resovleSig, ...
        'RootName',rootName)
    end

end

