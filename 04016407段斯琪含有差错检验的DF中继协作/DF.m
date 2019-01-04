N=100;
L=65;    %һ֡����
BerSnrTable=zeros(20,5);
for snr=0:25
    BerSnrTable(snr+1,1) = snr;      %��dBת��Ϊʮ������ֵ
    sig=1/sqrt(10^(snr/10));
    temp=0;
    temp1=0;
    for i=1:N
        BitsTx = floor(rand(1,L)*2);            %����ȡ����BitsTxΪ��ʼ�����ź�
        BitsTxcrc=CrcEncode(BitsTx);            %ѭ�������룻BitsTxcrcΪѭ���������ź�
        BitsTxcnv=cnv(BitsTxcrc);               %�����ƾ������
        Mod8Tx=mod_8psk(BitsTxcnv);             %8PSK����
        M=length(Mod8Tx);                        %8PSK���������г���
        
        %����Ϊ�����ŵ�ģ�ͺ�����ģ�ͣ����ڱ��η����ص㲻���ڴˣ����������¼�
        H1d=RayleighCH();                       %�û�1��Ŀ�Ľڵ�֮����ŵ�
        H12=RayleighCH();                       %�û�1���û�2֮����ŵ�
        H2d=RayleighCH();                       %�û�2��Ŀ�Ľڵ�֮����ŵ�   
        Z1d=randn(1,M)+1i*randn(1,M);           %�û�1��Ŀ�Ľڵ�֮�������
        Z12=randn(1,M)+1i*randn(1,M);           %�û�1���û�2֮�������
        Z2d=randn(1,M)+1i*randn(1,M);           %�û�2��Ŀ�Ľڵ�֮�������
        % Ŀ�Ľڵ���յ��û�1��Դ�ڵ�Ĺ���
        Y1d=H1d.*Mod8Tx+sig*Z1d;                %Ŀ�Ľڵ���յ����û�1���źŹ��ʺ���������֮��
        %user2���ղ�����
        Y12=H12.*Mod8Tx+sig*Z12;                %�û�2�����û�1���źŹ��ʺ���������֮��
        R12=conj(H12).*Y12;                     %conjΪȡ����
        BitR12=demod_8psk(R12);                 %8PSK��ʽ���룬BitRsrΪ��������
        BitR12viterbi=viterbi(BitR12);          %����·��****************����viterbi������������
        BitR12viterbi=BitR12viterbi(1:length(BitR12viterbi)-1);
        [BitR12decrc,error]=CrcDecode(BitR12viterbi);    %BitRsrdecrcΪ�м̽������룻errorΪ1���д�Ϊ0���޴�
         %error=0,��ȷ����   error=1���������
         %��Э�����
        if(error==1)
            R1d=conj(H1d).*Y1d; 
            BitR1d=demod_8psk(R1d);           %Ŀ�Ľڵ���յ����û�1��8PSK����
            BitR1dviterbi=viterbi(BitR1d);    %viterbi����
            BitR1dviterbi=BitR1dviterbi(1:length(BitR1dviterbi)-1);
            BitR1ddecrc=CrcDecode(BitR1dviterbi);  %ѭ�����룬BitR1ddecrcΪѭ������õ�����
            [Num,Ber] = symerr(BitR1ddecrc,BitsTx);         %symerr�����������������ŵĸ������������
                                                             %Numָ�����������ݼ���Ȳ�ͬ���ŵĸ�����BerΪ�����ʣ�������Num�����ܷ�����
            BerSnrTable(snr+1,2)=BerSnrTable(snr+1,2)+Num;
        end
         %Э�����
        if(error==0)
            Bits2d=BitR12decrc;                %�û�2�����׼��������Ŀ�Ľڵ����  
            Bits2dcrc=CrcEncode(Bits2d);       %�Խ����������ѭ������
            Bits2dcnv=cnv(Bits2dcrc);          %�����ƾ������
            Mod8_2d=mod_8psk(Bits2dcnv);       %�Ա����������8PSK����
            Y2d=H2d.*Mod8_2d+sig*Z2d;          %Ŀ�Ľڵ���յ����û�2�Ĺ���
            %���ϲ����ڴ˴��ļ���ʽ
            Rd=conj(H2d).*Y2d+conj(H1d).*Y1d; %Ŀ�Ľڵ��յ����û�1���û�2���ź�֮��
            BitRd=demod_8psk(Rd);               %Ŀ�Ľڵ�Խ��յ������źŵ������8PSK��ʽ����
            BitRdviterbi=viterbi(BitRd);        %viterbi����
            BitRdviterbi=BitRdviterbi(1:length(BitRdviterbi)-1);
            BitRddecrc=CrcDecode(BitRdviterbi);  %ѭ������
            [Num,Ber] = symerr(BitRddecrc,BitsTx);   %symerr�����������������ŵĸ������������
                                                       %Numָ�����������ݼ���Ȳ�ͬ���ŵĸ�����BerΪ�����ʣ�������Num�����ܷ�����
            BerSnrTable(snr+1,2)=BerSnrTable(snr+1,2)+Num;
            temp=temp+1;
        end   
    end
    BerSnrTable(snr+1,3)=BerSnrTable(snr+1,2)/(L*N);  %�˴���M�ĳ�N
    BerSnrTable(snr+1,4)=temp;
end   
semilogy(BerSnrTable(:,1),BerSnrTable(:,3),'r*-');
grid on;
figure
semilogy(BerSnrTable(:,1),BerSnrTable(:,4),'g*-');
grid on;
time_of_sim = toc; %��¼�������ʱ��
echo on;