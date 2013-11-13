function data = loadAndCollectData(this)
%LOADANDCOLLECTDATA Load output data and merge.
  for i = 1:numel(this.shard_size)
    output_file = ['output_', sprintf(this.data_file_pattern, i)];
    assert(exist(fullfile(this.work_directory, output_file), 'file') == 2, ...
           'Missing input file: %s.', output_file);
  end
  output_files = fullfile(this.work_directory, ...
                          sprintf('output_*_of_%d.mat', this.shard_size));
  data = loadFromMatfiles(output_files);
end

function [keys, values] = loadFromMatfiles(filepattern)
%LOADFROMMATFILES Load data from split matfiles.
%
%    values = loadFromMatfiles(filepattern)
%    [keys, values] = loadFromMatfiles(filepattern)
% 
% The function loads data saved into split matfiles using
% saveIntoMatfiles(). The filepattern must include `*_of_N` pattern
% where N is the number of splits.
%
% Example
%
%    mydata = loadFromMatfiles('tmp/mydata/*_of_10.mat');
%
% See also saveIntoMatfiles 
  files = dir(filepattern);
  if isempty(files)
    error('Missing input files: %s', filepattern);
  end
  assert(numel(files) == ...
         cellfun(@str2double,...
                 regexp(files(1).name, '\d+_of_(\d+)\.mat', 'tokens')));
  root_dir = fileparts(filepattern);
  keys = cell(size(files));
  values = cell(size(files));
  for i = 1:numel(files)
    filename = fullfile(root_dir, files(i).name);
    file_content = load(filename, 'keys', 'values');
    keys{i} = file_content.keys;
    values{i} = file_content.values;
  end
  dim_to_cat = (all(cellfun(@(x)size(x, 1), keys) == 1)) + 1;
  keys = cat(dim_to_cat, keys{:});
  dim_to_cat = (all(cellfun(@(x)size(x, 1), values) == 1)) + 1;
  values = cat(dim_to_cat, values{:});
  [keys, order] = sort(keys);
  values = values(order);
  if nargout < 2, keys = values; end
end
