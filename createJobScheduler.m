function scheduler = createJobScheduler(varargin)
%CREATEJOBSCHEDULER Create any job scheduler available in the system.
%
%    scheduler = createJobScheduler(...)
%
% CREATEJOBSCHEDULER() creates a new instance of one of job schedulers
% available in the platform. If none of the distributed job scheduler is
% available, a FakeJobScheduler instance is returned.
%
% Arguments to this function is passed to the constructor of the job scheduler
% instance.
%
% Example
% -------
%
%    scheduler = createJobScheduler('shard_size', 10);
%    output_data = scheduler.execute(@myFunction, input_data);
%
  root_directory = fileparts(mfilename('fullpath'));
  subclasses = findSubclasses(root_directory, 'BaseJobScheduler');
  % Fake scheduler must be the last.
  subclasses = [setdiff(subclasses, 'FakeJobScheduler'), 'FakeJobScheduler'];

  available_index = cellfun(@(name)feval([name,'.isAvailable']), subclasses);
  assert(any(available_index), 'No scheduler is available.');
  scheduler = feval(subclasses{find(available_index, 1)}, varargin{:});
end

function subclasses = findSubclasses(root_directory, base_class)
%FINDSUBCLASSES Find subclasses of a base class in a specified directory.
  class_directories = dir(fullfile(root_directory, '@*'));
  class_names = strrep({class_directories.name}, '@', '');
  index = cellfun(@(name)isSubclass(name, base_class), class_names);
  subclasses = class_names(index);
end

function flag = isSubclass(file_name, base_class)
%ISSUBCLASS Check if a given file is a subclass of the base class.
  flag = exist(file_name, 'class') && ...
         ismember(base_class, superclasses(file_name));
end