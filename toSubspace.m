clear

% 環境パスにディレクトリを追加
addpath('libAuxIVA');

fromHz = 44100;
toHz = 44100;

toBits = 16;

FFT_SIZE = 2048;
FFT_SHIFT = FFT_SIZE/2;

fromDir = 'audio_2ch_data';
fromFiles = dir(strcat(fromDir, '/1.wav'));

toDir = 'subspace';
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

	% 周波数解析
	STFT_data = mSTFT(resample_data, FFT_SIZE, FFT_SHIFT);

	% サブスペース法を適用したもの
		[Ymain lam] = subspaceMethod2(STFT_data);

		mainWav = minvSTFT(Ymain);
		backWav = minvSTFT(Yback);

		Xmain = (sum((mainWav(:,:))'))';
		Xback = (sum((backWav(:,:))'))';
	audiowrite(tgtFileName, [Xmain, Xback], toHz, 'BitsPerSample', toBits)

end
