BATCH
=====

Distributed Matlab job execution library.

 * High-level Matlab wrapper over computing grid infrastracture.
 * No requirement for the Matlab parallel processing toolbox.

Currently following job schedulers are supported.

 * Sun Grid Engine (`qsub`)
 * Platform LSF (`bsub`)
 * Fake scheduler for debugging

Example
-------

The following code shows an example of distributing 100 data points to 5
distributed jobs. Note the function handle `@(x)x+1` takes a vector with
100 / 5 = 20 elements at each distributed job.

    addpath('/path/to/matlab-batch');
    scheduler = createJobScheduler('ShardSize', 5);
    input_data = 1:100;
    output_data = scheduler.execute(@(x)x+1, input_data);
    disp(output_data);

The function can be a char or a function handle. The function must take a
single input argument of split data and return a corresponding output for
the input data.  You may pass any array to the scheduler, as long as the
input and the output contains the same number of elements. To process a
complex input, use a struct array instead of a numeric array.

    function exampleBatchUsage()
    %EXAMPLEBATCHUSAGE Another usage example.
      scheduler = SGEJobScheduler('ShardSize', 5, ...
                                  'ExtraOptions', '-l hostname=host1');
      input_data = struct('index', num2cell(1:100));
      additional_input = 'some flag';
      output_data = scheduler.execute(@processBatch, ...
                                      input_data, ...
                                      additional_input);
    end

    function data = processBatch(data, varargin)
    %PROCESSBATCH This function takes a split batch of input data.
      [data.result] = deal([]);
      for i = 1:numel(data)
        data(i).result = complicatedFunction(data(i), varargin{:});
      end
    end

Tips
----

 * Be careful about the data size. If you assign large data to each element of
   the output, you will run out of memory. To generate large data in the
   output, save them in an external file and return an array of file names.

TODO
----

 * Add a wrapper for Matlab parallel processing toolbox.
