function Yout = subspaceMethod(X, NOISE, num)
%%
%% subspaceMethod: Noise reduction based on subspace method
%%
%% coded by K. Yamaoka (yamaoka@mmlab.cs.tsukuba.ac.jp) on 7 June 2017
%%
%% [syntax]
%%   Y = subspaceMethod(X, NOISE, num)
%%
%% [inputs]
%%   X: Obserbed signal
%%     size -> (# of channel, # of time flame, # of frequency bin)
%%   NOISE: Noise signal for training
%%     size -> (# of channel, # of time flame, # of frequency bin)
%%   num: # of lower base for projection
%%
%% [outputs]
%%   Yout: Output signal
%%     size -> (1, # of time flame, # of frequency bin)
%%

[nch, nTime, nFreq] = size(X);
Y = zeros(size(X));

% Calculate covariance matrices
Ri = zeros(nch, nch, nFreq);
for f = 1:nFreq
    Ri(:,:,f) = NOISE(:,:,f) * NOISE(:,:,f)';
end

% 'Eigenvalue decomposition
V = zeros(nch, nch, nFreq);
D = V;
noiseSubspace = zeros(nch, num, nFreq);
%debug = zeros(nch,1);
for f = 1:nFreq
    [V(:,:,f), D(:,:,f)] = eig(Ri(:,:,f));
    [val, idx] = sort(diag(D(:,:,f)), 'ascend');
    noiseSubspace(:,:,f) = V(:,idx(1:num),f);
    %debug = debug + val;
end
%debug = debug / nFreq

% projection to noise signal subspace
for f = 1:nFreq
    for t = 1:nTime
        for i=1:num
            tmp = noiseSubspace(:,i,f);
            Y(:,t,f) = Y(:,t,f) + tmp * dot(tmp,X(:,t,f));
        end
    end
end
Yout = Y(1,:,:);
