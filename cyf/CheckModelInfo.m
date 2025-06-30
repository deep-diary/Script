function CheckModelInfo
%% Check 是否添加Moedel Infor模块
    obj = find_system(bdroot,'MaskDisplayString','Model Info');
    if isempty(obj)
        warning('Please add "Moedl Infor" Block to record change history ');
    end
end