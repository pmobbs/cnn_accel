# CNN Hardware Accelerator

In this project I have implemented a deep learning hardware accelerator in Verilog for the purpose of studying the memory bandwidth requirements of such accelerators. To perform inference on a single image it loads the image and the associated coefficients into a memory. The accelerator then reads out the image and coefficients in parallel and feeds them to a configurable number of processing units (one for each layer of network). One output is generated for each layer (e.g. one for each digit being recognized in the supplied example).

### Prerequisites

This project was developed using Synopsys VCS. You will need this in order to run the provided makefile.

### Building

To build the project, there is a makefile. Simply typing “make” will produce both the model and simulation executables.

### Running

* Run the simulation by executing ./simv after the make has completed successfully.
* Run the model by executing ./model

## Authors

* **Paul Mobbs** - *Initial work* - [pmobbs](https://github.com/pmobbs)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* This project makes use of the MNIST dataset of handwritten digits.
