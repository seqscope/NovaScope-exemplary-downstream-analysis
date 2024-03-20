#!/bin/bash

process_input_data_and_params() {
    # Ensure exactly one argument is provided
    if [ "$#" -ne 1 ]; then
        echo "Usage: process_input_data_and_params <path_to_file>"
        return 1
    fi

    local input_data_and_params="$1"

    # Check if the input file exists and is not empty
    if [ ! -s "$input_data_and_params" ]; then
        echo "Error: File '$input_data_and_params' not found or is empty."
        return 2
    fi

    # Source the input file
    source "$input_data_and_params"

    # Check for mandatory variables
    local mandatory_vars=("input_dir" "output_dir" "prefix" "train_model")
    for var in "${mandatory_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "Error: Mandatory variable '$var' is not defined or is empty."
            return 2
        fi
    done
    
    # Set default values for optional variables
    threads=${threads:-1}

    # Log settings
    echo -e "#=== ENVIRONMENT ===#"
    echo -e "ficture: $ficture"
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

    # Handling seed value based on training model
    if [[ -z $seed ]]; then
        seed=$(date +%s | cut -c 1-10)
        echo -e "seed: $seed (Random seed is assigned)"
    else
        echo -e "Seed: $seed (Seed is assigned by the user)"
    fi 

    # Calculations based on input parameters
    if [[ -n $ar ]]; then
        nr=$(echo "$ar + 1" | bc)
        echo -e "neighbor radius: $nr"
    fi

    if [[ -n $pw && -n $ar ]]; then
        p_move=$((pw / ar))
        echo -e "projection n_move: $p_move"
    fi

    # Prefix definitions
    hexagon_prefix="${prefix}.hexagon.${sf}.d_${tw}"
    train_prefix="${prefix}.${sf}.nF${nf}.d_${tw}.s_${ep}"
    tranform_prefix="${train_prefix}.prj_${pw}.r_${ar}"
    decode_prefix="${train_prefix}.decode.prj_${pw}.r_${ar}_${nr}"

    echo -e "\n#=== OUTPUT PREFIX ===#"
    echo -e "hexagon_prefix: $hexagon_prefix"
    echo -e "train_prefix: $train_prefix"
    echo -e "tranform_prefix: $tranform_prefix"
    echo -e "decode_prefix: $decode_prefix"

    model_dir=${output_dir}/${train_model}

    # Construct model path based on training model
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
            #echo "File '$trimmed_file' is a symbolic link to '$real_path'."
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
