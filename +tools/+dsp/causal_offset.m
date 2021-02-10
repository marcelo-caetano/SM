function offset = causal_offset(framelen,causalflag)
%CAUSAL_OFFSET Frame offset for causal processing.
%   OFFSET = CAUSAL_OFFSET(FRAMELEN,CAUSALFLAG)
%
%   See also CAUSAL_ZEROPAD

switch lower(causalflag)
    
    case 'causal'
        
        offset = -(tools.dsp.rightwin(framelen) + tools.dsp.leftwin(framelen));
        
    case 'non'
        
        offset = 0;
        
    case 'anti'
        
        offset = tools.dsp.rightwin(framelen) + 1 + tools.dsp.leftwin(framelen) + 1;
        
    otherwise
        
        warning('SMT:NUMFRAME:invalidFlag',...
            ['CAUSALFLAG must be CAUSAL, NON or ANTI.\n'...
            'CAUSALFLAG entered was %s.\n'
            'Using default CAUSALFLAG = NON'],...
            causalflag);
        
        offset = 0;
        
end


end