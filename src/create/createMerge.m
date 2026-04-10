function createMerge(varargin)
%CREATEMERGE 为当前路径下的使能子系统或switch case输出信号自动生成Merge模块
%   createMerge() 自动为当前模型中的使能子系统或switch case输出信号创建Merge模块。
%
%   可选参数:
%       'sigList' - 需要创建Merge的信号列表，默认为一组压缩机控制信号
%       'resovleSig' - 是否需要解析merge的信号，默认为true
%
%   示例:
%       createMerge()
%       createMerge('sigList', {'rTmComprCtrl_B_RdyToChange'})
%       createMerge('sigList', {'rTmComprCtrl_B_RdyToChange'}, 'resovleSig', false)
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2023-10-09
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'sigList', {
            'rTmComprCtrl_Te_s32TempError', ...
            'rTmComprCtrl_n_u16ComprRpmFF', ...
            'rTmComprCtrl_n_u16ComprRpmKp', ...
            'rTmComprCtrl_n_u16ComprRpmKi', ...
            'rTmComprCtrl_Te_s32UpErrStop', ...
            'rTmComprCtrl_Te_s32LowErrStop', ...
            'rTmComprCtrl_n_u16KpUpLimit', ...
            'rTmComprCtrl_n_u16KpLowLimit', ...
            'rTmComprCtrl_n_u16KiUpLimit', ...
            'rTmComprCtrl_n_u16KiLowLimit', ...
            'rTmComprCtrl_n_u16DisOverrideValue', ...
            'rTmComprCtrl_t_u8PIPeriod', ...
            'rTmComprCtrl_B_Enable'
            }, @iscell);
            
        addParameter(p, 'resovleSig', true, @islogical);
        addParameter(p, 'pos', []);
        
        parse(p, varargin{:});
        
        sigList = p.Results.sigList;
        resovleSig = p.Results.resovleSig;
        pos = p.Results.pos;
        
        %% 检查信号前缀一致性
        sig = sigList{1};
        sigParts = split(sig, '_');
        rootName = sigParts{1}(2:end);
        
        for i = 1:length(sigList)
            sig = sigList{i};
            sigParts = split(sig, '_');
            rootNameTemp = sigParts{1}(2:end);
            
            if ~strcmp(rootNameTemp, rootName)
                error('信号列表中的所有信号必须具有相同的前缀，例如"TmComprCtrl"在"rTmComprCtrl_Te_s32TempError"和"rTmComprCtrl_n_u16ComprRpmFF"中');
            end
        end
        
        %% 查找包含Action Port的子系统
        switchSubPaths = {};
        switchSubNames = {};
        
        subs = find_system(gcs, 'SearchDepth', 1, 'BlockType', 'SubSystem');
        subs = subs(2:end);  % 移除当前子系统
        
        for i = 1:length(subs)
            ports = get_param(subs{i}, 'Ports');
            if ports(8) || ports(3)  % 8: switch case port, 3: enable port
                switchSubPaths = [switchSubPaths, subs{i}];
                switchSubNames = [switchSubNames, get_param(subs{i}, 'Name')];
            end
        end
        
        if isempty(switchSubPaths)
            error('未找到包含Action Port的子系统');
        end
        
        %% 创建Merge模块
        numSubs = length(switchSubNames);
        step = (numSubs + 2) * 30;  % merge信号数量+两边留白，每个信号间距30
        if isempty(pos)
            pos = get_param(switchSubPaths{1}, 'Position');
        end
        posBase = [pos(3) + 600, pos(2), pos(3) + 630, pos(2) + 30 * numSubs];
        
        % 遍历信号列表
        for i = 1:length(sigList)
            pos = posBase + [0, (i-1)*step, 0, (i-1)*step];
            
            % 创建Merge模块
            mergeBlock = add_block('built-in/Merge', [gcs '/Merge'], ...
                'MakeNameUnique', 'on', ...
                'Position', pos, ...
                'Inputs', num2str(numSubs));
            
            % 生成信号列表
            sigs = cell(1, numSubs);
            for j = 1:length(switchSubNames)
                subName = switchSubNames{j};
                sigs{j} = strrep(sigList{i}, rootName, subName);
            end
            
            % 创建From模块
            createMergeFrom(mergeBlock, sigs, sigList{i}, 'resovleSig', resovleSig);
        end
        
        fprintf('成功创建了%d个Merge模块\n', length(sigList));
        
    catch ME
        error('创建Merge模块时发生错误: %s', ME.message);
    end
end

