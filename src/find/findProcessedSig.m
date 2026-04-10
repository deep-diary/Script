function [sigMono, sigDu, sigMonoAll, sigNoNA] = findProcessedSig(sig, NAStr)
%%
% 目的: 对信号进行相关处理，并返回处理后的信号。
% 输入：
%       Null
% 返回：
%   sigMono: 不重复的信号，
%   sigDu: 重复的信号，
%   sigMonoAll: 全部不重复信号，
%   sigNoNA: 去掉NA后的信号， 但这里还是有看可能包含重复的信号，
% 范例： [sigMono, sigDu, sigMonoAll, sigNoNA] = findProcessedSig(sig, NAStr)
% 作者： Blue.ge
% 日期： 20231108
%%
    clc
    %% 查找输入重复的信号
    sigDu = {};     % 有重复的信号
    sigMonoAll = {};  % 包含重复的信号
    sigNoNA = {};   % 去掉NA后的信号， 但这里还是有看可能包含重复的信号
    
    for i=1:length(sig)
        if strcmp(sig{i},NAStr)
            continue
        end
        sigNoNA = [sigNoNA, sig{i}];
        if ~ismember(sig{i},sigMonoAll)
            sigMonoAll = [sigMonoAll,sig{i}];
        else
            sigDu = [sigDu, sig{i}];
        end
    end
    sigDu = unique(sigDu,'stable');
    sigMono = setdiff(sigMonoAll, sigDu);
end
