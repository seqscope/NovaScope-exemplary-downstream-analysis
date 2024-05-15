import os
import sys
import argparse

def check_and_link_symbolic_file(source_file, symbolic_file, link_mode):
    """Check the input, manage directories, and handle links based on mode."""
    
    # Check if input file exists
    if not os.path.isfile(source_file):
        print(f"Error: The input file {source_file} does not exist.", file=sys.stderr)
        sys.exit(1)

    # Ensure the directory of the target link exists
    target_dir = os.path.dirname(symbolic_file)
    if not os.path.exists(target_dir):
        os.makedirs(target_dir)
        #print(f"Directory created: {target_dir}")

    # Handle the existence of the target file according to the specified mode
    if os.path.exists(symbolic_file):
        if link_mode == 'skip':
            print(f"Skipping link creation as {symbolic_file} already exists.")
            return
        elif link_mode == 'overwrite':
            os.remove(symbolic_file)
            print(f"!!Warning: Existing link/file removed: {symbolic_file}")

    # Create a symbolic link
    os.symlink(source_file, symbolic_file)
    print(f"Link created successfully from {source_file} to {symbolic_file}")

def main():
    # Setup argument parser
    parser = argparse.ArgumentParser(description='Create symbolic files for input files.')
    parser.add_argument('source_file', type=str, help='Path to the input symbolic file file.')
    parser.add_argument('symbolic_file', type=str, help='Target path for the symbolic link.')
    parser.add_argument('link_mode', choices=['skip', 'overwrite'], help='Link behavior: "skip" to skip if exists, "overwrite" to overwrite existing link.')
    
    args = parser.parse_args()

    # Call the function with parsed arguments
    check_and_link_symbolic_file(args.source_file, args.symbolic_file, args.link_mode)

if __name__ == "__main__":
    main()

