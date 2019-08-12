fromHz = 44100;
toHz = 44100;
fromBits = 24;
toBits = 16;
fromDir = 'VM_audio_beta2';

toDir = 'beta2_audio_result';
if(exist(toDir, 'dir') == 0)
	mkdir(toDir)
end

fromFiles = dir(strcat(fromDir, '/*.wav'));

for file = fromFiles'
    fileName = strcat(fromDir, '/', file.name)
    data = audioread(fileName);
%for lag_X = -24:24
%lag_X

Fs = 44100;
%44100 * 30 = 1323000サンプル
%40ms毎に区切る
%40ms = 44100 * 40 / 1000 = 1764 サンプル毎
%20msおきに取り出し，1500音源に分割して比較

L = data(:, 1); %左チャネル
LM = data(:, 2); %右チャネル
RM = data(:, 3);
R = data(:, 4);

%2乗和してゲインを合わせる
[sz,~] = size(L);
sumOfL = 0;
sumOfR = 0;
sumOfLM = 0;
sumOfRM = 0;

for i = 1:sz
sumOfL = abs(L(i,:)) + sumOfL;
sumOfR = abs(R(i,:)) + sumOfR;
sumOfLM = abs(LM(i,:)) + sumOfR;
sumOfRM = abs(RM(i,:)) + sumOfRM;

end

prepareGain = (sumOfL/sumOfR);
prepareGain_M = (sumOfL/sumOfLM);
prepareGain_RM = (sumOfL/sumOfRM);

if prepareGain > 100
  sumOfL
  sumOfR
  prepareGain
end

R = prepareGain * R;
LM = prepareGain_M * LM;
RM = prepareGain_RM * RM;

%40ms(1764サンプル)毎に分割された音源
%右端3音源(n=1497,1498,1499の時)はシフトさせた時のことを考慮し無視する
n = 0;


%lagを決め打ちする-22~22


%右端を無視した1497回まわす
while n < 1499
	st = 1 + 882*n;
	fn = st + 1763;
%比較用
	L1 = L(st:fn);
  LM1 = LM(st:fn);
  RM1 = RM(st:fn);
  R1 = R(st:fn);


%シフト用
	%L1_sh = data(st:fn+1764, 1);
	%R1_sh = data(st:fn+1764, 2);

%R1_sh = prepareGain * R1_sh;

%相関関数を計算

%相関係数を計算するにあたり窓掛けを行う
	hann_w = hanning(fn - st + 1);
	L1_w = L1 .* hann_w;
	R1_w = R1 .* hann_w;
	LM1_w = LM1 .* hann_w;
	RM1_w = RM1 .* hann_w;

	%shuを出して、LRで類似度が大きい方から引いてみるとかどうですかね


	[acor, lag] = xcorr(L1_w, R1_w);
	[~, I] = max(abs(acor));
	lagDiff = lag(I);
	L1_tmp = zeros(1764,1);
	R1_tmp = zeros(1764,1);
  RM1_tmp = zeros(1764,1);
  LM1_tmp = zeros(1764,1);

	  %Y(n+1) = lag(I);


	[acor, lag] = xcorr(L1_w, LM1_w);
	[~,I] = max(abs(acor));
	lag_M = abs(lag(I));

  Lag = abs(lagDiff);
	Y(n+1) = lag_M;

	if Lag < 50

  if lag(I) < 0
    R1_tmp(1:1764-lag_M*3) = R1(lag_M*3+1:1764);
    RM1_tmp(1:1764-lag_M*2) = RM1(lag_M*2+1:1764);
    LM1_tmp(1:1764-lag_M) = LM1(lag_M+1:1764);
  else
    R1_tmp(lag_M*3+1:1764) = R1(1:1764-lag_M*3);
    RM1_tmp(lag_M*2+1:1764) = RM1(1:1764-lag_M*2);
    LM1_tmp(lag_M+1:1764) = LM1(1:1764-lag_M);
	end


	%if max(L1_tmp) > 0.1 || max(R1_tmp) > 0.1
%Lが主音源Rが背景音
		new_L = (L1_tmp + R1_tmp + RM1_tmp + LM1_tmp)/2;
		new_R = LM1_tmp - RM1_tmp;


		else

			new_L = LM1+RM1;
			new_R = LM1-RM1;

		end

    %new_L = L1;
    %new_R = R1;
%閾値を超えない場合は何もしない
	%else
		%new_L = L1;
		%new_R = R1;
	%end

%振幅が1を超えたら出力する
	%for i = 1:1764
		%if new_L(i) > 1
		%	disp(new_L(i));
		%end
	%end

%窓掛けを行う
	new_L = new_L .* hann_w;
	new_R = new_R .* hann_w;

%シフトさせた結果と，LRの加減結果を新しい配列に書き込み
	if n == 0
		L1_new(st:fn) = new_L;
		R1_new(st:fn) = new_R;

%overlap-addを加味
	else
		for point = st:882*(n+1)
			L1_new(point) = L1_new(point) + new_L(point-st+1);
			R1_new(point) = R1_new(point) + new_R(point-st+1);
		end
		L_tmp = new_L(883:1764);
		R_tmp = new_R(883:1764);
		L1_new(1+882*(n+1):882*(n+2)) = L_tmp;
		R1_new(1+882*(n+1):882*(n+2)) = R_tmp;

	end
%転置
	L2 = transpose(L1_new);
	R2 = transpose(R1_new);
	n = n+1;
end

%wavファイルを書き込み
X = [1:1499];
plot(X,Y)
audiowrite(strcat(toDir, '/','test',file.name), [L2, R2], toHz, 'BitsPerSample', toBits)
%end
break
end
