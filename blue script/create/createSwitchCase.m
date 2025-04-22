function createSwitchCase(varargin)
%CREATESWITCHCASE 为当前路径下的模块创建Switch Case结构
%   createSwitchCase() 自动创建Switch Case模块及其相关的Action子系统。
%
%   可选参数:
%       'caseList' - Case的输入值，默认为'{1,2,3,[4 5 6]}'
%       'caseIn' - Case输入信号，默认为'Demo'
%       'caseNames' - Case具体名称列表，默认为一组压缩机控制信号
%       'sigNames' - Switch的输出信号，默认为{'demo1','demo2'}
%       'actionPosYShift' - 每个case的垂直偏移值，默认为50
%       'caseGap' - Switch case的间距，默认为30
%       'caseStp' - Switch case间距放大系数，默认为1
%       'resovleSig' - 是否需要解析merge后的信号，默认为true
%
%   示例:
%       createSwitchCase()
%       createSwitchCase('caseIn', 'Demo', 'caseList', '{1,2,3,[4 5 6]}', ...
%           'caseNames', {'A','B','C','D'}, 'sigNames', {'demo1','demo2'})
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-05-17
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'caseList', '{1,2,3,[4 5 6]}', @ischar);
        addParameter(p, 'caseIn', 'Demo', @ischar);
        addParameter(p, 'caseNames', {
            'rTmComprCtrl_Te_s32TempError', ...
            'rTmComprCtrl_n_u16ComprRpmFF', ...
            'rTmComprCtrl_n_u16ComprRpmKp', ...
            'rTmComprCtrl_n_u16ComprRpmKi'
            }, @iscell);
        addParameter(p, 'sigNames', {'demo1','demo2'}, @iscell);
        addParameter(p, 'actionPosYShift', 50, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'caseGap', 30, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'caseStp', 1, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'resovleSig', true, @islogical);
        
        parse(p, varargin{:});
        
        caseList = p.Results.caseList;
        caseNames = p.Results.caseNames;
        caseIn = p.Results.caseIn;
        sigNames = p.Results.sigNames;
        actionPosYShift = p.Results.actionPosYShift;
        caseStp = p.Results.caseStp;
        caseGap = p.Results.caseGap;
        resovleSig = p.Results.resovleSig;
        
        %% 创建Switch Case模块
        pos = [0, 0, 400, (length(caseNames) + 1) * 30];
        swCase = add_block('built-in/SwitchCase', [gcs '/Switch Case'], ...
            'MakeNameUnique', 'on', ...
            'Position', pos, ...
            'CaseConditions', caseList);
        
        %% 获取端口句柄
        portHandles = get_param(swCase, 'PortHandles');
        portInH = portHandles.Inport;
        portOutH = portHandles.Outport;
        
        %% 创建输入From模块
        pos = get(portInH).Position;
        posFrom = pos - [200, 0];
        posFrom = [posFrom, posFrom] + [-30, -7, 30, 7];
        
        fromBlock = add_block('built-in/From', [gcs '/From'], ...
            'MakeNameUnique', 'on', ...
            'Position', posFrom);
        set_param(fromBlock, 'GotoTag', caseIn);
        
        % 创建连线
        creatLines([fromBlock, swCase]);
        
        %% 创建输出Goto模块
        caseNames{end+1} = 'Default';
        for i = 1:length(caseNames)
            hPort = portOutH(i);
            sigName = caseNames{i};
            pos = get(hPort).Position;
            posGoto = pos + [200, 0];
            posGoto = [posGoto, posGoto] + [-30, -7, 30, 7];
            
            gotoBlock = add_block('built-in/Goto', [gcs '/Goto'], ...
                'MakeNameUnique', 'on', ...
                'Position', posGoto);
            set_param(gotoBlock, 'GotoTag', sigName);
            
            % 创建连线
            creatLines([swCase, gotoBlock]);
        end
        
        %% 创建各个子Case条件
        height = max(30 * length(sigNames), 60);
        posSubCaseBase = [1000, 0, 1400, height];
        
        for i = 1:length(caseNames)
            %% 创建SwitchCaseActionSubsystem
            yShift = caseStp * (height + actionPosYShift + caseGap) * (i-1);
            pos = posSubCaseBase + [0, yShift, 0, yShift];
            caseName = caseNames{i};
            
            subSystem = add_block('simulink/Ports & Subsystems/Switch Case Action Subsystem', ...
                [gcs '/' caseName], ...
                'MakeNameUnique', 'on', ...
                'Position', pos);
            
            % 删除默认端口和连线
            delete_block(find_system(subSystem, 'BlockType', 'Inport'));
            delete_block(find_system(subSystem, 'BlockType', 'Outport'));
            delete_line(find_system(subSystem, 'findall', 'on', 'Type', 'Line', 'Connected', 'off'));
            
            path = [get(subSystem).Path '/' get(subSystem).Name];
            
            %% 添加输出信号
            posBase = [0, 0, 0, 0];
            
            for j = 1:length(sigNames)
                sig = sigNames{j};
                sigList = split(sig, '_');
                sigPrefix = sigList{1}(1);
                rootName = sigList{1}(2:end);
                name = [sigPrefix, caseName, erase(sig, sigList{1})];
                
                difY = 30 * (j-1);
                pos = posBase + [0, difY, 0, difY];
                posOut = pos + [-15, -7, 15, 7];
                
                outPort = add_block('built-in/Outport', [path '/' name], ...
                    'Position', posOut);
            end
            
            %% 添加Action From
            portHandles = get_param(subSystem, 'PortHandles');
            ifActionH = portHandles.Ifaction;
            pos = get_param(ifActionH, 'Position') + [-150, -actionPosYShift];
            posActionFrom = [pos, pos] + [-30, -7, 30, 7];
            
            actionFrom = add_block('built-in/From', [gcs '/From'], ...
                'MakeNameUnique', 'on', ...
                'Position', posActionFrom);
            set_param(actionFrom, 'GotoTag', caseName);
            
            % 创建连线
            portHFrom = get(actionFrom).PortHandles.Outport;
            portHMod = get(subSystem).PortHandles.Ifaction;
            add_line(gcs, portHFrom, portHMod, 'autorouting', 'on');
        end
        
        %% 创建Goto/From模块
        createModGotoAll('mode', 'both');
        
        %% 创建Merge模块
        if ~isempty(sigNames)
            createMerge('sigList', sigNames, 'resovleSig', resovleSig);
        end
        
        fprintf('成功创建了Switch Case结构\n');
        
    catch ME
        error('创建Switch Case结构时发生错误: %s', ME.message);
    end
end

