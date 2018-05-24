addpath(genpath('C:\\Users\\Tim\\Downloads\\liblsl-Matlab'))
%ReceiveData
lib = lsl_loadlib();
result = lsl_resolve_byprop(lib,'type','EEG');
inlet = lsl_inlet(result{1});

%[ChunkData,Timestamps] = inlet.pull_chunk()
%[SampleData,Timestamp] = inlet.pull_sample(0)


%Algorithm 1:
%Online k-means Clustering Algorithm
s = 14;         %number of sensors
k = 4;          %number of actions (move froward, back, left, right: k=4)
n = 1000;       %number of samples per clustering calculation
sf = 128;       %sample frequency
data_window = zeros(s,n);
c = ones(s,k);  %assign initial values to centroids c={c1,c2,..,ck}
%centroid initialization using actual sensor vectors
time = 0;
time2 = time;
while isempty(data)
    [data,time] = inlet.pull_sample(0);
end
c(:,1) = data(1:s)';
epsilon = 0.5;  %diversity value, which is learned in online processing
for i=1:k-1
    c(:,i+1) = c(:,i) + c(:,i)*epsilon*i;
end

for i=1:n
    while isempty(data) || (time2-time)<(1/sf)
        [data,time2] = inlet.pull_sample(0);
    end
    data_window(:,n) = data(1:s)';
    time = time2;
end

while true  %loop while receiving signal
    while isempty(data) || (time2-time)<(1/sf)
        [data,time2] = inlet.pull_sample(0);
    end
    time = time2;
    data_window(:,1:n-1) = data_window(:,2:n);   %shift down
    data_window(:,n) = data(1:s);
    distances = dist(c',data_window);    %calculate distances to centroids
    
    clustersize = zeros(1,k);
    c_new = zeros(s,k);
    for i=1:n
        %find the shortest distance for each sample
        [~,j] = min(distances(:,i));
        c_new(:,j) = c_new(:,j) + data_window(:,i);
        clustersize(1,j) = clustersize(1,j) + 1;
    end
    for i=1:k
        %find centroids without clusters
        if clustersize(1,i)== 0
            c_new(:,i) = data_window(:,i);
            clustersize(1,i) = 1;
        end
    end
    c_new = bsxfun(@rdivide, c_new, clustersize);
    c_new(isnan(c_new)) = 0;
    c = c_new;
    
    [REEG_EigVec, ExpVar] = PCA_EigVec41(c);
end
