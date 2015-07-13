classdef SGEJobScheduler < BaseJobScheduler
  %SGEJOBSCHEDULER SGE batch job execution library.
  properties
    log_directory = 'log' % Where SGE job output is written to.
  end

  methods
    function this = SGEJobScheduler(varargin)
      %SGEJOBSCHEDULER Create an instance of SGE job scheduler.
      this = this@BaseJobScheduler(varargin{:});
      this.task_index_variable = 'SGE_TASK_ID';
    end
  end

  methods (Static)
    function flag = isAvailable()
      %ISAVAILABLE Check if the job scheduler is available.
      [status, result] = system('which qsub');
      flag = status == 0;
    end
  end

  methods (Access = protected)
    submitJobs(this, matlab_script)
  end
end
