function sumfactor = colasum(wintype)
%COLASUM COLA constant for different windows.
%   SUM = colasum(WINTYPE) returns SUM for a window of type WINTYPE.
%
%   SUM = COLA(R) for hop size R = M/DEN, expressed as a fraction of the
%   window size M. DEN depends on WINTYPE. Type WHICHWIN(WINTYPE) for the
%   names of the different windows supported.
%
%   See also COLADEN, ISCOLA, COLAHS, ALLCOLAHS, OL2HS

%   WINDOW_TYPE
%
%   1 - Rectangular
%   2 - Bartlett
%   3 - Hann
%   4 - Hanning
%   5 - Blackman
%   6 - Blackman-Harris
%   7 - Hamming

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK FUNCTION ARGUMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of input arguments
narginchk(1,1);

% Number of output arguments
nargoutchk(1,1);

% Validate input
validateattributes(wintype,{'single','double'},{'scalar','>',0,'<',8});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BODY OF FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sumfactor = infowin(wintype,'sum');

end
