function startJob(work_directory)
%STARTJOB Start a single batch job.
  this = loadMetadata(work_directory);
  [input_file, output_file] = getInputOutput(this);
  this.logMessage('Input: %s', input_file);
  this.logMessage('Output: %s', output_file);
  load(input_file, 'keys', 'values');
  values = feval(this.function_handle, values, this.extra_arguments{:});
  keys = handleInconsistentKeys(keys, values);
  save(output_file, 'keys', 'values');
end

function this = loadMetadata(work_directory)
%LOADMETADATA Retrieve a job metadata.
  metadata_file = fullfile(work_directory, 'metadata.mat');
  assert(exist(metadata_file, 'file') == 2, 'Missing %s.', metadata_file);
  load(metadata_file, 'this');
end

function [input_file, output_file] = getInputOutput(this)
%GETINPUTOUTPUT Obtain input and output files.
  data_file_pattern = sprintf(this.data_file_pattern, this.getTaskIndex());
  input_file = fullfile(this.work_directory, ['input_', data_file_pattern]);
  output_file = fullfile(this.work_directory, ['output_', data_file_pattern]);
  assert(exist(input_file, 'file') == 2);
end

function keys = handleInconsistentKeys(keys, values)
%HANDLEINCONSISTENTKEYS Modify inconsistent number of keys.
  if numel(keys) ~= numel(values)
    warning('Output size is %d while input size was %d.', ...
            numel(values), ...
            numel(keys));
    if numel(keys) > numel(values)
      keys = keys(1:numel(values));
    else
      % Just give an index of values.
      keys = reshape(1:numel(values), size(values));
    end
  end
end
