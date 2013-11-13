function submitJobs(this, matlab_script)
%SUBMITJOBS Submit batch jobs.
  submission_command = buildSubmissionCommand(this, matlab_script);
  job_id = scheduleJobs(this, submission_command);
  % Since bsub cannot specify -K option with array jobs, we'll have a loop to
  % wait until all jobs are done.
  pause(this.poll_interval);
  while ~isJobFinished(this, job_id)
    pause(this.poll_interval);
  end
end

function command = buildSubmissionCommand(this, matlab_script)
%GETSUBMISSIONCOMMAND Build a job submission command.
  script_file = fullfile(this.work_directory, 'main.m');
  writeStringToFile(matlab_script, script_file);
  if ~exist(fileparts(this.log_output), 'dir')
    mkdir(fileparts(this.log_output));
  end
  command = sprintf(...
      ['bsub -cwd %s -J matlab[1-%d] -i %s -o %s %s '...
       '%s/bin/matlab -nodisplay -singleCompThread'], ...
      pwd, ...
      this.shard_size, ...
      script_file, ...
      this.log_output, ...
      this.extra_options, ...
      matlabroot);
end

function writeStringToFile(string, file_name)
%WRITESTRINGTOFILE Write input string to a text file.
  fid = fopen(file_name, 'w');
  try
    fprintf(fid, '%s', string);
    fclose(fid);
  catch exception
    if fid > -1
      fclose(fid);
    end
    rethrow(exception);
  end
end

function job_id = scheduleJobs(this, submission_command)
%SCHEDULEJOBS Schedule a job in the queue.
  this.logMessage('%s', submission_command);
  [status, result] = system(submission_command);
  fprintf('%s', result);
  assert(status == 0, result);
  job_id = regexp(result, '<(\d+)>', 'tokens', 'once');
  job_id = job_id{:};
end

function flag = isJobFinished(this, job_id)
%ISJOBFINISHED Check if an array job is finished.
  [status, result] = system(sprintf('bjobs %s', job_id));
  assert(status == 0);
  % Find a status list.
  job_statuses = regexp(result, ...
                        [job_id, '\s+', getenv('USER'), '\s+', '(\S+)'], ...
                        'tokens');
  job_statuses = [job_statuses{:}];
  % This check doesn't work since 'DONE' or 'EXIT' status will go away after some time.
  %assert(numel(job_statuses) == this.shard_size);
  is_job_done = strcmp(job_statuses, 'DONE');
  is_job_exit = strcmp(job_statuses, 'EXIT');
  this.logMessage('%d / %d done', nnz(is_job_done), numel(job_statuses));
  flag = all(is_job_done);

  if any(is_job_exit & ~is_job_done)
    kill_command = sprintf('bkill %s', job_id);
    this.logMessage(kill_command);
    [status, result] = system(kill_command);
    fprintf('%s', result);
    error('Found %d unexpected job terminations in job %s.', ...
          nnz(is_job_exit), ...
          job_id);
  end
end
