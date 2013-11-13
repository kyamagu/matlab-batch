function submitJobs(this, matlab_script)
%SUBMITJOBS Submit batch jobs.
  submission_command = buildSubmissionCommand(this, matlab_script);
  this.logMessage('%s', submission_command);
  system(submission_command);
end

function command = buildSubmissionCommand(this, matlab_script)
%GETSUBMISSIONCOMMAND Build a job submission command.
  script_file = fullfile(this.work_directory, 'main.m');
  writeStringToFile(matlab_script, script_file);
  if ~exist(this.log_directory, 'dir')
    mkdir(this.log_directory);
  end
  command = sprintf(...
      ['qsub -sync y -j y -o %s -cwd -t 1-%d -V -b y -shell n -i %s %s '...
       '%s/bin/matlab -nodisplay -singleCompThread'], ...
      this.log_directory, ...
      this.shard_size, ...
      script_file, ...
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
