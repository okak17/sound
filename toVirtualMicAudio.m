clear

% 環境パスにディレクトリを追加
addpath('libAuxIVA');

fromHz = 44100;
toHz = 44100;

toBits = 16;

FFT_SIZE = 2048;
FFT_SHIFT = FFT_SIZE/4;
POS_ALPHA = [0, 0.33, 0.67, 1];
BETA = 2;

fromDir = 'audio_test';
fromFiles = dir(strcat(fromDir, '/*.wav'));

toDir = 'VM_audio_beta2';
if(exist(toDir, 'dir') == 0)
	mkdir(toDir)
end


% ディレクトリ内のすべてのファイルに対して操作を行う
for file = fromFiles'
	% '変換元のファイル名
    srcFileName = strcat(fromDir, '/', file.name);
	% 変換先のファイル名
	tgtFileName = strcat(toDir, '/', file.name)

   data = audioread(srcFileName);

	% サンプリング周波数のリサンプリング
    [p, q] = rat(toHz / fromHz);
    resample_data = resample(data, p, q);

	% 多チャネルの周波数解析
	STFT_data = mSTFT(resample_data, FFT_SIZE, FFT_SHIFT);

	% ヴァーチャル多素子化でチャネルを増やす
	multichannel_data = kaVirtualSignalBetaDiv(STFT_data, POS_ALPHA, BETA);

	% 多チャネルスペクトログラムを波形にして出力
	multichannel_wave = minvSTFT(multichannel_data, FFT_SHIFT);

	audiowrite(tgtFileName, multichannel_wave, toHz, 'BitsPerSample', toBits)

end
