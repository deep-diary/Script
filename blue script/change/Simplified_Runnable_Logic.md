# 简化的 Runnable 处理逻辑

## 新的处理逻辑

现在 `changeAutosarDict` 函数的 Runnable 处理逻辑更加简洁明了：

### 核心逻辑

1. **如果指定了 Runnable 参数**：

   - 检查 Runnable 是否包含 `_Step`
   - 如果包含 `_Step`，将其替换为指定的名称
   - 如果不包含 `_Step`，使用规则替换

2. **如果没有指定 Runnable 参数**：
   - 使用规则替换（去掉后缀，将 `_Step` 改为 `_Runnable`）

## 代码实现

```matlab
for i = 1:length(runnables)
    symbol = get(arProps, runnables{i}, 'symbol');

    if ~isempty(runnable)
        % 如果提供了Runnable参数，将包含_Step的标识改为设定值
        if contains(symbol, '_Step')
            if ischar(runnable) || isstring(runnable)
                % 单个Runnable名称
                symbol = char(runnable);
            elseif iscell(runnable) && i <= length(runnable)
                % 多个Runnable名称，按顺序使用
                symbol = char(runnable{i});
            else
                % 如果提供的名称数量不足，使用规则替换
                symbol = strrep(symbol, suffix, '');
                symbol = strrep(symbol, '_Step', '_Runnable');
            end
        else
            % 如果不包含_Step，使用规则替换
            symbol = strrep(symbol, suffix, '');
            symbol = strrep(symbol, '_Step', '_Runnable');
        end
    else
        % 如果没有提供Runnable参数，使用规则替换
        symbol = strrep(symbol, suffix, '');
        symbol = strrep(symbol, '_Step', '_Runnable');
    end

    set(arProps, runnables{i}, 'symbol', symbol);
end
```

## 处理示例

### 示例 1：包含 \_Step 的 Runnable

**输入**：

- 原始 Runnable：`PrkgClimaActvMgrArch_Step`
- 指定名称：`CCMLoad_DiagRunnable`

**处理**：

```matlab
changeAutosarDict('PrkgClimaActvMgrArch', 'Runnable', 'CCMLoad_DiagRunnable');
```

**结果**：

- `PrkgClimaActvMgrArch_Step` → `CCMLoad_DiagRunnable`

### 示例 2：不包含 \_Step 的 Runnable

**输入**：

- 原始 Runnable：`PrkgClimaActvMgrArch_Init`
- 指定名称：`CustomName`

**处理**：

```matlab
changeAutosarDict('PrkgClimaActvMgrArch', 'Runnable', 'CustomName');
```

**结果**：

- `PrkgClimaActvMgrArch_Init` → `PrkgClimaActvMgr_Init`（使用规则替换）

### 示例 3：混合情况

**输入**：

- 原始 Runnables：
  - `PrkgClimaActvMgrArch_Init`（不包含 `_Step`）
  - `PrkgClimaActvMgrArch_Step`（包含 `_Step`）
- 指定名称：`CCMLoad_DiagRunnable`

**处理**：

```matlab
changeAutosarDict('PrkgClimaActvMgrArch', 'Runnable', 'CCMLoad_DiagRunnable');
```

**结果**：

- `PrkgClimaActvMgrArch_Init` → `PrkgClimaActvMgr_Init`（规则替换）
- `PrkgClimaActvMgrArch_Step` → `CCMLoad_DiagRunnable`（指定名称）

### 示例 4：多个包含 \_Step 的 Runnable

**输入**：

- 原始 Runnables：
  - `PrkgClimaActvMgrArch_Step1`
  - `PrkgClimaActvMgrArch_Step2`
- 指定名称：`{'MainRunnable', 'DiagRunnable'}`

**处理**：

```matlab
changeAutosarDict('PrkgClimaActvMgrArch', 'Runnable', {'MainRunnable', 'DiagRunnable'});
```

**结果**：

- `PrkgClimaActvMgrArch_Step1` → `MainRunnable`
- `PrkgClimaActvMgrArch_Step2` → `DiagRunnable`

## 优势

1. **逻辑清晰**：只处理包含 `_Step` 的 Runnable
2. **精确控制**：可以精确指定需要修改的 Runnable 名称
3. **向后兼容**：不指定参数时行为与之前完全一致
4. **灵活性强**：支持单个或多个 Runnable 名称指定
5. **错误处理**：名称数量不足时自动使用规则替换

## 使用建议

1. **明确目标**：只对包含 `_Step` 的 Runnable 使用指定名称
2. **名称匹配**：确保提供的名称数量与包含 `_Step` 的 Runnable 数量匹配
3. **测试验证**：在生产环境使用前，先在小范围测试验证效果
4. **文档记录**：记录使用的 Runnable 名称，便于后续维护

## 实际应用

在 `appCreateCcmArch.m` 中的应用：

```matlab
% 从组件名称生成Runnable名称
if endsWith(componentName, 'Arch')
    runnableName = strrep(componentName, 'Arch', 'Runnable');
else
    runnableName = [componentName, 'Runnable'];
end

% 传递Runnable名称，只影响包含_Step的Runnable
changeAutosarDict(componentName, 'RunnablePeriod', runnablePeriod, 'Runnable', runnableName);
```

这样，只有包含 `_Step` 的 Runnable 会被替换为指定的名称，其他 Runnable 保持规则替换的行为。
