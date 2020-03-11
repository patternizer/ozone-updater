% function read_extract_woudc()

%--------------------------------------------------------------------------
% Called by load_woudc1.bat:
%
% C:\Users\patternizer\Downloads\wget64 --reject "robots.txt" --mirror --recursive --no-parent --reject "index.html*" 
% http://woudc.org/archive/Archive-NewFormat/TotalOzoneObs_1.0_1/
% matlab -nosplash -nodesktop -noFigureWindows -r "try; run('C:\Users\patternizer\Downloads\read_extract_woudc.m'); catch; end; quit"
%--------------------------------------------------------------------------
% Dr. Michael Taylor: 
% Laboratory of Atmospheric Physics, Aristotle University of Thessaloniki
% http://users.auth.gr/mtaylor/
% email(1): mtaylor@auth.gr
% email(2): patternizer@gmail.com
% Version 1.0: 1/11/2016
%--------------------------------------------------------------------------

clear all; close all; clc;
disp(['IN: read_extract_woudc']);

%% PARAMETERS
dir_stations = 'C:\Users\patternizer\Downloads\woudc.org\archive\Archive-NewFormat\TotalOzoneObs_1.0_1\';
instrument_list = {'brewer','dobson'};
ncolumns = 8;
year_min = 1995;
year_max = str2num(datestr(now,'yyyy')); 

%% DIRECTORY HANDLING
if isequal(exist(dir_stations),7), else mkdir(dir_stations), end;
station_array = struct2cell(dir(dir_stations));
station_list = station_array(1,3:end); clear station_array;
for i=1:size(instrument_list,2)
    station_list(strcmp(station_list(:),instrument_list{i}) == 1) = [];
    dir_instrument = strcat([dir_stations,instrument_list{i},'\']);
    if isequal(exist(dir_instrument),7), else mkdir(dir_instrument), end;
end
nstations = size(station_list,2);
ninstruments = size(instrument_list,2);

%% EXTRACT DATA
for i = 1:nstations    
    station_id = station_list{1}(4:end);
    station_name = char(station_list(i,:))
    station_dir = strcat([dir_stations,station_name,'\']);
    
    for j = 1:ninstruments          
        dir_instrument = strcat([dir_stations,instrument_list{j},'\']);
        instrument_dir = strcat([station_dir,instrument_list{j},'\']);        
        filename = strcat([dir_instrument,station_id])              
        if isequal(exist(filename,'file'),0)
            data_old = [];
            YYYY = num2str(year_min);
            DD = 1;
            MM = 1;
            if DD < 10, DD = strcat('0',num2str(DD)); else DD = num2str(DD); end           
            if MM < 10, MM = strcat('0',num2str(MM)); else MM = num2str(MM); end
            date_last = str2double(strcat([YYYY,DD,MM]));
            year_last = year_max;
        else
            data_old = csvread(filename);
            YYYY = num2str(data_old(end,1));
            DD = data_old(end,2);
            MM = data_old(end,3);
            if DD < 10, DD = strcat('0',num2str(DD)); else DD = num2str(DD); end           
            if MM < 10, MM = strcat('0',num2str(MM)); else MM = num2str(MM); end
            date_last = str2double(strcat([YYYY,DD,MM]));
            year_last = data_old(end,1);            
        end        

        year_array = struct2cell(dir(instrument_dir));
        year_list = str2double(year_array(1,3:end));
        year_list(year_list < year_last) = [];
        nyear = size(year_list,2);
       
        data = data_old;
        
        for k=1:nyear
            year_name = num2str(year_list(k))
            year_dir = strcat([instrument_dir,year_name,'\']);
            file_array = struct2cell(dir(year_dir));
            file_list = file_array(1,3:end);
            date_list = [];
            for n=1:size(file_list,2)
                date_n = str2double(file_list{n}(1:8));
                date_list = [date_list,date_n];
            end
            idx = find(date_list(:) <= date_last)';
            date_list(idx) = [];
            file_list(idx) = [];
            nfiles = size(file_list,2);

            for l=1:nfiles             
                date_n = num2str(date_list(l));                
                date_vec = [str2double(date_n(1:4)),str2num(date_n(5:6)),str2num(date_n(7:8))];  
                
                file_name = char(file_list(l));
                file_dir = strcat([year_dir,file_name]);                     
                fileID = fopen(file_dir,'r'); 
                C = textscan(fileID,'%s','Delimiter','%\n'); 
                maxlines = size(C{1},1);
                frewind(fileID);               
                
                idx = strfind(C{1},'#OBSERVATIONS');
                nheader = find(~cellfun('isempty',idx)) + 1;
                frewind(fileID);
                data_array = [];
                pointer = 0;          
                
                for m = 1:maxlines
                    data_cell = textscan(fileID,'%s',ncolumns,'delimiter',',','whitespace','','TreatAsEmpty',' ','HeaderLines',nheader + pointer);
                    data_row = data_cell{1,1}'; 
                    if size(data_row,2) == ncolumns
                        timestamp = data_row{1}; 
                        measurements = str2double(data_row(1,2:ncolumns)); 
                        if length(timestamp) == 0
                        else                            
                            if isnan(measurements(1))                            
                            else    
                                time_vec = [str2double(timestamp(1:2)),str2double(timestamp(4:5)),str2double(timestamp(7:8))];  
                                data = [data;date_vec,time_vec,measurements];                        
                            end
                        end
                    end
                    pointer = pointer + 1;
                    frewind(fileID);                                        
                end% m=1:maxlines   
                fclose(fileID);  
                               
            end % l=1:nfile                   
        end % k=1:nyear
                
        csvwrite(strcat(filename),data);
        
% columns = {'YYYY','MM','DD','HH','MM','SS','WLcode','ObsCode,'Airmass','ColumnO3','StdDevO3','ColumnSO2','StdDevSO2'};

    end % j=1:ninstruments
end % i=1:nstations

disp(['OUT: read_extract_woudc']);

% end % function
