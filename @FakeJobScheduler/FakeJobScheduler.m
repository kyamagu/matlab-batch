classdef FakeJobScheduler < BaseJobScheduler
  %FAKEJOBSCHEDULER Fake batch job execution library.
  methods
    function this = FakeJobScheduler(varargin)
      %FAKEJOBSCHEDULER Create an instance of a fake job scheduler.
      this = this@BaseJobScheduler(varargin{:});
    end
  end

  methods (Static)
    function flag = isAvailable()
      %ISAVAILABLE Check if the job scheduler is available.
      flag = true;
    end
  end

  methods (Access = protected)
    submitJobs(this, matlab_script)
  end
end
