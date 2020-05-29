function [sinusoidal,partials,amplitudes,frequencies,new_amp,new_freq,new_phase] = ...
    sinusoidal_resynthesis_PI(amp,freq,ph,delta,framelen,hop,fs,...
    nsample,cframe,maxnpeak,cfwflag,dispflag)
%SINUSOIDAL_RESYNTHESIS_PI Summary of this function goes here
%   Detailed explanation goes here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK INPUT ARGUMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check number of input arguments
narginchk(11,12);

% Check number of output arguments
nargoutchk(0,7);

if nargin == 11
    
    dispflag = false;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nframe = length(cframe);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ZERO-PADDING AT THE BEGINNING AND END OF SIGNAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch lower(cfwflag)
    
    case 'one'
        
        % SHIFT is the number of zeros before CW
        shift = lhw(framelen);
        
    case 'half'
        
        % SHIFT is the number of zeros before CW
        shift = 0;
        
    case 'nhalf'
        
        % SHIFT is the number of zeros before CW
        shift = framelen;
        
    otherwise
        
        warning(['SMT:invalidFlag: ', 'Undefined window flag.\n'...
            'CFWFLAG specifies the center of the first analysis window\n'...
            'CFWFLAG must be ONE, HALF, or NHALF. Value entered was %d'...
            'Using default value ONE'],cfwflag);
        
        % SHIFT is the number of zeros before CW
        shift = lhw(framelen);
end

% Preallocate for NFRAME
new_amp = cell(1,nframe);
new_freq = cell(1,nframe);
new_phase = cell(1,nframe);

% Preallocate
sinusoidal = zeros(nsample+2*shift,1);
partials = zeros(nsample+2*shift,maxnpeak);
amplitudes = zeros(nsample+2*shift,maxnpeak);
frequencies = zeros(nsample+2*shift,maxnpeak);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYNTHESIS BY PARAMETER INTERPOLATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iframe = 1:nframe-1
    
    if dispflag
        
        fprintf(1,'PI synthesis between frame %d and %d\n',iframe,iframe+1);
        
    end
    
    if iframe == 1 && cframe(iframe) > 1
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FROM CFRAME-LHW(WINSIZE) TO CFRAME (LEFT HALF OF FIRST WINDOW)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Parameter interpolation & Additive resynthesis (with linear ph estimation)
        [sin_model,partial_model,amp_model,freq_model] = parameter_interpolation...
            (amp{iframe},amp{iframe},freq{iframe},freq{iframe},ph{iframe} -...
            (freq{iframe}*2*pi*lhw(framelen)/fs),ph{iframe},lhw(framelen),fs);
        
        % Concatenation into final synthesis vector
        sinusoidal(cframe(iframe)-lhw(framelen)+shift:cframe(iframe)-1+shift) = sin_model;
        partials(cframe(iframe)-lhw(framelen)+shift:cframe(iframe)-1+shift,1:size(partial_model,2)) = partial_model;
        amplitudes(cframe(iframe)-lhw(framelen)+shift:cframe(iframe)-1+shift,1:size(amp_model,2)) = amp_model;
        frequencies(cframe(iframe)-lhw(framelen)+shift:cframe(iframe)-1+shift,1:size(freq_model,2)) = freq_model/(2*pi);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FROM CFRAME TO CFRAME+HOPSIZE (RIGHT HALF OF FIRST WINDOW)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        [new_amp{iframe},new_amp{iframe+1},new_freq{iframe},new_freq{iframe+1},new_phase{iframe},new_phase{iframe+1}] = peak_matching_tracks...
            (amp{iframe},amp{iframe+1},freq{iframe},freq{iframe+1},ph{iframe},ph{iframe+1},delta,hop,fs);
        
        % Parameter interpolation & Additive resynthesis
        [sin_model,partial_model,amp_model,freq_model] = parameter_interpolation...
            (new_amp{iframe},new_amp{iframe+1},new_freq{iframe},new_freq{iframe+1},...
            new_phase{iframe},new_phase{iframe+1},hop,fs);
        
        % Concatenation into final synthesis vector
        sinusoidal(cframe(iframe)+shift:cframe(iframe+1)-1+shift) = sin_model;
        partials(cframe(iframe)+shift:cframe(iframe+1)-1+shift,1:size(partial_model,2)) = partial_model;
        amplitudes(cframe(iframe)+shift:cframe(iframe+1)-1+shift,1:size(amp_model,2)) = amp_model;
        frequencies(cframe(iframe)+shift:cframe(iframe+1)-1+shift,1:size(freq_model,2)) = freq_model/(2*pi);
        
    elseif iframe == nframe-1 && cframe(iframe) < nsample
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FROM CFRAME TO CFRAME+RHW(WINSIZE) (RIGHT HALF OF LAST WINDOW)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Parameter interpolation & Additive resynthesis (with linear ph estimation)
        [sin_model,partial_model,amp_model,freq_model] = parameter_interpolation...
            (amp{iframe},amp{iframe},freq{iframe},freq{iframe},ph{iframe},ph{iframe}+(freq{iframe}*2*pi*(nsample-cframe(iframe)+1)/fs),...
            nsample-cframe(iframe)+1,fs);
        
        % Concatenation into final synthesis vector
        sinusoidal(cframe(iframe)+shift:nsample+shift) = sin_model;
        partials(cframe(iframe)+shift:nsample+shift,1:size(partial_model,2)) = partial_model;
        amplitudes(cframe(iframe)+shift:nsample+shift,1:size(amp_model,2)) = amp_model;
        frequencies(cframe(iframe)+shift:nsample+shift,1:size(freq_model,2)) = freq_model/(2*pi);
        
    else
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FROM CFRAME TO CFRAME+HOPSIZE (BETWEEN CENTER OF CONSECUTIVE WINDOWS)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Peak matching
        [new_amp{iframe},new_amp{iframe+1},new_freq{iframe},new_freq{iframe+1},new_phase{iframe},new_phase{iframe+1}] = ...
            peak_matching_tracks(amp{iframe},amp{iframe+1},freq{iframe},freq{iframe+1},ph{iframe},ph{iframe+1},delta,hop,fs);
        
        % Parameter interpolation & Additive resynthesis
        [sin_model,partial_model,amp_model,freq_model] = parameter_interpolation...
            (new_amp{iframe},new_amp{iframe+1},new_freq{iframe},new_freq{iframe+1},...
            new_phase{iframe},new_phase{iframe+1},hop,fs);
        
        % Concatenation into final synthesis vector
        sinusoidal(cframe(iframe)+shift:cframe(iframe+1)-1+shift) = sin_model;
        partials(cframe(iframe)+shift:cframe(iframe+1)-1+shift,1:size(partial_model,2)) = partial_model;
        amplitudes(cframe(iframe)+shift:cframe(iframe+1)-1+shift,1:size(amp_model,2)) = amp_model;
        frequencies(cframe(iframe)+shift:cframe(iframe+1)-1+shift,1:size(freq_model,2)) = freq_model/(2*pi);
        
    end
    
end

% Remove zero-padding
sinusoidal = sinusoidal(1+shift:nsample+shift);
partials = partials(1+shift:nsample+shift,:);
amplitudes = amplitudes(1+shift:nsample+shift,:);
frequencies = frequencies(1+shift:nsample+shift,:);

end
