%% 删除单个输入端口及其对应的模块
deletedSig = delInportRelLineAndBlock(gcb, 'Goto')

%% 删除单个输出端口及其对应的模块
deletedSig = delOutportRelLineAndBlock(gcb, 'Ground')

%% delSigOnLine: 可选参数： 'both'，'inport'， 'outport'
delSigOnLine(gcb);

%% delSigOnLineAll: mode 可选参数： 'both'，'inport'， 'outport'
delSigOnLineAll('mode','both')

%% autosar.api.delete
autosar.api.delete(gcs);

%% delGcsAll 删除gcs中所有内容
delGcsAll()

%% 删除当前路径下所有无用信号线
delUselessLine(gcs)

%% 删除当前路径那些无用的端口，比如接ground 和 terminator的，还有接的那些block已经注释掉了的
[validInports, validOutports] = delUselessPort(gcs)