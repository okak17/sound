function [Yout1, Yout2] = subspaceMethod2(X)
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
%%   Yout: Output signal
%%     size -> (1, # of time flame, # of frequency bin)
%%

[nch, nTime, nFreq] = size(X);
Ymain = zeros(size(X));
Yback = zeros(size(X));

for t = 1:nTime
  arrMain = zeros(2,nFreq); %固有ベクトルを保存する配列 kmeansで使う
  arrBack = zeros(2,nFreq);
  arrVal = zeros(1,nFreq); %固有値を保存する配列
  for f = 1:nFreq

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

    arrMain(:,f) = main;
    arrVal(:,f) = max(max(D));
    arrBack(:,f) = back;
  end

  [M, idx] = max(arrVal);

    main = arrMain(:,idx);
    back = arrBack(:,idx);


  for f = 1:nFreq
    Ymain(:,t,f) = main*dot(main,X(:,t,f));
    Yback(:,t,f) = back*dot(back,X(:,t,f));
  end

end
Yout1 = Ymain;
Yout2 = Yback;
