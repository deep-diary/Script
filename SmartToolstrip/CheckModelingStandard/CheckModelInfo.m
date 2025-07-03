function CheckModelInfo
%% Check 是否添加Moedel Info模块
    obj = find_system(bdroot,'MaskDisplayString','Model Info');
    if isempty(obj)
        warning('请添加 "Moedl Infor" 模块来记录变更历史 ');
    end
end