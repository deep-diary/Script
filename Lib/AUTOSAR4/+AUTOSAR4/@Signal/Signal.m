classdef Signal < AUTOSAR.Signal
%AUTOSAR4.Parameter  Class definition.

%   Copyright 2013 The MathWorks, Inc.
  
  methods
    %---------------------------------------------------------------------------
    function setupCoderInfo(h)
      % Use custom storage classes from this package
      useLocalCustomStorageClasses(h, 'AUTOSAR4');
    end
    
    function h = Signal(varargin)
        %SIGNAL  Class constructor.
        
        % Call superclass constructor with variable arguments
        h@AUTOSAR.Signal(varargin{:});
        h.CoderInfo.StorageClass = 'Custom';
        h.CoderInfo.CustomStorageClass = 'Global';        
    end % end of constructor

  end % methods
end % classdef

