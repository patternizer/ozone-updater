% function read_extract_ndacc()

%--------------------------------------------------------------------------
% Called by load_ndacc.bat:
%
% C:\Users\patternizer\Downloads\wget64 --reject "robots.txt" --mirror --recursive --no-parent --reject "index.html*" 
% ftp://ftp.cpc.ncep.noaa.gov/ndacc/station/
% matlab -nosplash -nodesktop -noFigureWindows -r "try; run('C:\Users\patternizer\Download\read_extract_ndacc.m'); catch; end; quit"
%--------------------------------------------------------------------------
% Dr. Michael Taylor: 
% Laboratory of Atmospheric Physics, Aristotle University of Thessaloniki
% http://users.auth.gr/mtaylor/
% email(1): mtaylor@auth.gr
% email(2): patternizer@gmail.com
% Version 1.0: 6/11/2016
%--------------------------------------------------------------------------

clear all; close all; clc;
disp(['IN: read_extract_ndacc']);

%% PARAMETERS
dir_stations = 'C:\Users\patternizer\Downloads\ftp.cpc.ncep.noaa.gov\ndacc\station\';
instrument_list = {'brewer','dobson'};
ncolumns = 8;

%% DIRECTORY HANDLING
if isequal(exist(dir_stations),7), else mkdir(dir_stations), end;
station_array = struct2cell(dir(dir_stations));
station_list = station_array(1,3:end); clear station_array;
station_list(strcmp(station_list(:),'.listing') == 1) = [];
for i=1:size(instrument_list,2)
    station_list(strcmp(station_list(:),instrument_list{i}) == 1) = [];
    dir_instrument = strcat([dir_stations,instrument_list{i},'\']);
    if isequal(exist(dir_instrument),7), else mkdir(dir_instrument), end;
end
nstations = size(station_list,2);
ninstruments = size(instrument_list,2);

%% EXTRACT DATA
for i = 1:nstations    
    station_name = char(station_list(i,:));
    station_dir = strcat([dir_stations,station_name,'\ames','\']);
    
    for j = 1:ninstruments          
        dir_instrument = strcat([dir_stations,instrument_list{j},'\']);
        instrument_dir = strcat([station_dir,instrument_list{j},'\']);     
        file_array = struct2cell(dir(instrument_dir));
        file_list = file_array(1,3:end);
        file_list(strcmp(file_list(:),'.listing') == 1) = [];
        if isempty(file_list)
            continue
        end        
        date_list = [];
        for n=1:size(file_list,2)
            YY = file_list{n}(5:6);
            MM = file_list{n}(7:8);
            DD = '00';
            if isequal(strcmp(YY(1),'8'),1) || isequal(strcmp(YY(1),'9'),1)
                YYYY = strcat('19',YY);
            else
                YYYY = strcat('20',YY);
            end            
            date_list = [date_list,str2double(strcat([YYYY,MM,DD]))];
        end        
        [dates,idx] = sort(date_list);
        files = file_list(idx);
        filename = strcat([dir_instrument,station_name]);
        
        if isequal(exist(filename,'file'),0)
            data_old = [];
            date_last = dates(1);   
        else
            data_old = csvread(filename);
            YYYY = num2str(data_old(end,1));
            DD = data_old(end,2);
            MM = data_old(end,3);
            if DD < 10, DD = strcat('0',num2str(DD)); else DD = num2str(DD); end           
            if MM < 10, MM = strcat('0',num2str(MM)); else MM = num2str(MM); end
            date_last = str2double(strcat([YYYY,DD,MM]));
        end               
        data = data_old;        
        idx = find(dates(:) < date_last)';           
        dates(idx) = [];
        files(idx) = [];
        nfiles = size(files,2);
        
        for k=1:nfiles                             
            file_name = char(files(k));            
            file_dir = strcat([instrument_dir,file_name]);                                 
            fileID = fopen(file_dir,'r');             
            C = textscan(fileID,'%s','Delimiter','%\n');             
            maxlines = size(C{1},1);            
            fclose(fileID);  
            data_row = C{1,1}';
            nheader = 34;
            nmeasurements = (maxlines - nheader)/2;     
            
            for l = 1:nmeasurements                     
                data_l = data_row{nheader + (2*l - 1)};   
                data_ref = sscanf(data_l,'%f')';
                YYYY = data_ref(1,2);
                MM = data_ref(1,3);
                DD = data_ref(1,4);                
                % Extract day of month (DD) and create date_vec
                date_vec = [YYYY,MM,DD];                         
                % Extract timestamp (HH:MM:SS) and create time_vec
                HH = data_ref(1,5);
                MM = data_ref(1,6);
                SS = 0;
                time_vec = [HH,MM,SS];                  
                % Extract SZA
                SZA = data_ref(1,10); 
                % Extract measurements
                data_l = data_row{nheader + (2*l)};                
                measurements = sscanf(data_l,'%f')';               
                data = [data;date_vec,time_vec,SZA,measurements];                                   
                data(data == 99) = NaN;
                data(data == 99.99) = NaN;                
                data(data == 999.99) = NaN;
                data(data == 9999) = NaN;
                data(data == 9999) = NaN;
            end% l=1:nmeasurements                                                        
        end % k=1:nfiles                                   
        csvwrite(strcat(filename),data);        
        % columns = {'YYYY','MM','DD','HH','MM','SS','SZA','Airmass,'VCDO3','StdDevVCDO3','VCDO3DU','StdDevVCD03DU'};

    end % j=1:ninstruments
end % i=1:nstations

disp(['OUT: read_extract_ndacc']);

% end % function
