function [signalNumber,signalNumberRatio] = EigenDecomSSNE(audioDataArray,frameLength,ULAmicArray)

    audioDataArrayCovarianceArray = (audioDataArray*audioDataArray')/frameLength;
    eigenValue = eig(audioDataArrayCovarianceArray);
    % 此处用协方差矩阵的特征值分解进行声源数目判定，
    % 实际上完全可以用观测信号的奇异值分解算法代替
    eigenValue = sort(eigenValue,'descend');
    mainEigenValue = eigenValue(1:ULAmicArray.kelm);
    
    sumMainEigenValue2 = sum(mainEigenValue,1);
    sumSignalEigenValue = 0;
    for iloop1 = 1:3
        sumSignalEigenValue = sumSignalEigenValue + mainEigenValue(iloop1);
        ratio = sumSignalEigenValue/sumMainEigenValue2;
        if (ratio > 0.93)
            signalNumber = iloop1;
            signalNumberRatio = ratio;
            break;
        end
    end