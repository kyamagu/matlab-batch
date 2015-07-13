classdef ParforJobScheduler < BaseJobScheduler
  %PARFORJOBSCHEDULER PARFOR batch job execution library.
  methods
    function this = ParforJobScheduler(varargin)
      %PARFORJOBSCHEDULER Create an instance of a fake job scheduler.
      this = this@BaseJobScheduler(varargin{:});
    end
  end

  methods (Static)
    function flag = isAvailable()
      %ISAVAILABLE Check if the job scheduler is available.
      flag = exist('parpool', 'builtin') > 0;
    end
  end

  methods (Access = protected)
    submitJobs(this, matlab_script)
  end
end
