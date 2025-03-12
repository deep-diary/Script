function cs = Model_Config()
% 在 27-Apr-2023 14:48:24 上生成的配置集的 MATLAB 函数
% MATLAB 版本: 9.11.0.1769968 (R2021b)

cs = Simulink.ConfigSet;

% 原始配置集版本: 21.1.0
if cs.versionCompare('21.1.0') < 0
    error('Simulink:MFileVersionViolation', '目标配置集的版本早于原始配置集。');
end

% 字符编码: UTF-8

% 不要更改以下命令的顺序。参数之间存在依存关系。
cs.set_param('Name', 'Configuration'); % 名称
cs.set_param('Description', ''); % 说明

% Original configuration set target is ert.tlc
cs.switchTarget('ert.tlc','');

cs.set_param('HardwareBoard', 'None');   % Hardware board

cs.set_param('TargetLang', 'C');   % 语言

cs.set_param('CodeInterfacePackaging', 'Nonreusable function');   % 代码接口打包

cs.set_param('GenerateAllocFcn', 'off');   % 使用动态内存分配进行模型初始化

cs.set_param('Solver', 'FixedStepDiscrete');   % 求解器

% Solver
cs.set_param('StartTime', '0.0');   % 开始时间
cs.set_param('StopTime', '10.0');   % 停止时间
cs.set_param('SampleTimeConstraint', 'Unconstrained');   % 周期性采样时间约束
cs.set_param('SolverType', 'Fixed-step');   % 类型
cs.set_param('SolverName', 'FixedStepDiscrete');   % 求解器
cs.set_param('FixedStep', 'auto');   % 固定步长(基础采样时间)
cs.set_param('ConcurrentTasks', 'off');   % 允许任务在目标上并发执行
cs.set_param('EnableMultiTasking', 'off');   % 将每个离散速率视为单独任务
cs.set_param('AllowMultiTaskInputOutput', 'off');   % 允许多个任务访问输入和输出
cs.set_param('PositivePriorityOrder', 'off');   % 优先级值越高，任务优先级越高
cs.set_param('AutoInsertRateTranBlk', 'off');   % 自动处理数据传输的速率转换

% Data Import/Export
cs.set_param('Decimation', '1');   % 抽取
cs.set_param('LoadExternalInput', 'off');   % 加载外部输入
cs.set_param('SaveFinalState', 'off');   % 保存最终状态
cs.set_param('LoadInitialState', 'off');   % 加载初始状态
cs.set_param('LimitDataPoints', 'off');   % 限制数据点
cs.set_param('SaveFormat', 'Dataset');   % 格式
cs.set_param('SaveOutput', 'on');   % 保存输出
cs.set_param('SaveState', 'off');   % 保存状态
cs.set_param('SignalLogging', 'on');   % 信号记录
cs.set_param('DSMLogging', 'on');   % 数据存储
cs.set_param('InspectSignalLogs', 'off');   % 在仿真数据检查器中记录所记录的工作区数据
cs.set_param('SaveTime', 'on');   % 保存时间
cs.set_param('ReturnWorkspaceOutputs', 'on');   % 单一仿真输出
cs.set_param('TimeSaveName', 'tout');   % 时间变量
cs.set_param('OutputSaveName', 'yout');   % 输出变量
cs.set_param('SignalLoggingName', 'logsout');   % 信号记录名称
cs.set_param('DSMLoggingName', 'dsmout');   % 数据存储记录名称
cs.set_param('ReturnWorkspaceOutputsName', 'out');   % 仿真输出变量
cs.set_param('LoggingToFile', 'off');   % 将数据集数据记录到文件
cs.set_param('DatasetSignalFormat', 'timeseries');   % 数据集信号格式
cs.set_param('LoggingIntervals', '[-inf, inf]');   % 记录间隔

% Optimization
cs.set_param('BlockReduction', 'on');   % 模块简化
cs.set_param('BooleanDataType', 'on');   % 将逻辑信号实现为布尔数据(而不是双精度数据)
cs.set_param('ConditionallyExecuteInputs', 'on');   % 条件输入分支执行
cs.set_param('DefaultParameterBehavior', 'Inlined');   % 默认参数行为
cs.set_param('UseDivisionForNetSlopeComputation', 'off');   % 使用除法进行定点净斜率计算
cs.set_param('GainParamInheritBuiltInType', 'off');   % 增益参数继承无损的内置整数类型
cs.set_param('UseFloatMulNetSlope', 'off');   % 使用浮点乘法处理净斜率校正
cs.set_param('InheritOutputTypeSmallerThanSingle', 'off');   % 继承小于单精度的浮点输出类型
cs.set_param('DefaultUnderspecifiedDataType', 'double');   % 数据类型未定时默认使用的类型
cs.set_param('UseSpecifiedMinMax', 'off');   % 使用指定的最小值和最大值进行优化
cs.set_param('InlineInvariantSignals', 'off');   % 内联不变信号
cs.set_param('OptimizationCustomize', 'off');   % 指定自定义优化
cs.set_param('OptimizationPriority', 'Balanced');   % 优先级
cs.set_param('OptimizationLevel', 'level2');   % 级别
cs.set_param('DataBitsets', 'off');   % 使用位集来存储布尔数据
cs.set_param('StateBitsets', 'off');   % 使用位集来存储状态配置
cs.set_param('LocalBlockOutputs', 'on');   % 启用局部模块输出
cs.set_param('EnableMemcpy', 'on');   % 使用 memcpy 进行向量赋值
cs.set_param('ExpressionFolding', 'on');   % 消除多余的局部变量(表达式折叠)
cs.set_param('BufferReuse', 'on');   % 重用局部模块输出
cs.set_param('OptimizeBlockIOStorage', 'on');   % 信号存储重用
cs.set_param('AdvancedOptControl', '');   % 禁用不兼容的优化
cs.set_param('BitwiseOrLogicalOp', 'Same as modeled');   % 用于表示 Bitwise Operator 和 Logical Operator 模块的运算符
cs.set_param('MemcpyThreshold', 64);   % Memcpy 阈值(字节)
cs.set_param('PassReuseOutputArgsAs', 'Individual arguments');   % 可重用子系统输出的传递方式
cs.set_param('PassReuseOutputArgsThreshold', 12);   % 子系统输出的最大参数个数
cs.set_param('RollThreshold', 5);   % 循环展开阈值
cs.set_param('ActiveStateOutputEnumStorageType', 'Native Integer');   % 自动创建的枚举的基本存储类型
cs.set_param('ZeroExternalMemoryAtStartup', 'off');   % 删除根级 I/O 零初始化
cs.set_param('ZeroInternalMemoryAtStartup', 'off');   % 删除内部数据零初始化
cs.set_param('InitFltsAndDblsToZero', 'off');   % 使用 memset 将浮点值和双精度值初始化为 0.0
cs.set_param('NoFixptDivByZeroProtection', 'off');   % 删除防止除法算术异常的代码
cs.set_param('EfficientFloat2IntCast', 'off');   % 删除从浮点到整数转换中将超出范围值绕回的代码
cs.set_param('EfficientMapNaN2IntZero', 'on');   % 删除涉及饱和处理的从浮点到整数转换中将 NaN 映射至零的代码
cs.set_param('LifeSpan', 'auto');   % 应用程序生命周期(天)
cs.set_param('MaxStackSize', 'Inherit from target');   % 最大堆栈大小(字节)
cs.set_param('BufferReusableBoundary', 'on');   % 可重用子系统的缓冲区
cs.set_param('SimCompilerOptimization', 'off');   % 编译器优化级别
cs.set_param('AccelVerboseBuild', 'off');   % 详细的加速编译
cs.set_param('UseRowMajorAlgorithm', 'off');   % 使用针对行优先数组布局优化的算法
cs.set_param('LabelGuidedReuse', 'off');   % 使用信号标签来指导缓冲区重用
cs.set_param('DenormalBehavior', 'GradualUnderflow');   % 在加速仿真模式下，可以使用 '下溢为零' 选项将非规范数下溢为零。
cs.set_param('EfficientTunableParamExpr', 'on');   % 从可调参数表达式中删除对超出范围值进行饱和处理的代码

% Diagnostics
cs.set_param('RTPrefix', 'error');   % 标识符的 "rt" 前缀
cs.set_param('ConsistencyChecking', 'none');   % 求解器数据不一致
cs.set_param('ArrayBoundsChecking', 'none');   % 超出数组边界
cs.set_param('SignalInfNanChecking', 'none');   % 模块输出为 Inf 或 NaN
cs.set_param('StringTruncationChecking', 'error');   % 字符串截断检查
cs.set_param('SignalRangeChecking', 'none');   % 仿真范围检查
cs.set_param('ReadBeforeWriteMsg', 'UseLocalSettings');   % 检测写前读
cs.set_param('WriteAfterWriteMsg', 'UseLocalSettings');   % 检测写后写
cs.set_param('WriteAfterReadMsg', 'UseLocalSettings');   % 检测读后写
cs.set_param('AlgebraicLoopMsg', 'warning');   % 代数环
cs.set_param('ArtificialAlgebraicLoopMsg', 'warning');   % 尽量减少代数环
cs.set_param('SaveWithDisabledLinksMsg', 'warning');   % 模块图包含禁用的库链接
cs.set_param('SaveWithParameterizedLinksMsg', 'warning');   % 模块图包含参数化库链接
cs.set_param('UnderspecifiedInitializationDetection', 'Simplified');   % 欠定初始化检测
cs.set_param('MergeDetectMultiDrivingBlocksExec', 'error');   % 检测在同一时间步执行的多个驱动模块
cs.set_param('SignalResolutionControl', 'UseLocalSettings');   % 信号解析
cs.set_param('BlockPriorityViolationMsg', 'warning');   % 模块优先级违规
cs.set_param('MinStepSizeMsg', 'warning');   % 最小步长违规
cs.set_param('TimeAdjustmentMsg', 'none');   % 采样命中时间调整
cs.set_param('MaxConsecutiveZCsMsg', 'error');   % 连续过零违规
cs.set_param('MaskedZcDiagnostic', 'warning');   % 遮蔽的过零点
cs.set_param('IgnoredZcDiagnostic', 'warning');   % 忽略的过零点
cs.set_param('SolverPrmCheckMsg', 'none');   % 自动求解器参数选择
cs.set_param('InheritedTsInSrcMsg', 'warning');   % 信号源模块指定 -1 采样时间
cs.set_param('MultiTaskDSMMsg', 'error');   % 多任务数据存储
cs.set_param('MultiTaskCondExecSysMsg', 'error');   % 多任务条件执行子系统
cs.set_param('MultiTaskRateTransMsg', 'error');   % 多任务数据传输
cs.set_param('SingleTaskRateTransMsg', 'none');   % 单任务数据传输
cs.set_param('TasksWithSamePriorityMsg', 'warning');   % 具有同等优先级的任务
cs.set_param('SigSpecEnsureSampleTimeMsg', 'warning');   % 强制应用 Signal Specification 模块指定的采样时间
cs.set_param('CheckMatrixSingularityMsg', 'none');   % 除以奇异矩阵
cs.set_param('IntegerOverflowMsg', 'warning');   % 溢出时绕回
cs.set_param('Int32ToFloatConvMsg', 'warning');   % 32 位整数到单精度浮点转换
cs.set_param('ParameterDowncastMsg', 'error');   % 检测向下转换
cs.set_param('ParameterOverflowMsg', 'error');   % 检测溢出
cs.set_param('ParameterUnderflowMsg', 'none');   % 检测下溢
cs.set_param('ParameterPrecisionLossMsg', 'warning');   % 检测精度损失
cs.set_param('ParameterTunabilityLossMsg', 'error');   % 检测可调性损失
cs.set_param('FixptConstUnderflowMsg', 'none');   % 检测下溢
cs.set_param('FixptConstOverflowMsg', 'none');   % 检测上溢
cs.set_param('FixptConstPrecisionLossMsg', 'none');   % 检测精度损失
cs.set_param('UnderSpecifiedDataTypeMsg', 'none');   % 未定数据类型
cs.set_param('UnnecessaryDatatypeConvMsg', 'none');   % 不必要的类型转换
cs.set_param('VectorMatrixConversionMsg', 'none');   % 向量/矩阵模块输入转换
cs.set_param('FcnCallInpInsideContextMsg', 'error');   % 上下文相关输入
cs.set_param('SignalLabelMismatchMsg', 'none');   % 信号标签不匹配
cs.set_param('UnconnectedInputMsg', 'warning');   % 未连接的模块输入端口
cs.set_param('UnconnectedOutputMsg', 'warning');   % 未连接的模块输出端口
cs.set_param('UnconnectedLineMsg', 'warning');   % 未连接的信号线
cs.set_param('SFcnCompatibilityMsg', 'none');   % 需要升级 S-Function
cs.set_param('FrameProcessingCompatibilityMsg', 'error');   % 模块行为取决于信号的帧状态
cs.set_param('UniqueDataStoreMsg', 'none');   % 重复数据存储名称
cs.set_param('BusObjectLabelMismatch', 'warning');   % 元素名称不匹配
cs.set_param('RootOutportRequireBusObject', 'warning');   % 根 Outport 模块上未指定总线对象
cs.set_param('AssertControl', 'UseLocalSettings');   % 模型验证模块的启用
cs.set_param('AllowSymbolicDim', 'on');   % 允许符号维度设定
cs.set_param('ModelReferenceIOMsg', 'none');   % 无效根 Inport/Outport 模块连接
cs.set_param('ModelReferenceVersionMismatchMessage', 'none');   % Model 模块版本不匹配
cs.set_param('ModelReferenceIOMismatchMessage', 'none');   % 端口和参数不匹配
cs.set_param('UnknownTsInhSupMsg', 'warning');   % 未指定采样时间的可继承性
cs.set_param('ModelReferenceDataLoggingMessage', 'warning');   % 不支持的数据记录
cs.set_param('ModelReferenceNoExplicitFinalValueMsg', 'none');   % 模型参数没有显式最终值
cs.set_param('ModelReferenceSymbolNameMessage', 'warning');   % 最大标识符长度不足
cs.set_param('ModelReferenceExtraNoncontSigs', 'error');   % 外部离散导数信号
cs.set_param('StateNameClashWarn', 'none');   % 状态名称冲突
cs.set_param('OperatingPointInterfaceChecksumMismatchMsg', 'warning');   % 工作点还原接口校验和不匹配
cs.set_param('NonCurrentReleaseOperatingPointMsg', 'error');   % 来自不同版本的工作点对象
cs.set_param('PregeneratedLibrarySubsystemCodeDiagnostic', 'warning');   % 缺失预生成的库子系统代码时的行为
cs.set_param('InitInArrayFormatMsg', 'warning');   % 初始状态为数组
cs.set_param('StrictBusMsg', 'ErrorLevel1');   % 总线信号视为向量
cs.set_param('BusNameAdapt', 'WarnAndRepair');   % 修复总线选择
cs.set_param('NonBusSignalsTreatedAsBus', 'none');   % 非总线信号被视为总线信号
cs.set_param('SFUnusedDataAndEventsDiag', 'warning');   % 未使用的数据、事件、消息和函数
cs.set_param('SFUnexpectedBacktrackingDiag', 'error');   % 意外回溯
cs.set_param('SFInvalidInputDataAccessInChartInitDiag', 'warning');   % 图初始化中无效的输入数据访问
cs.set_param('SFNoUnconditionalDefaultTransitionDiag', 'error');   % 不存在无条件默认转移
cs.set_param('SFTransitionOutsideNaturalParentDiag', 'warning');   % 自然父级外的转移
cs.set_param('SFUnreachableExecutionPathDiag', 'warning');   % 不可达的执行路径
cs.set_param('SFUndirectedBroadcastEventsDiag', 'warning');   % 无向事件广播
cs.set_param('SFTransitionActionBeforeConditionDiag', 'warning');   % 在条件动作之前指定的转移动作
cs.set_param('SFOutputUsedAsStateInMooreChartDiag', 'error');   % 对 Moore 图中输出的写前读
cs.set_param('SFTemporalDelaySmallerThanSampleTimeDiag', 'warning');   % 绝对时间时序值短于采样期间
cs.set_param('SFSelfTransitionDiag', 'warning');   % 叶状态的自环转移
cs.set_param('SFExecutionAtInitializationDiag', 'warning');   % 存在输入事件时禁用了 '初始化时执行'
cs.set_param('SFMachineParentedDataDiag', 'error');   % 使用了机器级别数据而非数据存储内存
cs.set_param('IntegerSaturationMsg', 'warning');   % 溢出时饱和
cs.set_param('AllowedUnitSystems', 'all');   % 允许的单位制
cs.set_param('UnitsInconsistencyMsg', 'warning');   % 单位不一致消息
cs.set_param('AllowAutomaticUnitConversions', 'on');   % 允许自动单位转换
cs.set_param('RCSCRenamedMsg', 'warning');   % 检测未重用的自定义存储类
cs.set_param('RCSCObservableMsg', 'warning');   % 检测具有多义性的自定义存储类最终值
cs.set_param('ForceCombineOutputUpdateInSim', 'off');   % 为代码生成和仿真合并输出和更新方法
cs.set_param('UnderSpecifiedDimensionMsg', 'none');   % 欠定维度
cs.set_param('DebugExecutionForFMUViaOutOfProcess', 'off');   % FMU Import 模块
cs.set_param('ArithmeticOperatorsInVariantConditions', 'error');   % 变体条件中存在算术运算
cs.set_param('VariantConditionMismatch', 'none');   % 信号的源和目标的变体条件不匹配

% Hardware Implementation
cs.set_param('ProdHWDeviceType', 'Intel->x86-64 (Windows64)');   % 生产设备供应商和类型
cs.set_param('ProdLongLongMode', 'off');   % 支持 long long
cs.set_param('ProdEqTarget', 'on');   % 测试硬件与生产硬件相同
cs.set_param('TargetPreprocMaxBitsSint', 32);   % C 预处理器中有符号整数的最大位数
cs.set_param('TargetPreprocMaxBitsUint', 32);   % C 预处理器中无符号整数的最大位数
cs.set_param('HardwareBoardFeatureSet', 'EmbeddedCoderHSP');   % 所选硬件板的功能集

% Model Referencing
cs.set_param('UpdateModelReferenceTargets', 'IfOutOfDateOrStructuralChange');   % 重新编译
cs.set_param('EnableRefExpFcnMdlSchedulingChecks', 'on');   % 为引用模型启用严格调度检查
cs.set_param('EnableParallelModelReferenceBuilds', 'off');   % 启用并行模型引用编译
cs.set_param('ParallelModelReferenceErrorOnInvalidPool', 'on');   % 对并行池执行一致性检查
cs.set_param('ModelReferenceNumInstancesAllowed', 'Multi');   % 每个顶层模型允许的实例总数
cs.set_param('PropagateVarSize', 'Infer from blocks in model');   % 传播可变大小信号的大小
cs.set_param('ModelDependencies', '');   % 模型依存关系
cs.set_param('ModelReferencePassRootInputsByReference', 'on');   % 为代码生成按值传递固定大小的标量根输入
cs.set_param('ModelReferenceMinAlgLoopOccurrences', 'off');   % 尽量减少出现代数环
cs.set_param('PropagateSignalLabelsOutOfModel', 'on');   % 将所有信号标签传播到模型之外
cs.set_param('SupportModelReferenceSimTargetCustomCode', 'off');   % 包含引用模型的自定义代码

% Simulation Target
cs.set_param('SimCustomSourceCode', '');   % 源文件
cs.set_param('SimUserSources', '');   % 源文件
cs.set_param('SimCustomHeaderCode', '');   % 头文件
cs.set_param('SimCustomInitializer', '');   % 初始化函数
cs.set_param('SimCustomTerminator', '');   % 终止函数
cs.set_param('SimReservedNameArray', []);   % 保留名称
cs.set_param('SimUserIncludeDirs', '');   % 包含目录
cs.set_param('SimUserLibraries', '');   % 库
cs.set_param('SimUserDefines', '');   % 宏定义
cs.set_param('SFSimEnableDebug', 'off');   % 允许在仿真期间设置断点
cs.set_param('SFSimEcho', 'on');   % 回显不带分号的表达式的输出
cs.set_param('SimCtrlC', 'on');   % 按 Ctrl+C 中断
cs.set_param('SimIntegrity', 'on');   % 启用内存完整性检查
cs.set_param('SimParseCustomCode', 'on');   % 导入自定义代码
cs.set_param('SimDebugExecutionForCustomCode', 'off');   % 在单独进程中仿真自定义代码
cs.set_param('SimAnalyzeCustomCode', 'off');   % 启用自定义代码分析
cs.set_param('SimGenImportedTypeDefs', 'off');   % 为导入的总线和枚举类型生成 typedef
cs.set_param('CompileTimeRecursionLimit', 50);   % MATLAB 函数的编译时递归限制
cs.set_param('EnableRuntimeRecursion', 'on');   % 为 MATLAB 函数启用运行时递归
cs.set_param('EnableImplicitExpansion', 'on');   % 在 MATLAB 函数中启用隐式扩展
cs.set_param('MATLABDynamicMemAlloc', 'off');   % MATLAB 函数中的动态内存分配
cs.set_param('LegacyBehaviorForPersistentVarInContinuousTime', 'off');   % 允许连续时间 MATLAB 函数写入初始化的持久变量
cs.set_param('CustomCodeFunctionArrayLayout', []);   % 例外(按函数)...
cs.set_param('DefaultCustomCodeFunctionArrayLayout', 'NotSpecified');   % 默认函数数组布局
cs.set_param('CustomCodeUndefinedFunction', 'FilterOut');   % 未定义函数的处理
cs.set_param('CustomCodeGlobalsAsFunctionIO', 'off');   % 启用全局变量作为函数接口
cs.set_param('DefaultCustomCodeDeterministicFunctions', 'None');   % 确定性函数
cs.set_param('SimHardwareAcceleration', 'generic');   % 硬件加速
cs.set_param('GPUAcceleration', 'off');   % GPU 加速
cs.set_param('SimTargetLang', 'C');   % 语言

% Code Generation
cs.set_param('RemoveResetFunc', 'on');   % 删除 reset 函数
cs.set_param('ExistingSharedCode', '');   % 现有共享代码
cs.set_param('TLCOptions', '');   % TLC 命令行选项
cs.set_param('GenCodeOnly', 'on');   % 仅生成代码
cs.set_param('PackageGeneratedCodeAndArtifacts', 'off');   % 代码和工件打包
cs.set_param('PostCodeGenCommand', '');   % 代码生成之后执行的命令
cs.set_param('GenerateReport', 'on');   % 创建代码生成报告
cs.set_param('RTWVerbose', 'on');   % 详细编译
cs.set_param('RetainRTWFile', 'off');   % 保留 .rtw 文件
cs.set_param('ProfileTLC', 'off');   % 探查 TLC
cs.set_param('TLCDebug', 'off');   % 生成代码时启动 TLC 调试器
cs.set_param('TLCCoverage', 'off');   % 生成代码时启动 TLC 覆盖率报告
cs.set_param('TLCAssert', 'off');   % 启用 TLC 断言
cs.set_param('RTWUseSimCustomCode', 'off');   % 使用与仿真目标相同的自定义代码设置
cs.set_param('CustomSourceCode', '');   % 源文件
cs.set_param('CustomHeaderCode', '');   % 头文件
cs.set_param('CustomInclude', '');   % 包含目录
cs.set_param('CustomSource', '');   % 源文件
cs.set_param('CustomLibrary', '');   % 库
cs.set_param('CustomDefine', '');   % 宏定义
cs.set_param('CustomBLASCallback', '');   % 自定义 BLAS 库回调
cs.set_param('CustomLAPACKCallback', '');   % 自定义 LAPACK 库回调
cs.set_param('CustomFFTCallback', '');   % 自定义 FFT 库回调
cs.set_param('CustomInitializer', '');   % 初始化函数
cs.set_param('CustomTerminator', '');   % 终止函数
cs.set_param('Toolchain', 'Automatically locate an installed toolchain');   % 工具链
cs.set_param('BuildConfiguration', 'Faster Builds');   % 编译配置
cs.set_param('IncludeHyperlinkInReport', 'on');   % 代码到模型
cs.set_param('LaunchReport', 'on');   % 自动打开报告
cs.set_param('PortableWordSizes', 'off');   % 启用可移植字长
cs.set_param('CreateSILPILBlock', 'None');   % 创建模块
cs.set_param('CodeExecutionProfiling', 'off');   % 测量任务执行时间
cs.set_param('CodeProfilingInstrumentation', 'off');   % 测量函数执行时间
cs.set_param('CodeCoverageSettings', coder.coverage.CodeCoverageSettings([],'off','off','None'));   % 第三方工具
cs.set_param('SILDebugging', 'off');   % 对 SIL 启用源代码级别调试
cs.set_param('GenerateTraceInfo', 'on');   % 模型到代码
cs.set_param('GenerateTraceReport', 'on');   % 已消除模块/虚拟模块
cs.set_param('GenerateTraceReportSl', 'on');   % 可追溯的 Simulink 模块
cs.set_param('GenerateTraceReportSf', 'on');   % 可追溯的 Stateflow 对象
cs.set_param('GenerateTraceReportEml', 'on');   % 可追溯的 MATLAB 函数
cs.set_param('GenerateWebview', 'off');   % 生成模型 Web 视图
cs.set_param('GenerateCodeMetricsReport', 'off');   % 生成静态代码指标
cs.set_param('GenerateCodeReplacementReport', 'off');   % 摘要显示哪些模块触发了代码替换
cs.set_param('ObjectivePriorities', []);   % 优先目标
cs.set_param('CheckMdlBeforeBuild', 'Off');   % 生成代码前检查模型
cs.set_param('GenerateComments', 'on');   % 包括注释
cs.set_param('ForceParamTrailComments', 'on');   % 为 '模型默认' 存储类提供详细注释
cs.set_param('CommentStyle', 'Auto');   % 注释样式
cs.set_param('IgnoreCustomStorageClasses', 'off');   % 忽略自定义存储类
cs.set_param('IgnoreTestpoints', 'off');   % 忽略测试点信号
cs.set_param('MaxIdLength', 31);   % 最大标识符长度
cs.set_param('ShowEliminatedStatement', 'on');   % 显示已消除模块
cs.set_param('OperatorAnnotations', 'on');   % 运算符注释
cs.set_param('SimulinkDataObjDesc', 'on');   % Simulink 数据对象说明
cs.set_param('SFDataObjDesc', 'on');   % Stateflow 对象说明
cs.set_param('MATLABFcnDesc', 'off');   % MATLAB 用户注释
cs.set_param('MangleLength', 1);   % 最小修饰长度
cs.set_param('SharedChecksumLength', 8);   % 共享校验和长度
cs.set_param('CustomSymbolStrGlobalVar', '$R$N$M');   % 全局变量
cs.set_param('CustomSymbolStrType', '$N$R$M_T');   % 全局类型
cs.set_param('CustomSymbolStrField', '$N$M');   % 全局类型的字段名称
cs.set_param('CustomSymbolStrFcn', '$R$N$M$F');   % 子系统方法
cs.set_param('CustomSymbolStrFcnArg', 'rt$I$N$M');   % 子系统方法参数
cs.set_param('CustomSymbolStrBlkIO', 'rtb_$N$M');   % 局部模块输出变量
cs.set_param('CustomSymbolStrTmpVar', '$N$M');   % 局部临时变量
cs.set_param('CustomSymbolStrMacro', '$R$N$M');   % 常量宏
cs.set_param('CustomSymbolStrEmxType', 'emxArray_$M$N');   % EMX 数组类型标识符格式
cs.set_param('CustomSymbolStrEmxFcn', 'emx$M$N');   % EMX 数组工具函数标识符格式
cs.set_param('CustomUserTokenString', '');   % 自定义标记文本
cs.set_param('EnableCustomComments', 'off');   % 自定义注释(仅限 MPT 对象)
cs.set_param('DefineNamingRule', 'None');   % #define 命名
cs.set_param('ParamNamingRule', 'None');   % 参数命名
cs.set_param('SignalNamingRule', 'None');   % 信号命名
cs.set_param('InsertBlockDesc', 'on');   % Simulink 模块说明
cs.set_param('InsertPolySpaceComments', 'off');   % 插入 Polyspace 注释
cs.set_param('SimulinkBlockComments', 'on');   % Simulink 模块注释
cs.set_param('StateflowObjectComments', 'off');   % Stateflow 对象注释
cs.set_param('BlockCommentType', 'BlockPathComment');   % 使用以下方式追溯至模型
cs.set_param('MATLABSourceComments', 'off');   % MATLAB 源代码作为注释
cs.set_param('InternalIdentifier', 'Shortened');   % 系统生成的标识符
cs.set_param('InlinedPrmAccess', 'Literals');   % 将标量内联参数生成为
cs.set_param('ReqsInCode', 'off');   % 在模块注释中包含需求描述
cs.set_param('UseSimReservedNames', 'off');   % 使用与仿真目标相同的保留名称
cs.set_param('ReservedNameArray', []);   % 保留名称
cs.set_param('EnumMemberNameClash', 'error');   % 重复的枚举成员名称
cs.set_param('TargetLibSuffix', '');   % 应用于目标库名称的后缀
cs.set_param('TargetPreCompLibLocation', '');   % 预编译的库位置
cs.set_param('TargetLangStandard', 'C99 (ISO)');   % 语言标准
cs.set_param('CodeReplacementLibrary', 'None');   % 代码替换库
cs.set_param('UtilityFuncGeneration', 'Auto');   % 共享代码放置
cs.set_param('MultiwordTypeDef', 'System defined');   % 多字类型定义
cs.set_param('DynamicStringBufferSize', 256);   % 动态大小字符串的缓冲区大小(以字节为单位)
cs.set_param('GenerateFullHeader', 'on');   % 生成完整文件前注
cs.set_param('InferredTypesCompatibility', 'off');   % 在 rtwtypes.h 中创建预处理器指令。
cs.set_param('GenerateSampleERTMain', 'on');   % 生成示例主程序
cs.set_param('IncludeMdlTerminateFcn', 'on');   % 需要终止函数
cs.set_param('GRTInterface', 'off');   % 经典调用接口
cs.set_param('CombineOutputUpdateFcns', 'on');   % 单一输出/更新函数
cs.set_param('CombineSignalStateStructs', 'off');   % 组合信号/状态结构体
cs.set_param('MatFileLogging', 'off');   % MAT 文件记录
cs.set_param('SuppressErrorStatus', 'off');   % 删除实时模型数据结构体中的错误状态字段
cs.set_param('IncludeFileDelimiter', 'Auto');   % #include 文件分隔符
cs.set_param('ERTCustomFileBanners', 'on');   % 启用自定义文件前注
cs.set_param('SupportAbsoluteTime', 'on');   % 支持绝对时间
cs.set_param('PurelyIntegerCode', 'off');   % 支持浮点数
cs.set_param('SupportNonFinite', 'on');   % 支持非有限数
cs.set_param('SupportComplex', 'on');   % 支持复数
cs.set_param('SupportContinuousTime', 'off');   % 支持连续时间
cs.set_param('SupportNonInlinedSFcns', 'off');   % 支持非内联 S-Function
cs.set_param('RemoveDisableFunc', 'off');   % 删除 disable 函数
cs.set_param('SupportVariableSizeSignals', 'off');   % 支持可变大小信号
cs.set_param('ParenthesesLevel', 'Nominal');   % 括号繁简级别
cs.set_param('CastingMode', 'Nominal');   % 强制转换模式
cs.set_param('ArrayLayout', 'Column-major');   % 数组布局
cs.set_param('LUTObjectStructOrderExplicitValues', 'Size,Breakpoints,Table');   % 显式值设定的 LUT 对象结构体顺序
cs.set_param('LUTObjectStructOrderEvenSpacing', 'Size,Breakpoints,Table');   % 均匀间距设定的 LUT 对象结构体顺序
cs.set_param('ERTHeaderFileRootName', '$R$E');   % 头文件
cs.set_param('ERTSourceFileRootName', '$R$E');   % 源文件
cs.set_param('ERTFilePackagingFormat', 'Modular');   % 文件打包格式
cs.set_param('ERTDataFileRootName', '$R_data');   % 数据文件
cs.set_param('InstructionSetExtensions', {'SSE2'});   % Leverage target hardware instruction set extensions
cs.set_param('GlobalDataDefinition', 'Auto');   % 数据定义
cs.set_param('GlobalDataReference', 'Auto');   % 数据声明
cs.set_param('ExtMode', 'off');   % 外部模式
cs.set_param('ExtModeTransport', 0);   % 传输层
cs.set_param('ExtModeMexFile', 'ext_comm');   % MEX 文件名
cs.set_param('ExtModeStaticAlloc', 'off');   % 静态内存分配
cs.set_param('EnableUserReplacementTypes', 'off');   % 替换生成代码中的数据类型名称
cs.set_param('ConvertIfToSwitch', 'on');   % 将 if-elseif-else 模式转换为 switch-case 语句
cs.set_param('ERTCustomFileTemplate', 'example_file_process.tlc');   % 文件自定义模板
cs.set_param('ERTDataHdrFileTemplate', 'ert_code_template.cgt');   % 头文件模板
cs.set_param('ERTDataSrcFileTemplate', 'ert_code_template.cgt');   % 源文件模板
cs.set_param('RateTransitionBlockCode', 'Inline');   % Rate Transition 模块代码
cs.set_param('ERTHdrFileBannerTemplate', 'ert_code_template.cgt');   % 头文件模板
cs.set_param('ERTSrcFileBannerTemplate', 'ert_code_template.cgt');   % 源文件模板
cs.set_param('EnableDataOwnership', 'off');   % 使用数据对象的所有者信息来确定数据定义的放置
cs.set_param('ExtModeIntrfLevel', 'Level1');   % 外部模式接口级别
cs.set_param('ExtModeMexArgs', '');   % MEX 文件参数
cs.set_param('ExtModeTesting', 'off');   % 外部模式测试
cs.set_param('IndentSize', '2');   % 缩进大小
cs.set_param('IndentStyle', 'K&R');   % 缩进样式
cs.set_param('NewlineStyle', 'Default');   % 换行样式
cs.set_param('MaxLineWidth', 80);   % 最大行宽
cs.set_param('ParamTuneLevel', 10);   % 参数调整级别
cs.set_param('EnableSignedLeftShifts', 'on');   % 将二次幂的乘法替换为有符号按位移位
cs.set_param('EnableSignedRightShifts', 'on');   % 允许有符号整数右移
cs.set_param('PreserveExpressionOrder', 'off');   % 保留表达式中的操作数顺序
cs.set_param('PreserveExternInFcnDecls', 'on');   % 在函数声明中保留 extern 关键字
cs.set_param('PreserveIfCondition', 'off');   % 保留 if 语句中的条件表达式
cs.set_param('RTWCAPIParams', 'off');   % 生成用于参数的 C API
cs.set_param('RTWCAPIRootIO', 'off');   % 生成用于根级 I/O 的 C API
cs.set_param('RTWCAPISignals', 'off');   % 生成用于信号的 C API
cs.set_param('RTWCAPIStates', 'off');   % 生成用于状态的 C API
cs.set_param('SignalDisplayLevel', 10);   % 信号显示级别
cs.set_param('SuppressUnreachableDefaultCases', 'on');   % 禁止为 Stateflow switch 语句生成不可达的默认 case
cs.set_param('TargetOS', 'BareBoardExample');   % 目标操作系统
cs.set_param('BooleanTrueId', 'true');   % 布尔 true 标识符
cs.set_param('BooleanFalseId', 'false');   % 布尔 false 标识符
cs.set_param('MaxIdInt32', 'MAX_int32_T');   % 32 位整数最大值标识符
cs.set_param('MinIdInt32', 'MIN_int32_T');   % 32 位整数最小值标识符
cs.set_param('MaxIdUint32', 'MAX_uint32_T');   % 32 位无符号整数最大值标识符
cs.set_param('MaxIdInt16', 'MAX_int16_T');   % 16 位整数最大值标识符
cs.set_param('MinIdInt16', 'MIN_int16_T');   % 16 位整数最小值标识符
cs.set_param('MaxIdUint16', 'MAX_uint16_T');   % 16 位无符号整数最大值标识符
cs.set_param('MaxIdInt8', 'MAX_int8_T');   % 8 位整数最大值标识符
cs.set_param('MinIdInt8', 'MIN_int8_T');   % 8 位整数最小值标识符
cs.set_param('MaxIdUint8', 'MAX_uint8_T');   % 8 位无符号整数最大值标识符
cs.set_param('MaxIdInt64', 'MAX_int64_T');   % 64 位整数最大值标识符
cs.set_param('MinIdInt64', 'MIN_int64_T');   % 64 位整数最小值标识符
cs.set_param('MaxIdUint64', 'MAX_uint64_T');   % 64 位无符号整数最大值标识符
cs.set_param('TypeLimitIdReplacementHeaderFile', '');   % 类型限值标识符替换头文件
cs.set_param('DSAsUniqueAccess', 'off');   % 将每个数据存储模块实现为唯一访问点

% Simulink Coverage
cs.set_param('CovModelRefEnable', 'off');   % Record coverage for referenced models
cs.set_param('RecordCoverage', 'off');   % Record coverage for this model
cs.set_param('CovEnable', 'off');   % Enable coverage analysis

% HDL Coder
try 
	cs_componentCC = hdlcoderui.hdlcc;
	cs_componentCC.createCLI();
	cs.attachComponent(cs_componentCC);
catch ME
	warning('Simulink:ConfigSet:AttachComponentError', '%s', ME.message);
end