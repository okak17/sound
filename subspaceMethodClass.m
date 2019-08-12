function [Yout1, Yout2, Yout3] = subspaceMethod2(X)
%%
%% subspaceMethod: Noise reduction based on subspace method
%%
%% coded by K. Yamaoka (yamaoka@mmlab.cs.tsukuba.ac.jp) on 7 June 2017
%%
%% [syntax]
%%   Y = subspaceMethod2(X, NOISE, num)
%%
%% [inputs]
%%   X: Obserbed signal
%%     size -> (# of channel, # of time flame, # of frequency bin)
%%   NOISE: Noise signal for training
%%     size -> (# of channel, # of time flame, # of frequency bin)
%%   num: # of lower base for projection
%%
%% [outputs]
%%   Yout1,2: Output signal
%%     size -> (1, # of time flame, # of frequency bin)
%%   Yout3: Output Boolian

[nch, nTime, nFreq] = size(X);
outMain = zeros(size(X));
outBack = zeros(size(X));

arrMain = zeros(2,nTime*nFreq);
arrBack = zeros(2,nTime*nFreq);
arrVal = zeros(1,nTime*nFreq);
for f = 1:nFreq

  for t = 1:nTime

    train = zeros(nch,21);
    Ri = zeros(nch,nch);
    tmp = zeros(nch,nch);

    if t > 20
      train = X(:,t-20:t,f);
    else
      train = X(:,t:t+20,f);
    end


    % Calculate covariance matrices
    for trainTime = 1:21
      tmp = tmp + train(:,trainTime) * train(:,trainTime)';
    end
    Ri  = 1/21*tmp;

    %'Eigenvalue decomposition
    subSpace = zeros(nch,nch);
    V = zeros(nch, nch);
    D = V;
    [V(:,:), D(:,:)] = eig(Ri(:,:));
    [val, idx] = sort(diag(D(:,:)), 'ascend');
    subSpace(:,:) = V(:,idx(1:2));


    back = subSpace(:,1);
    main = subSpace(:,2);
    arrMain(:,(f-1)*nTime+t) = main;
    arrVal(:,(f-1)*nTime+t) = max(max(D));
    arrBack(:,(f-1)*nTime+t) = back;

  end
end

threshold = arrVal > 50;
test = (arrMain(:,threshold))';

Yback = (arrBack(:,threshold))';
I = max(arrVal);
[sz,~] = size(test);

bl = 0;
if sz > 10
  bl = 1;
  [Y, index] = kMeans(test);
  Ymain = Y
  Yback = Yback(index,:);

  for f = 1:nFreq
    for t = 1:nTime
      outMain(:,t,f) = Ymain*dot(Ymain,X(:,t,f));
      outBack(:,t,f) = arrBack(:,(f-1)*nTime+t)*dot(arrBack(:,(f-1)*nTime+t),X(:,t,f));
    end
  end

else
  outMain = 0;
  outBack = 0;
end

Yout1 = outMain;
Yout2 = outBack;
Yout3 = bl;
