testproblem = 1
crossover_art = [0,1,2,3]
crossover_rate_art = [1,2,3]
offset = 0
wert_crossover_rate_konst_und_onefifth = 0.125:0.125:1.0
wert_crossover_rate_clegg = 0.0005:0.0010:0.0055
wert_offset = 0


for c_art in crossover_art
    for c_r_art in crossover_rate_art
        if c_r_art == 1 || c_r_art == 3
            range_crossover_rate = wert_crossover_rate_konst_und_onefifth
        elseif c_r_art == 2
            range_crossover_rate = wert_crossover_rate_clegg
        end

        for c_r_value in range_crossover_rate

            if c_art == 3
                c_r_art = 1
                c_r_value = 0.0
            end

            text = "#!/usr/bin/env bash
#SBATCH --partition=cpu
#SBATCH --time=4-0
#SBATCH --array=1-50
#SBATCH --output=/data/oc-compute03/ebertzci/OC-MasterThesis/output/%x-%A-%a.txt
#SBATCH --mem=4000
#SBATCH -c 2
#SBATCH --exclude=oc-compute03


echo \"SLURM_JOB_ID=\${SLURM_JOB_ID}\"
echo hostname=\$(hostname)


# Circumvent weird bug because of XDG_RUNTIME_DIR pointing to unwritable folder.
# Default mode of `srun` is to make all env vars available to the process so
# this is made available to `nix develop`.
export XDG_RUNTIME_DIR=~/XDG_RUNTIME_DIR
srun nix develop --impure --command bash -c \"
    just justfilefunc /data/oc-compute03/ebertzci/OC-MasterThesis/symbolicRegression/kozaMain.jl $testproblem $c_art $c_r_art $offset $c_r_value $wert_offset \$SLURM_ARRAY_TASK_ID
\"
            "

            nachkommastellen_crossover_rate = split(string(c_r_value), ".")[2]
            if nachkommastellen_crossover_rate == "0"
                nachkommastellen_crossover_rate = 1
            end

            if c_art == 3
                save_path = joinpath(["scripts",
                                        "kozaNoCrossover.sbatch"])
                mkpath(dirname(save_path))

            else

                save_path = joinpath(["scripts",
                                            "koza$c_art$(c_r_art)CRV$nachkommastellen_crossover_rate.sbatch"])
                mkpath(dirname(save_path))
            end

            # Öffne die Datei
            open(save_path, "w") do file
                write(file, text)
                close(file)
            end
        end
    end
end
