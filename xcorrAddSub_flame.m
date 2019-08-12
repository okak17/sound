fromHz = 44100;
toHz = 44100;
fromBits = 24;
toBits = 16;
fromDir = 'audio';
toDir = 'audio_AddSub';

fromFiles = dir(strcat(fromDir, '/*.wav'));

for file = fromFiles'
    fileName = strcat(fromDir, '/', file.name)
    data = wavread(fileName);

Fs = 44100;
%44100 * 30 = 1323000サンプル
%40ms毎に区切る
%40ms = 44100 * 40 / 1000 = 1764 サンプル毎
%20msおきに取り出し，1500音源に分割して比較

L = data(:, 1); %左チャネル
R = data(:, 2); %右チャネル

%40ms(1764サンプル)毎に分割された音源
%右端3音源(n=1497,1498,1499の時)はシフトさせた時のことを考慮し無視する
n = 0;

%右端を無視した1497回まわす
while n < 1497
	st = 1 + 882*n;
	fn = st + 1763;
%比較用
	L1 = data(st:fn, 1);
	R1 = data(st:fn, 2);
%シフト用
	L1_sh = data(st:fn+1764, 1);
	R1_sh = data(st:fn+1764, 2);

%相関関数を計算
	[acor, lag] = xcorr(R1, L1);
	[~, I] = max(abs(acor));
	lagDiff = lag(I);

 	if lagDiff < 0
		L1_tmp = L1_sh(-lagDiff:(1763-lagDiff));
 		R1_tmp = R1;
 	elseif lagDiff > 0
 		R1_tmp = R1_sh(lagDiff:(1763+lagDiff));
 		L1_tmp = L1;
 	else
 		L1_tmp = L1;
 		R1_tmp = R1;
	end

%LRの加減したものを窓掛けする(ハニング窓)
  new_L = L1_tmp + R1_tmp;
  new_R = L1_tmp - R1_tmp;

  hann_w = hann(fn - st + 1);

%窓掛け
  new_L = new_L .* hann_w;
  new_R = new_R .* hann_w;


%シフトさせた結果と，LRの加減結果を新しい配列に書き込み(over-lap add を加味)
  if st == 1
    L1_new(st:fn) = new_L + new_R;
    R1_new(st:fn) = new_R - new_R;

  else
    for point = st:(st+fn)/2
      L1_new(point) = L1_new(point) + new_L;
      R1_new(point) = R1_new(point) + new_R;
    end
  end
%転置
	L2 = transpose(L1_new);
	R2 = transpose(R1_new);
	n = n+1;
end

%wavファイルを書き込み
wavwrite([L2, R2], toHz, toBits, strcat(toDir, '/', file.name))

end
