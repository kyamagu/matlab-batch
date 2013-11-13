function logMessage(this, varargin)
%LOGMESSAGE Display a log message.
%
%    scheduler.logMessage(format, param1, param2, ...)
%
% LOGMESSAGE displays a log message using the printf arguments. LOGMESSAGE
% takes format string followed by parameters for substituion.
%
% Example
% -------
%
%    scheduler.logMessage('Processing %d of %d.', index, length);
%
% See also fprintf
  if this.log_enabled
    fprintf('[%s] ', datestr(now));
    fprintf(varargin{:});
    fprintf('\n');
  end
end
