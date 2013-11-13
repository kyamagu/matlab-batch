function testFakeJobScheduler
%TESTFAKEJOBSCHEDULER
  testNumericInputOutput;
  testCellInputOutput;
end

function testNumericInputOutput
%TESTNUMERICINPUTOUTPUT
  scheduler = FakeJobScheduler('shard_size', 10);
  input_data = 1:100;
  output_data = scheduler.execute(@plus, input_data, 100);
  assert(all(output_data == (input_data + 100)));
end

function testCellInputOutput
%TESTNUMERICINPUTOUTPUT
  scheduler = FakeJobScheduler('shard_size', 10);
  input_data = arrayfun(@(x)['input-', num2str(x)], ...
                        1:100, ...
                        'UniformOutput', false);
  output_data = scheduler.execute(@strrep, input_data, 'input', 'output');
  expected_output_data = strrep(input_data, 'input', 'output');
  assert(iscellstr(output_data));
  assert(numel(output_data) == numel(expected_output_data));
  for i = 1:numel(input_data)
    assert(strcmp(output_data{i}, expected_output_data{i}));
  end
end