# ozone-updater

MATLAB code written while working on ESA Ozone_CCI and EUMETSAT AC SAF tasks at 
LAP-AUTh to download, read, parse and write operational data from the 
Network for the Detection of Atmospheric Composition Change 
([NDACC](http://www.ndaccdemo.org/)) and from the World Ozone and Ultraviolet Data Centre ([WOUDC](https://woudc.org/)).

## Contents

* `BIRA_REPORT_V3.0.pdf` - Summary of research tasks
* `load_ndacc.bat` - batch script to download the NDACC ozone data using wget64 via FTP and then call the MATLAB reader read_extract_ndacc.m
* `load_woudc.bat` - batch script to download the WOUDC ozone data using wget64 via FTP and then call the MATLAB reader read_extract_woudc.m
* `load_woudc_MSC.bat` - batch script to download the WOUDC ozone MSC data using wget64 via FTP and then call the MATLAB reader read_extract_woudc_MSC.m
* `load_woudc_UOFT.bat` - batch script to download the WOUDC ozone UOFT data using wget64 via FTP and then call the MATLAB reader read_extract_woudc_UOFT.m
* `read_extract_ndacc.m` - MATLAB script to read, parse and write out the NDACC ozone data
* `read_extract_woudc.m` - MATLAB script to read, parse and write out the WOUDC ozone data 
* `read_extract_woudc_MSC.m` - MATLAB script to read, parse and write out the WOUDC ozone MSC data 
* `read_extract_woudc_UOFT.m` - MATLAB script to read, parse and write out the WOUDC ozone UOFT data 

The first step is to clone latest chimere-tools code and step into the check out directory: 

    $ git clone https://github.com/patternizer/ozone-updater.git
    $ cd ozone-updater
    
### Usage

Run the batch scripts directly from the command line with wget64 in your path.
	        
## License

The code is distributed under terms and conditions of the [MIT license](https://opensource.org/licenses/MIT).

## Contact information

* [Michael Taylor](https://patternizer.github.io)


