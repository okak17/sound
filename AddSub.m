fromHz = 44100;
toHz = 44100;
fromBits = 24;
toBits = 16;
fromDir = 'audio';
toDir = 'MS';
if(exist(toDir, 'dir') == 0)
	mkdir(toDir)
end

fromFiles = dir(strcat(fromDir, '/*.wav'));

for file = fromFiles'
Y = zeros(1499,1);
    fileName = strcat(fromDir, '/', file.name)
    data = audioread(fileName);
Fs = 44100;
%44100 * 30 = 1323000サンプル'
%40ms毎に区切る
%40ms = 44100 * 40 / 1000 = 1764 サンプル毎
%20msおきに取り出し，1500音源に分割して比較

L = data(:, 1); %左チャネル
R = data(:, 2); %右チャネル

L2 = L+R;
R2 = L-R;

%wavファイルを書き込み
audiowrite(strcat(toDir, '/',file.name), [L2, R2], toHz, 'BitsPerSample', toBits)
end
