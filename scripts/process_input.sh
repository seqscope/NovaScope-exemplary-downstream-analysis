#!/bin/bash
# Define the function to check mandatory variables
check_mandatory_vars() {
    local vars_to_check=("$@")  # Receive array elements as arguments

    for var in "${vars_to_check[@]}"; do
        if [ -z "${!var}" ]; then  # Check if variable is unset or empty using indirect expansion
            echo "Error: Mandatory variable '$var' is not defined or is empty." >&2
            return 2  # Return a specific non-zero value to indicate an error
        fi
    done
}

read_config_for_neda() {
    # Ensure exactly one argument is provided
    if [ "$#" -ne 2 ]; then
        echo "Usage: read_config_for_neda <path_to_file> <path_to_neda>"
        return 1
    fi

    local config_job="$1"
    local neda="$2"

    # Check if the input file exists and is not empty
    if [ ! -s "$config_job" ]; then
        echo "Error: File '$config_job' not found or is empty."
        return 2
    fi

    # Source the input file
    source "$config_job"

    # Check for general mandatory variables
    local mandatory_vars=("input_transcripts" "input_features" "input_xyrange"  "output_dir" "prefix" "train_model")
    check_mandatory_vars "${mandatory_vars[@]}"

    # Set default values 
    threads=${threads:-1}
    ficture=${ficture:-$neda/submodules/ficture}       # temporary for current branch
    input_hexagon_sge_ficture=${input_hexagon_sge_ficture:="NOT APPLICABLE"}
    input_hexagon_sge_10x_dir=${input_hexagon_sge_10x_dir:="NOT APPLICABLE"}

    # Log settings
    echo -e "#=== ENV ===#"
    echo -e "NEDA: $neda"
    echo -e "ficture: $ficture"
    echo -e "threads: $threads"

    echo -e "\n#=== INPUT ===#"
    echo -e "input transcripts: $input_transcripts"
    echo -e "input feature: $input_feature"
    echo -e "input min and max x y coordinates: $input_xyrange"
    echo -e "input hexagon SGE in FICTURE-compatible format: $input_hexagon_sge_ficture"
    echo -e "input hexagon SGE in 10X Genomics-compatible format: $input_hexagon_sge_10x_dir"

    echo -e "\n#=== ANALYSIS PARAMS ===#"
    echo -e "train model: $train_model"
    echo -e "major axis: $major_axis"
    echo -e "solo feature: $solo_feature"
    echo -e "training width: $train_width"
    if [[ -z ${nfactor+x} ]]; then
        nfactor="NA"
    fi
    if [[ -z ${train_n_epoch+x} ]]; then
        train_n_epoch="NA"
    fi
    echo -e "number of factors: $nfactor"
    echo -e "training N epoch: $train_n_epoch"
    echo -e "projection width: $fit_width"
    echo -e "anchor distance: $anchor_dist"
    # Calculations based on input parameters
    if [[ -n $anchor_dist ]]; then
        neighbor_radius=$(echo "$anchor_dist + 1" | bc)
        echo -e "neighbor radius: $neighbor_radius"
    fi

    if [[ -n $fit_width && -n $anchor_dist ]]; then
        proj_n_move=$((fit_width / anchor_dist))
        echo -e "projection n move: $proj_n_move"
    fi

    # Handling seed value based on training model
    if [[ -z ${seed+x} ]]; then
        seed=$(date +%s | cut -c 1-10)
        echo -e "seed: $seed (random)"
    else
        echo -e "seed: $seed (user-defined)"
    fi
    
    # Handling the output directory
    echo -e "\n#=== OUTPUT DIR/PREFIX ===#"
    if [ ! -d "$output_dir" ]; then
        mkdir -p "$output_dir"
    fi
    model_dir=${output_dir}/${train_model}
    echo -e "output dir: $output_dir"
    echo -e "model dir: $model_dir"

    train_prefix="${prefix}.${solo_feature}.nf${nfactor}.d_${train_width}.s_${train_n_epoch}"
    tranform_prefix="${train_prefix}.prj_${fit_width}.r_${anchor_dist}"
    decode_prefix="${train_prefix}.decode.prj_${fit_width}.r_${anchor_dist}_${neighbor_radius}"
    echo -e "prefix: $prefix"
    echo -e "train prefix: $train_prefix"
    echo -e "tranform prefix: $tranform_prefix"
    echo -e "decode prefix: $decode_prefix"

    model_path=${model_dir}/${train_prefix}.model_matrix.tsv.gz
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
