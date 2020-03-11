C:\Users\patternizer\Downloads\wget64 --reject "robots.txt" --mirror --recursive --no-parent --reject "index.html*" ftp://ftp.cpc.ncep.noaa.gov/ndacc/station/
matlab -nosplash -nodesktop -noFigureWindows -r "try; run('C:\Users\patternizer\Download\read_extract_ndacc.m'); catch; end; quit"


