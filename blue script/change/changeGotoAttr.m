function changeGotoAttr(path, varargin)
%CHANGEGOTOATTR 修改Goto/From模块的属性
%   CHANGEGOTOATTR(PATH) 修改指定路径下所有Goto/From模块的属性
%   CHANGEGOTOATTR(PATH, 'Type', TYPE) 指定要修改的模块类型
%   CHANGEGOTOATTR(PATH, 'Type', TYPE, PROPERTY, VALUE) 设置指定属性
%
%   输入参数:
%       path - 模块路径，可以是模块路径、'gcs'或'bdroot'
%       varargin - 名称-值对参数:
%           'Type' - 模块类型，可选值:
%               'goto' - 只修改Goto模块
%               'from' - 只修改From模块
%               'both' - 修改Goto和From模块（默认）
%           PROPERTY - 要修改的属性名称
%           VALUE - 属性的新值
%           特殊属性:
%               'wid' - 模块宽度
%               'height' - 模块高度
%
%   示例:
%       % 修改所有Goto/From模块的标签位置
%       changeGotoAttr(gcs, 'ShowName', 'off')
%
%       % 只修改Goto模块的标签位置
%       changeGotoAttr(gcs, 'Type', 'goto', 'ShowName', 'off')
%
%       % 修改多个属性
%       changeGotoAttr(gcs, 'Type', 'from', 'ShowName', 'off', 'TagVisibility', 'global')
%
%       % 修改模块尺寸
%       changeGotoAttr(gcs, 'Type', 'goto', 'wid', 30, 'height', 14)
%
%   作者: Blue.ge
%   日期: 20250609

    % 初始化参数
    type = 'both';
    properties = {};
    values = {};
    wid = [];
    height = [];

    % 处理输入参数
    i = 1;
    while i <= length(varargin)
        if strcmpi(varargin{i}, 'Type')
            if i + 1 <= length(varargin)
                type = lower(varargin{i+1});
                i = i + 2;
            else
                warning('Type参数缺少值，使用默认值''both''');
                i = i + 1;
            end
        elseif strcmpi(varargin{i}, 'wid')
            if i + 1 <= length(varargin)
                wid = varargin{i+1};
                i = i + 2;
            else
                warning('wid参数缺少值，忽略此参数');
                i = i + 1;
            end
        elseif strcmpi(varargin{i}, 'height')
            if i + 1 <= length(varargin)
                height = varargin{i+1};
                i = i + 2;
            else
                warning('height参数缺少值，忽略此参数');
                i = i + 1;
            end
        else
            if i + 1 <= length(varargin)
                properties{end+1} = varargin{i};
                values{end+1} = varargin{i+1};
                i = i + 2;
            else
                warning('忽略未配对的参数: %s', varargin{i});
                break;
            end
        end
    end

    % 验证type参数
    if ~ismember(type, {'goto', 'from', 'both'})
        error('Type参数必须是''goto''、''from''或''both''');
    end

    % 获取所有Goto/From模块
    if strcmp(type, 'both')
        blocks = find_system(path, 'FollowLinks', 'off', 'LookUnderMasks', 'off', ...
            'BlockType', 'Goto');
        blocks = [blocks; find_system(path, 'FollowLinks', 'off', 'LookUnderMasks', 'off', ...
            'BlockType', 'From')];
    elseif strcmp(type, 'goto')
        blocks = find_system(path, 'FollowLinks', 'off', 'LookUnderMasks', 'off', ...
            'BlockType', 'Goto');
    else % from
        blocks = find_system(path, 'FollowLinks', 'off', 'LookUnderMasks', 'off', ...
            'BlockType', 'From');
    end

    % 修改属性
    for i = 1:length(blocks)
        % 处理尺寸属性
        if ~isempty(wid) || ~isempty(height)
            try
                pos = get_param(blocks{i}, 'Position');
                if ~isempty(wid)
                    pos(3) = pos(1) + wid;
                end
                if ~isempty(height)
                    pos(4) = pos(2) + height;
                end
                set_param(blocks{i}, 'Position', pos);
            catch ME
                warning('无法设置模块 %s 的尺寸: %s', blocks{i}, ME.message);
            end
        end

        % 处理其他属性
        for j = 1:length(properties)
            try
                set_param(blocks{i}, properties{j}, values{j});
            catch ME
                warning('无法设置模块 %s 的属性 %s: %s', blocks{i}, properties{j}, ME.message);
            end
        end
    end
end 