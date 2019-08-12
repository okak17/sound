function [Yout1, Yout2] = kMeans(X)

[I,~] = size(X);
counter = (1:I)'; %配列番号を保持'
class = mod(int16(100*rand(I,1)),4); %クラス番号を保持

means = zeros(4,1); %4つクラスの平均
classZero = class >= 0 & class < 1;
classOne = class >= 1 & class < 2;
classTwo = class >= 2 & class < 3;
classThree = class >= 3 & class < 4;
means(1) = mean(X(classZero)); %平均をクラスごと計算
means(2) = mean(X(classOne));
means(3) = mean(X(classTwo));
means(4) = mean(X(classThree));

for count = 1:30
  for i = 1:I
    [~,tmp] = min([norm(X(i,:)-means(1),2),
                  norm(X(i,:)-means(2),2),
                  norm(X(i,:)-means(3),2),
                  norm(X(i,:)-means(4),2)]);
    class(i) = tmp-1;
  end

  classZero = class >= 0 & class < 1;
  classOne = class >= 1 & class < 2;
  classTwo = class >= 2 & class < 3;
  classThree = class >= 3 & class < 4;
  means(1) = mean(X(classZero)); %平均をクラスごと計算
  means(2) = mean(X(classOne));
  means(3) = mean(X(classTwo));
  means(4) = mean(X(classThree));

end

[Z,~]=size(X(classZero));
[O,~]=size(X(classOne));
[T,~]=size(X(classTwo));
[Th,~]=size(X(classThree));

[sizeOfX,tmp] = max([Z,O,T,Th]);

val = 100;
near = 0;
idx = -1;
for i = 1:I
  len = norm(X(i,:)-means(tmp),2);

  if len < val
    val = len;
    near = X(i,:);
    idx = i;
  end
end

Yout1 = near;
Yout2 = idx;
