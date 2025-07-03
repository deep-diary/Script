function result = findAlgebraicLoops(path, varargin)
    result = Simulink.BlockDiagram.getAlgebraicLoops(path);
    if isempty(result)
        fprintf('No algebraic loops found in %s\n', path);
    else
        fprintf('Algebraic loops found in %s\n', path);
    end
end