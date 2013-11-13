function submitJobs(this, matlab_script)
%SUBMITJOBS Submit batch jobs.
  for i = 1:this.shard_size
    this.logMessage('Batch %d / %d.', i, this.shard_size);
    setenv(this.task_index_variable, num2str(i));
    eval(matlab_script);
  end
end
