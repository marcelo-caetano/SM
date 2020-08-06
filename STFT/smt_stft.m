function [fft_frame,nsample,dc,cframe] = stft(wav,framelen,hop,nfft,winflag,cfwflag,normflag,zphflag)
%STFT Short-Time Fourier Transform.
%   [ST,NSAMPLE,DC,CFR] = STFT(S,M,H,NFFT,WINFLAG,CFWFLAG) returns the
%   STFT of signal S calculated with a WINFLAG window of length M and a
%   hop size of H samples. NFFT is the size of the FFT. Each frame is
%   zero-padded if NFFT > M. If NFFT < M, NFFT defaults to the first power
%   of two that satisfies NFFT > M (otherwise FFT truncates the frames
%   resulting in loss of information).
%
%   CFWFLAG is a string that determines the sample corresponding to the
%   center of the first analysis window. CFWFLAG can be ONE, HALF, or NHALF.
%
%   STFT returns the short-term FFT in the columns of ST, the original
%   length NSAMPLE of S (in samples), the dc value DC of S, and the array
%   CFR with the samples corresponding to the center of the frames of ST.
%
%   [ST,NSAMPLE,DC,CFR] = STFT(S,M,H,NFFT,WINFLAG,CFWFLAG,NORMFLAG) returns
%   ST calculated with a normalized window (normalized energy). NORMFLAG =
%   TRUE normalizes and NORMFLAG = FALSE does not. When NORMFLAG is not
%   specified, it defaults to TRUE.
%
%   [ST,NSAMPLE,DC,CFR] = STFT(S,M,H,NFFT,WINFLAG,CFWFLAG,NORMFLAG,ZPHFLAG)
%   returns ST calculated with a zero-phase window. ZPHFLAG = TRUE uses a
%   zero-phase window and ZPHFLAG = FALSE does not. When ZPHFLAG is not
%   specified, it defaults to TRUE.

% 2016 M Caetano; Revised 2019
% 2020 MCaetano SMT 0.1.1 (Revised)
% 2020 MCaetano SMT 0.2.0 (Revised)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK INPUT ARGUMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check number of input arguments
narginchk(6,8);

% Check number of output arguments
nargoutchk(0,4);

if nargin == 6
    
    normflag = true;
    
    zphflag = true;
    
elseif nargin == 7
    
    zphflag = true;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make time frames
[time_frame,nsample,dc,cframe] = sof(wav,framelen,hop,winflag,cfwflag,normflag);

% zero pad
if nfft > framelen
    
    zpad_frame = flexpad(time_frame,nfft);
    
elseif nfft == framelen
    
    zpad_frame = time_frame;
    
else
    
    nfft = fftsize(framelen);
    
    zpad_frame = flexpad(time_frame,nfft);
    
end

% zero phase
if zphflag
    
    zph_frame = lp2zp(zpad_frame,framelen);
    
else
    
    zph_frame = zpad_frame;
    
end

% Calculate the Short-Time Fourier Transform
fft_frame = fft(zph_frame,nfft);

end