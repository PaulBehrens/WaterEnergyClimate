%% This script extracts all raw data sources, both powerplants and aqueduct
%  A stores the paths for the datasets
%  Data outputs in all_data.mat are:
%   S2 = Aqueduct water data - historic, 2010 data (1472 basins)
%   S3 = Aqueduct water data - forecast, 2030 data (1472 basins)
%   P14 = WEPP powerplant data - historic, 2014 data (1306 units)
%   P20 = WEPP powerplant data - projection, 2020 data (1327 units)
%   P30 = WEPP powerplant data - projection, 2030 data (1031 units) 
%
%   Includes one pre-processing step:
%       - removes water consumption for sea and brackish water cooling
%%
clear all; clc;
%% Extract Power plants
A = PAB_paths;

years = {'14', '20', '30'};
filename{1} = '../Data/2014/current stock 2014.xlsx';
filename{2} = '../Data/2020/2020.xlsx';
filename{3} = '../Data/2030/2030.xlsx';

for k = 1:3
[~, header] = xlsread(filename{k},'all','A1:AB1');
[num, text, raw] = xlsread(filename{k},'all');

for i = 1:(size(raw,1)-1)
    for j = 1:size(raw,2)
       eval(['P(i).' char(header(j)) ' = raw(i+1,j);'])
    end
end

idx = [4 6 7 8 15 16 18 19 20 21 26 27 28]; % select columns of interest
for i = 1:(size(raw,1)-1)
   for j = 1:length(idx)
      eval(['P(i).' char(header(idx(j))) ' = cell2mat(P(i).' char(header(idx(j))) ');']) 
   end
end

for i = 1:(size(raw,1)-1)
   I = strcmp(P(i).COOL,'OTS') | strcmp(P(i).COOL,'OTB'); % remove cooling requirements for seawater or brackish water
   if I == 1
       P(i).WITHDRAWAL = 0;
       P(i).CONSUMPTION = 0;
       P(i).WFW_FACTOR = 0;
       P(i).WFC_FACTOR = 0;
       P(i).MW = 0;
       P(i).ENERGY_GJ = 0;
   end
end

L = size(P,2)+1;
for j = 1:size(raw,2)
    eval(['P(L).' char(header(j)) ' = 0;']) 
end

 eval(['P' char(years{k}) ' = P;'])
 clear P
end

keep P14 P20 P30 A

%% Extract present water basins

GU = xlsread('../data/Total_dataset.xlsx','2020BAU','D2:D1473');

S = shaperead(A.Aqueduct.baseline);

my_size = size(S,1);

FGU = extractfield(S,'GU')

for i = 1:length(GU)
    idx(i) = find(FGU == GU(i));
end

header = fieldnames(S);

for i = 1:length(idx)
    for j = 1:length(header);
      eval(['S2(i).' char(header(j)) ' = S(idx(i)).' char(header(j)) ';'])
    end
end

keep S2 P14 P20 P30 A

%% Extract future water basins
BasinID = xlsread('../data/Total_dataset.xlsx','2020BAU','L2:L1473');
Area_km2 = xlsread('../data/Total_dataset.xlsx','2020BAU','N2:N1473');

load(A.Aqueduct.ProjectionLatest);

my_size = size(S,1);

FArea_km2 = extractfield(S,'Area_km2');
FBasinID = extractfield(S,'BasinID');

for i = 1:length(BasinID)
    idx(i)  = find(FBasinID == BasinID(i) & FArea_km2 == Area_km2(i));
end

header = fieldnames(S);

for i = 1:length(idx)
    for j = 1:length(header);
      eval(['S3(i).' char(header(j)) ' = S(idx(i)).' char(header(j)) ';'])
    end
end

keep P14 P20 P30 S2 S3
save ../Data/Raw_data.mat *