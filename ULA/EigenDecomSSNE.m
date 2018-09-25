function [signalNumber,signalNumberRatio] = EigenDecomSSNE(audioDataArray,frameLength,ULAmicArray)

    audioDataArrayCovarianceArray = (audioDataArray*audioDataArray')/frameLength;
    eigenValue = eig(audioDataArrayCovarianceArray);
    % �˴���Э������������ֵ�ֽ������Դ��Ŀ�ж���
    % ʵ������ȫ�����ù۲��źŵ�����ֵ�ֽ��㷨����
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