task_id = parse(Int, ENV["SLURM_ARRAY_TASK_ID"])

save_path = joinpath(["test$task_id.txt"])

mkpath(dirname(save_path))

# Öffne die Datei
open(save_path, "w") do file
    write(file, "This is a test file for task $task_id")
    close(file)
end