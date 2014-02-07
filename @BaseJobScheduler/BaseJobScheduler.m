classdef BaseJobScheduler
  %BASEJOBSCHEDULER Abstract batch job execution library.
  properties
    temporary_directory = 'tmp' % Location of the temporary directory.
    shard_size = 100            % Size of the batch.
    log_enabled = true          % Flag to enable/disable logging message.
  end

  properties (SetAccess = protected)
    task_index_variable = 'JOB_INDEX' % Replace this with the actual name.
    extra_arguments
    work_directory
    function_handle
    data_file_pattern
  end

  methods
    function this = BaseJobScheduler(varargin)
      %BASEJOBSCHEDULER Create an instance the job scheduler.
      this = getOptions(this, varargin{:});
    end

    function flag = isAvailable()
      %ISAVAILABLE Check if the scheduler is available.
      flag = false; % Override this method in a subclass.
    end

    data = execute(this, function_handle, data, varargin)
    logMessage(this, varargin)
  end

  methods (Abstract, Access = protected)
    %SUBMITJOBS Submit batch jobs. Must block until jobs finish.
    submitJobs(this, matlab_script)
  end

  methods (Access = protected)
    this = getOptions(this, varargin)
    task_index = getTaskIndex(this)
    data = loadAndCollectData(this)
    this = splitAndSaveData(this, function_handle, data)
  end

  methods (Static, Hidden)
    startJob(work_directory)
  end
end
