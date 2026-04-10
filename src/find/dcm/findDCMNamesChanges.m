function changes = findDCMNamesChanges(filepath1, filepath2)
%FINDDCMNAMESCHANGES 比较两个DCM文件的参数差异
%   CHANGES = FINDDCMNAMESCHANGES(FILEPATH1, FILEPATH2) 比较两个DCM文件，
%   找出参数的添加、删除和修改
%
%   输入参数:
%      filepath1    - 基准DCM文件的完整路径
%      filepath2    - 比较DCM文件的完整路径
%
%   输出参数:
%      changes      - 包含参数变化的结构体，具有以下字段:
%                     .added   - 在文件2中添加的参数列表
%                     .removed - 在文件2中删除的参数列表
%                     .common  - 两个文件中共有的参数列表
%
%   示例:
%      diff = findDCMNamesChanges('HY11_PCMU_Tm_OTA3_V6010212_All.DCM', 'HY11_PCMU_Tm_OTA3_V6050327_All.DCM');
%      disp('Added parameters:');
%      disp(diff.added);
%      disp('Removed parameters:');
%      disp(diff.removed);
%
%   参见: FINDDCMNAMES, FINDDCMPARAM
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20250320

    % 检查文件是否存在
    if ~exist(filepath1, 'file')
        error('基准文件不存在: %s', filepath1);
    end
    if ~exist(filepath2, 'file')
        error('比较文件不存在: %s', filepath2);
    end
    
    % 获取两个文件的参数名称
    try
        names1 = findDCMNames(filepath1);
        names2 = findDCMNames(filepath2);
    catch ME
        error('获取DCM参数名称时出错: %s', ME.message);
    end
    
    % 转换为集合以便进行集合操作
    set1 = unique(names1);
    set2 = unique(names2);
    
    % 找出添加和删除的参数
    [inBoth, idx1, idx2] = intersect(set1, set2, 'stable');
    added = setdiff(set2, set1, 'stable');
    removed = setdiff(set1, set2, 'stable');
    
    % 构建结果结构体
    changes = struct();
    changes.added = added;
    changes.removed = removed;
    changes.common = inBoth;
    
    % 显示结果摘要
    fprintf('比较结果摘要:\n');
    fprintf('  共有参数: %d\n', length(inBoth));
    fprintf('  添加参数: %d\n', length(added));
    fprintf('  删除参数: %d\n', length(removed));

    % 显示具体的added和removed参数
    fprintf('------------------------------:\n');
    fprintf('具体变化信息:\n');
    if ~isempty(added)
        fprintf('  添加参数:\n');
        for i = 1:length(added)
            fprintf('    %s\n', added{i});
        end
    end
    fprintf('-------------:\n');
    if ~isempty(removed)
        fprintf('  删除参数:\n'); 
        for i = 1:length(removed)
            fprintf('    %s\n', removed{i});
        end
    end
    fprintf('------------------------------:\n');
end
