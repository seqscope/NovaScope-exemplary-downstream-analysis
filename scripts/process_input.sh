#!/bin/bash

process_input_data_and_params() {
    # Loading the input_data_and_params
    if [ $# -ne 1 ]; then
        echo -e "Usage: process_input_data_and_params <path_to_file>"
        return 1
    fi

    local input_data_and_params="$1"

    if [ -s "$input_data_and_params" ]; then
        source "$input_data_and_params"
    else
        echo -e "Error: File '$input_data_and_params' not found or is empty."
        return 2
    fi

    # Checking variables
    # - Mandatory (minimal)
    local mandatory_vars=("input_dir" "output_dir" "prefix" "train_model")
    for var in "${mandatory_vars[@]}"; do
        if [ -z "${!var}" ]; then  
            echo "Error: Mandatory variable '$var' is not defined or is empty."
            return 2
        fi
    done

    # - Optional
    threads=${threads:-1}
    # Log
    echo -e "#=== ENVIRONMENT ===#"
    echo -e "py39_env: $py39_env"
    echo -e "py310_env: $py310_env"
    echo -e "ficture: $ficture"
    echo -e "execution_mode: $execution_mode"
    echo -e "threads: $threads"
    echo -e "ref_geneinfo: $ref_geneinfo"

    echo -e "\n#=== INPUT/OUTPUT ===#"
    echo -e "input_dir: $input_dir"
    echo -e "output_dir: $output_dir"
    echo -e "prefix: $prefix"
    echo -e "train_model: $train_model"
    
    echo -e "\n#=== PARAMETERS ===#"
    echo -e "solo feature: $sf"
    echo -e "training width: $tw"
    echo -e "number of factor: $nf"
    echo -e "training epoch: $ep"
    echo -e "projection width: $pw"
    echo -e "anchor distance: $ar"

    # seed
    if [[ $train_model == "LDA" ]]; then
        if [[ -z $seed ]]; then
            seed=$(date +%s | cut -c 1-10)
            echo "seed: $seed (Random seed is assigned)"
        else
            echo "Seed: $seed (Seed is assigned by the user)"
        fi 
    else
        seed="NotApplicable"
    fi

    # Define variables based on the input_data_and_params

    if [[ -n $ar ]]; then
        nr=$( echo "${ar}+1" | bc )
        echo "neighbor radius: $nr"
    fi

    if [[ -n $pw && -n $ar ]]; then
        p_move=$((pw / ar))
        echo "projection n_move: $p_move"
    fi

    hexagon_prefix="${prefix}.hexagon.${sf}.d_${tw}"
    train_prefix="${prefix}.${sf}.nF${nf}.d_${tw}.s_${ep}"
    tranform_prefix="${train_prefix}.prj_${pw}.r_${ar}"
    decode_prefix="${train_prefix}.decode.prj_${pw}.r_${ar}_${nr}"

    echo "#=== OUTPUT PREFIX ===#"
    echo "hexagon_prefix: $hexagon_prefix"
    echo "train_prefix: $train_prefix"
    echo "tranform_prefix: $tranform_prefix"
    echo "decode_prefix: $decode_prefix"

    model_dir=${output_dir}/${train_model}

    # model fn differs by train_model
    if [[ $train_model == "LDA" ]]; then
        model_path=${model_dir}/${train_prefix}.model.p
    elif [[ $train_model == "Seurat" ]]; then
        model_path=${model_dir}/${train_prefix}.model.tsv.gz
    fi
}

# Define a function to check the existence of each file in the provided list
check_files_exist() {
    echo -e "\n#=== Checking input files ===#"
    local files=("$@") # Capture all arguments into an array

    for file in "${files[@]}"; do
        trimmed_file=$(echo "$file" | sed 's/[[:space:]]*$//')
        # Resolve symbolic link (if any)
        if [[ -L "$trimmed_file" ]]; then
            real_path=$(readlink -f "$trimmed_file")
            echo "File '$trimmed_file' is a symbolic link to '$real_path'."
        else
            real_path=$trimmed_file
            #echo "File '$real_path' is not a symbolic link."
        fi
        
        if [[ -f "$real_path" ]]; then
            echo "File '$file' exists."
        else
            echo "File '$file' does not exist."
            exit 1
        fi
    done
}
