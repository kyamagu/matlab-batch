function submitJobs(this, matlab_script)
%SUBMITJOBS Submit batch jobs.
  cluster = parcluster('local');
  cluster.NumWorkers = this.shard_size;
  pool = parpool('local', this.shard_size);
  parfor i = 1:this.shard_size
    this.logMessage('Batch %d / %d.', i, this.shard_size);
    runJob(this, matlab_script, i);
  end
  delete(pool);
end

function runJob(this, matlab_script, i)
  setenv(this.task_index_variable, num2str(i));
  eval(matlab_script);
end
