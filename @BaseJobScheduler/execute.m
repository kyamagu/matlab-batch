function data = execute(this, function_handle, data, varargin)
%EXECUTE Execute a function to an array input in batch.
%
%    output_data = scheduler.execute(function_handle, input_data, ...)
%
% EXECUTE() splits input_data into smaller batches and applies a function to
% each batch using the scheduler. Additional arguments after the input data are
% passed to the function handle in each job.
%
% See also createJobScheduler
  error(nargchk(3, inf, nargin, 'struct'));
  assert(isscalar(this), 'Not a scalar.');
  assert(ischar(function_handle) || ...
         isa(function_handle, 'function_handle'), ...
         'Not a string nor a function handle.');
  assert(this.shard_size > 0);
  if isempty(data)
    return;
  end

  this.work_directory = ensureWorkDirectory(this);
  this.data_file_pattern = getDataFilePattern(this.shard_size);
  this.extra_arguments = varargin;
  try
    this.logMessage('Splitting input data into %d batches.', this.shard_size);
    this = this.splitAndSaveData(function_handle, data);
    this.logMessage('Launching batch jobs.');
    this.submitJobs(getMatlabScript(this));
    this.logMessage('Collecting results.')
    data = this.loadAndCollectData();
    removeWorkDirectory(this);
  catch exception
    this.logMessage(exception.getReport());
    removeWorkDirectory(this);
    rethrow(exception);
  end
end

function work_directory = ensureWorkDirectory(this)
%ENSUREWORKDIRECTORY Ensure a work directory for this task.
  work_directory = tempname(this.temporary_directory);
  while exist(work_directory, 'dir')
    work_directory = tempname(this.temporary_directory);
  end
  this.logMessage('Creating a work directory: %s.', work_directory);
  mkdir(work_directory);
end

function data_file_pattern = getDataFilePattern(shard_size)
%GETDATAFILEPATTERN Get a pattern of input/output file names.
  data_file_pattern = sprintf(['%%0', ...
                               num2str(floor(log10(shard_size)) + 1), ...
                               'd_of_%d.mat'], ...
                              shard_size);
end

function matlab_script = getMatlabScript(this)
%GETMATLABSCRIPT Get a matlab script to execute in each job.
  matlab_script = sprintf('%s.startJob(''%s'')', ...
                          class(this), ...
                          this.work_directory);
end

function removeWorkDirectory(this)
%REMOVEWORKDIRECTORY Destroy the work directory if existing.
  if exist(this.work_directory, 'dir')
    this.logMessage('Deleting a work directory: %s.', this.work_directory);
    rmdir(this.work_directory, 's');
  end
end
