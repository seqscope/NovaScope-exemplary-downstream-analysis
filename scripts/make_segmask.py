import argparse, os
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
from scipy.ndimage import label
import matplotlib.cm as cm

def convert_tif_to_mask(args):
    # Load the image
    image_path = args.input
    image = Image.open(image_path)
    image_array = np.array(image)

    # Convert image to binary (white areas as True, black boundaries as False)
    binary_image = image_array > 0

    # Label connected components
    labeled_array, num_features = label(binary_image)

    # Save the labeled array to .npy file
    npy_path = f"{args.outpref}_seg.npy"
    np.save(npy_path, labeled_array)

    # Print the number of segmented areas
    print("Number of segmented areas:", num_features)

    # Generate a grayscale map
    norm = plt.Normalize(vmin=labeled_array.min(), vmax=labeled_array.max())
    colormap = cm.get_cmap('nipy_spectral')
    segmented_colors = colormap(norm(labeled_array))

    # Save the color labeled image
    plt.imsave(f"{args.outpref}_areas.png", segmented_colors)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="""
            Converts a black-and-white segmentation TIF image into a segmentation mask matrix encoded in the NumPy array format and a color-coded visualization.
            The output include a *_seg.npy file containing the segmentation mask matrix and a *_areas.png file containing the color-coded visualization.
            """,
        epilog="Example usage: python make_segmask.py --input 'path/to/image.tif' --outpref 'output/path/output_prefix'"
    )
    
    parser.add_argument('--input', type=str, required=True, help='Path to the black-and-white segmentation TIF image file.')
    parser.add_argument('--outpref', type=str, required=True, help='Output prefix for saving the segmentation mask matrix and color-coded image.')
    args = parser.parse_args()

    assert os.path.exists(args.input), "The input file does not exist."
    output_dir = os.path.dirname(args.outpref)
    os.makedirs(output_dir, exist_ok=True)
    convert_tif_to_mask(args)
