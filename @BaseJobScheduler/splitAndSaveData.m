function this = splitAndSaveData(this, function_handle, data)
%SPLITANDSAVEDATA Split input data into shards.
  this.function_handle = function_handle;
  metadata_file = fullfile(this.work_directory, 'metadata.mat');
  save(metadata_file, 'this');
  input_files = fullfile(this.work_directory, ...
                         sprintf('input_*_of_%d.mat', this.shard_size));
  saveIntoMatfiles(input_files, data);
  % assert(exist(metadata_file, 'file') == 2);
  % for i = 1:this.shard_size
  %   input_file = ['input_', sprintf(this.data_file_pattern, i)];
  %   assert(exist(fullfile(this.work_directory, input_file), 'file') == 2);
  % end
end

function saveIntoMatfiles(filepattern, keys, values)
%SAVEINTOMATFILES Split value array or key-value array into files.
%
%    save_into_matfiles(filepattern, values)
%    save_into_matfiles(filepattern, keys, values)
%
% The function split a value array or a key-value pairs and saves into
% multiple MAT files. The first argument is a pattern of mat file names to
% save into. The keys and values must be a vector of any type. If they are
% not a vector, the function silently tries to flatten and save them.
%
% The filepattern must include `*_of_N` pattern where N is the number of
% split. `*` is substituted with split index.
%
% Example
%
%    mydata = num2cell(1:100);
%    saveIntoMatfiles('tmp/mydata/*_of_10.mat', mydata);
%
% See also loadFromMatfiles
  if nargin < 3
    values = keys;
    keys = reshape(1:numel(keys), size(values));
  end
  assert(numel(keys) == numel(values), ...
         'Unmatched number of keys and values.');
  assert(~isempty(keys), 'Empty input.');
  if ~isvector(keys), keys = keys(:); end
  if ~isvector(values), values = values(:); end

  [root_dir, filepattern, fileext] = fileparts(filepattern);
  assert(strcmp(fileext, '.mat'));
  if ~exist(root_dir, 'dir'), mkdir(root_dir); end
  filepattern = [filepattern, fileext];
  split_size = str2double(regexp(filepattern, ...
                                 '_of_(\d+)\.mat', 'tokens', 'once'));
  filepattern = strrep(filepattern, '*', ...
                       ['%0',num2str(floor(log10(split_size))+1),'d']);
  index = mod(0:numel(values)-1, split_size)' + 1;
  for i = 1:split_size
    file_content.keys = keys(index == i);
    file_content.values = values(index == i);
    filename = sprintf(fullfile(root_dir, filepattern), i);
    save(filename, '-struct', 'file_content');
  end
end
