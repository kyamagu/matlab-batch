classdef LSFJobScheduler < BaseJobScheduler
  %LSFJOBSCHEDULER LSF batch job execution library.
  properties
    log_output = 'log/%J-%I.log' % Where LSF job output is written to.
    poll_interval = 10           % Interval in seconds to check if finished.
  end

  methods
    function this = LSFJobScheduler(varargin)
      %LSF Create an instance of LSF job scheduler.
      this = this@BaseJobScheduler(varargin{:});
      this.task_index_variable = 'LSB_JOBINDEX';
    end
  end

  methods (Static)
    function flag = isAvailable()
      %ISAVAILABLE Check if the job scheduler is available.
      [status, result] = system('which bsub');
      flag = status == 0;
    end
  end

  methods (Access = protected)
    submitJobs(this, matlab_script)
  end
end
