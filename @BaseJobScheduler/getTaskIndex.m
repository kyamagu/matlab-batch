function task_index = getTaskIndex(this)
%GETTASKINDEX Get an index of the current task.
  task_index = str2double(getenv(this.task_index_variable));
  task_index(isnan(task_index)) = 1;
end
