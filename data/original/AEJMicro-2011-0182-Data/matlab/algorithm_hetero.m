choice_matrix=zeros(8038,1000);
nturns_matrix=zeros(8038,1000);
rank_female_matrix=zeros(14172,1000);
save('results_hetero');
clear;

males=csvread('all_males_matlab.csv');
%generating the predicted income variable;
males(:,36)=7.418931+0.3802024.*(males(:,17)==2)+0.2910631.*(males(:,17)==3)+0.4149558.*(males(:,17)==4)+0.85294.*(males(:,17)==5)+0.9937935.*(males(:,17)==6)+0.7304921.*males(:,18)+0.3681355.*males(:,22)+0.1091655.*males(:,21)+0.3095811.*males(:,23)+0.6503404.*males(:,19)+0.0898219.*males(:,24)+0.2121816.*males(:,27)+1.049178.*males(:,28);
females=csvread('all_females_matlab.csv');
%generating the predicted income variable;
females(:,36)=6.293726-1.104065.*(females(:,17)==2)-0.3399234.*(females(:,17)==4)-0.4702701.*(females(:,17)==5)-0.5913263.*females(:,18)+0.0704875.*females(:,22)-0.1481157.*females(:,21)-1.253383.*females(:,19)+0.1901144.*females(:,24)+0.5717738.*females(:,27)+2.719963.*females(:,28);
save stable_hetero;
clear;
%Construction of the betas-indidivual to each person in the sample;
delta_brides=zeros(1000,8,39);
delta=csvread('delta_groomwanted_withZ.csv');
x=1;
while x<1001
    delta_brides(x,:,:)=reshape(delta(x,:),8,39);
    x=x+1;
end;
clear delta x;
delta_grooms=zeros(1000,8,44);
delta=csvread('delta_bridewanted_withZ.csv');
x=1;
while x<1001
    delta_grooms(x,:,:)=reshape(delta(x,:),8,44);
    x=x+1;
end;
clear delta x;
sigma=csvread('sigma_groomwanted_withZ.csv');
sigma_brides=zeros(1000,39,39);
x=1;
while x<1001
    sigma_brides(x,:,:)=reshape(sigma(x,:),39,39);
    x=x+1;
end;
sigma=csvread('sigma_bridewanted_withZ.csv');
sigma_grooms=zeros(1000,44,44);
x=1;
while x<1001
    sigma_grooms(x,:,:)=reshape(sigma(x,:),44,44);
    x=x+1;
end;
clear sigma x;
load stable_hetero;
Z_brides=horzcat(ones(14172,1),females(:,5)-3.62055336,females(:,6)-0.001976285,females(:,3)-26.22134387,females(:,10)-0.013833992,females(:,11)-1.520769368, females(:,12)-0.037549407, females(:,36)-8.647438314);
Z_grooms=horzcat(ones(8038,1),males(:,5)-3.768953069,males(:,6)-0.007220217,males(:,3)-30.86281588,males(:,10)-0.039711191,males(:,11)-1.518456318,males(:,12)-0.108303249,males(:,36)-9.35095774);
clear males females;
save stable_hetero2;
clear;

x=1;
while x<251
    tic
    load stable_hetero2;
    u_brides=mvnrnd(zeros(1,39),squeeze(sigma_brides(x,:,:)),14172);
    clear sigma_brides;
    beta_brides=Z_brides*squeeze(delta_brides(x,:,:))+u_brides;
    clear delta_brides Z_brides u_brides;
    u_grooms=mvnrnd(zeros(1,44),squeeze(sigma_grooms(x,:,:)),8038);
    clear sigma_grooms;
    beta_grooms=Z_grooms*squeeze(delta_grooms(x,:,:))+u_grooms;
    clear delta_grooms Z_grooms u_grooms;
    save beta;
    clear beta_grooms;
    load stable_hetero.mat;
    V=single(zeros(8038,39));
    J=uint16(zeros(8038,14172));
    A=single(zeros(14172,1));
    
    V(:,1)=males(:,6);
    V(:,2)=males(:,10);
    V(:,3)=males(:,12);
    V(:,4)=males(:,9);
    V(:,5)=males(:,1);
    V(:,6)=males(:,7);
    V(:,31)=males(:,8);
    V(:,32)=males(:,5)==2;
    V(:,33)=males(:,5)==3;
    V(:,34)=males(:,5)==4;
    V(:,35)=males(:,5)==5;
    V(:,36)=males(:,5)==6;
    V(:,37)=males(:,5)==7;
    V(:,38)=males(:,6)==8;
    V(:,39)=males(:,36);
    N=horzcat(males(:,5),males(:,2),males(:,31),males(:,3), males(:,11));
    clear males;
    I=single(ones(8038,1));

    j=1;
    while j<14173
        fem_j=horzcat(females(j,5)*I,females(j,6)*I, females(j,3)*I, females(j,10)*I, females(j,11)*I, females(j,12)*I, females(j,2)*I, females(j,9)*I,females(j,1)*I, females(j,7)*I, females(j,29)*I, females(j,30)*I, females(j,31)*I); 
        V(:,7)=V(:,1).*fem_j(:,2);
        V(:,9)=V(:,4).*fem_j(:,8);
        V(:,8)=(N(:,2)==fem_j(:,7)).*(1-V(:,9));
        V(:,10)=V(:,6).*fem_j(:,10);
        V(:,14)=(V(:,5)==fem_j(:,9)).*(1-V(:,10));
        V(:,11)=V(:,2).*fem_j(:,4);
        V(:,12)=V(:,3).*fem_j(:,6);
        V(:,13)=N(:,3)==fem_j(:,13)|(N(:,3)==1 & fem_j(:,1)==1)|(N(:,3)==18 & fem_j(:,1)==2)|(N(:,3)==9 & fem_j(:,1)==3)|(N(:,3)==20 & fem_j(:,3)==4 & fem_j(:,13)~=24 & fem_j(:,13)~=83 & fem_j(:,13)~=87 & fem_j(:,13)~=105)|(N(:,3)==16 & (fem_j(:,13)==17|fem_j(:,13)==100))|(N(:,3)==25 & ((fem_j(:,13)>=26 & fem_j(:,13)<=30)|fem_j(:,13)==35|fem_j(:,13)==37|fem_j(:,13)==39|fem_j(:,13)==100|fem_j(:,13)==105|fem_j(:,13)==107))|(N(:,3)==31 & (fem_j(:,13)==32|fem_j(:,13)==33|fem_j(:,13)==40|fem_j(:,13)==41|fem_j(:,13)==85))|(N(:,3)==34 & fem_j(:,13)==35)|(N(:,3)==36 & fem_j(:,13)==37)|(N(:,3)==38 & fem_j(:,13)==39)|(N(:,3)==42 & fem_j(:,13)==43)|(N(:,3)==44 & (fem_j(:,13)==45|fem_j(:,13)==46))|(N(:,3)==53 & fem_j(:,13)==54)|(N(:,3)==56 & fem_j(:,13)==57)|(N(:,3)==58 & (fem_j(:,13)>=59 & fem_j(:,13)<=63))|(N(:,3)==79 & fem_j(:,1)==8)|(fem_j(:,13)==1 & N(:,1)==1)|(N(:,1)==2 & fem_j(:,13)==18)|(N(:,1)==3 & fem_j(:,13)==9)|(N(:,1)==4 & fem_j(:,13)==20 & N(:,3)~=24 & N(:,3)~=83 & N(:,3)~=87 & N(:,3)~=105)|((N(:,3)==17|N(:,3)==100) & fem_j(:,13)==16)|(fem_j(:,13)==25 & ((N(:,3)>=26 & N(:,3)<=30)|N(:,3)==35|N(:,3)==37|N(:,3)==39|N(:,3)==100|N(:,3)==105|N(:,3)==107))|(fem_j(:,13)==31 & (N(:,3)==32|N(:,3)==33|N(:,3)==40|N(:,3)==41|N(:,3)==85))|(N(:,3)==35 & fem_j(:,13)==34)|(N(:,3)==37 & fem_j(:,13)==36)|(N(:,3)==39 & fem_j(:,13)==38)|(N(:,3)==43 & fem_j(:,13)==42)|(fem_j(:,13)==44 & (N(:,3)==45|N(:,3)==46))|(N(:,3)==54 & fem_j(:,13)==53)|(N(:,3)==57 & fem_j(:,13)==56)|(fem_j(:,13)==58 & (N(:,3)>=59 & N(:,3)<=63))|(N(:,1)==8 & fem_j(:,13)==79);
        V(:,15)=(N(:,1)-fem_j(:,1)).*(N(:,1)<fem_j(:,1)).*(N(:,1)~=0);
        V(:,16)=(N(:,1)-fem_j(:,1)).*(N(:,1)>fem_j(:,1)).*(fem_j(:,1)~=0);
        V(:,25)=V(:,13).*fem_j(:,11);
        V(:,26)=(V(:,15)+V(:,16)).*fem_j(:,11);
        V(:,27)=V(:,1).*fem_j(:,11);
        V(:,28)=V(:,13).*fem_j(:,12);
        V(:,29)=(V(:,15)+V(:,16)).*fem_j(:,12);
        V(:,30)=V(:,1).*fem_j(:,12);
        V(:,17)=(N(:,4)-fem_j(:,3)).*(1-V(:,2)).*(1-fem_j(:,4));
        V(:,18)=(N(:,5)-fem_j(:,5)).*(1-V(:,3)).*(1-fem_j(:,6));
        V(:,19)=V(:,17).^2;
        V(:,20)=V(:,18).^2;
        V(:,21)=N(:,4).*fem_j(:,4);
        V(:,22)=V(:,2).*fem_j(:,3);
        V(:,23)=N(:,5).*fem_j(:,6);
        V(:,24)=V(:,3).*fem_j(:,5);  
        X=single(10000*V*beta_brides(j,:)');
        [A,M]=sort(X,'descend');
        clear A;
        i=1;
        while i<8039
            J(M(i,1),j)=i;
            i=i+1;
        end;
        clear M;
        j=j+1;
    end;

    clear N X V beta_brides I fem_j females j;

    K=mean(J');
    [A,J3]=sort(K, 'ascend');
    J2=uint16(J3);
    clear A;
    clear K;
    clear J3;
    clear J;
    clear i;
    save('J2');

    load stable_hetero.mat;
    load beta;
    clear beta_brides;
    load J2;
    i=1;
    while i<8039
        male(i,:)=males(J2(1,i),:);
        b_grooms(i,:)=beta_grooms(J2(1,i),:);
        i=i+1;
    end;
    clear males beta_grooms;
    males=male;
    beta_grooms=b_grooms;
    clear male b_grooms;
    clear J2;
    save ('stable2_hetero');
    clear;
    
    load beta;
    clear beta_grooms;
    save beta;
    clear;

    load stable2_hetero.mat;
    V(:,1)=females(:,6);
    V(:,2)=females(:,10);
    V(:,3)=females(:,12);
    V(:,4)=females(:,4);
    V(:,5)=females(:,13);
    V(:,6)=females(:,9);
    V(:,7)=females(:,1);
    V(:,8)=females(:,7);
    V(:,9)=females(:,15);
    V(:,10)=females(:,14);
    V(:,11)=females(:,16);
    V(:,36)=females(:,8);
    V(:,37)=females(:,5)==2;
    V(:,38)=females(:,5)==3;
    V(:,39)=females(:,5)==4;
    V(:,40)=females(:,5)==5;
    V(:,41)=females(:,5)==6;
    V(:,42)=females(:,5)==7;
    V(:,43)=females(:,5)==8;
    V(:,44)=females(:,36);
    J=horzcat(females(:,5), females(:,2), females(:,31), females(:,3), females(:,11));
    clear females;
    N=single(ones(14172,1));
    i=1;

    while i<8039
        fem_j=horzcat(males(i,5)*N,males(i,6)*N, males(i,3)*N, males(i,10)*N, males(i,11)*N, males(i,12)*N, males(i,2)*N, males(i,9)*N, males(i,1)*N, males(i,7)*N, males(i,29)*N, males(i,30)*N, males(i,31)*N); 
		V(:,12)=V(:,1).*fem_j(:,2);
        V(:,14)=V(:,6).*fem_j(:,8);
        V(:,13)=(J(:,2)==fem_j(:,7)).*(1-V(:,14));
        V(:,15)=V(:,8).*fem_j(:,10);
        V(:,16)=V(:,2).*fem_j(:,4);
        V(:,17)=V(:,3).*fem_j(:,6);
        V(:,18)=J(:,3)==fem_j(:,13)|(J(:,3)==1 & fem_j(:,1)==1)|(J(:,3)==18 & fem_j(:,1)==2)|(J(:,3)==9 & fem_j(:,1)==3)|(J(:,3)==20 & fem_j(:,1)==4 & fem_j(:,13)~=24 & fem_j(:,13)~=83 & fem_j(:,13)~=87 & fem_j(:,13)~=105)|(J(:,3)==16 & (fem_j(:,13)==17|fem_j(:,13)==100))|(J(:,3)==25 & ((fem_j(:,13)>=26 & fem_j(:,13)<=30)|fem_j(:,13)==35|fem_j(:,13)==37|fem_j(:,13)==39|fem_j(:,13)==100|fem_j(:,13)==105|fem_j(:,13)==107))|(J(:,3)==31 & (fem_j(:,13)==32|fem_j(:,13)==33|fem_j(:,13)==40|fem_j(:,13)==41|fem_j(:,13)==85))|(J(:,3)==34 & fem_j(:,13)==35)|(J(:,3)==36 & fem_j(:,13)==37)|(J(:,3)==38 & fem_j(:,13)==39)|(J(:,3)==42 & fem_j(:,13)==43)|(J(:,3)==44 & (fem_j(:,13)==45|fem_j(:,13)==46))|(J(:,3)==53 & fem_j(:,13)==54)|(J(:,3)==56 & fem_j(:,13)==57)|(J(:,3)==58 & (fem_j(:,13)>=59 & fem_j(:,13)<=63))|(J(:,3)==79 & fem_j(:,1)==8)|(fem_j(:,13)==1 & J(:,1)==1)|(J(:,1)==2 & fem_j(:,13)==18)|(J(:,1)==3 & fem_j(:,13)==9)|(J(:,1)==4 & fem_j(:,13)==20 & J(:,3)~=24 & J(:,3)~=83 & J(:,3)~=87 & J(:,3)~=105)|((J(:,3)==17|J(:,3)==100) & fem_j(:,13)==16)|(fem_j(:,13)==25 & ((J(:,3)>=26 & J(:,3)<=30)|J(:,3)==35|J(:,3)==37|J(:,3)==39|J(:,3)==100|J(:,3)==105|J(:,3)==107))|(fem_j(:,13)==31 & (J(:,3)==32|J(:,3)==33|J(:,3)==40|J(:,3)==41|J(:,3)==85))|(J(:,3)==35 & fem_j(:,13)==34)|(J(:,3)==37 & fem_j(:,13)==36)|(J(:,3)==39 & fem_j(:,13)==38)|(J(:,3)==43 & fem_j(:,13)==42)|(fem_j(:,13)==44 & (J(:,3)==45|J(:,3)==46))|(J(:,3)==54 & fem_j(:,13)==53)|(J(:,3)==57 & fem_j(:,13)==56)|(fem_j(:,13)==58 & (J(:,3)>=59 & J(:,3)<=63))|(J(:,1)==8 & fem_j(:,13)==79);
        V(:,19)=(V(:,7)==fem_j(:,9)).*(1-V(:,15));
        V(:,20)=(fem_j(:,1)-J(:,1)).*(fem_j(:,1)<J(:,1)).*(1-fem_j(:,2));
        V(:,21)=(fem_j(:,1)-J(:,1)).*(fem_j(:,1)>J(:,1)).*(J(:,1)~=0);
        V(:,22)=(fem_j(:,3)-J(:,4)).*(1-V(:,2)).*(1-fem_j(:,4));
        V(:,23)=(fem_j(:,5)-J(:,5)).*(1-V(:,3)).*(1-fem_j(:,6));
        V(:,24)=V(:,22).^2;
        V(:,25)=V(:,23).^2;
        V(:,26)=J(:,4).*fem_j(:,4);
        V(:,27)=V(:,2).*fem_j(:,3);
        V(:,28)=J(:,5).*fem_j(:,6);
        V(:,29)=V(:,3).*fem_j(:,5);
        V(:,30)=V(:,18).*fem_j(:,11);
        V(:,31)=(V(:,20)+V(:,21)).*fem_j(:,11);
        V(:,32)=V(:,1).*fem_j(:,11);
        V(:,33)=V(:,18).*fem_j(:,12);
        V(:,34)=(V(:,20)+V(:,21)).*fem_j(:,12);
        V(:,35)=V(:,1).*fem_j(:,12);
        X=single(10000*V*beta_grooms(i,:)');
        [A,B]=sort(X,'descend');
        I(:,i)=uint16(B);
        clear A B;
        i=i+1;
    end;

    clear J X V beta_grooms N fem_j males j;
    save('I');

    load stable2_hetero.mat;
    clear beta_grooms;
    load beta;
    V=single(zeros(8038,39));
    J=uint16(zeros(8038,14172));
    A=single(zeros(14172,1));
    
    V(:,1)=males(:,6);
    V(:,2)=males(:,10);
    V(:,3)=males(:,12);
    V(:,4)=males(:,9);
    V(:,5)=males(:,1);
    V(:,6)=males(:,7);
    V(:,31)=males(:,8);
    V(:,32)=males(:,5)==2;
    V(:,33)=males(:,5)==3;
    V(:,34)=males(:,5)==4;
    V(:,35)=males(:,5)==5;
    V(:,36)=males(:,5)==6;
    V(:,37)=males(:,5)==7;
    V(:,38)=males(:,6)==8;
    V(:,39)=males(:,36);
    N=horzcat(males(:,5),males(:,2),males(:,31),males(:,3), males(:,11));
    clear males;
    I=single(ones(8038,1));

    j=1;
    while j<14173
        fem_j=horzcat(females(j,5)*I,females(j,6)*I, females(j,3)*I, females(j,10)*I, females(j,11)*I, females(j,12)*I, females(j,2)*I, females(j,9)*I,females(j,1)*I, females(j,7)*I, females(j,29)*I, females(j,30)*I, females(j,31)*I); 
        V(:,7)=V(:,1).*fem_j(:,2);
        V(:,9)=V(:,4).*fem_j(:,8);
        V(:,8)=(N(:,2)==fem_j(:,7)).*(1-V(:,9));
        V(:,10)=V(:,6).*fem_j(:,10);
        V(:,14)=(V(:,5)==fem_j(:,9)).*(1-V(:,10));
        V(:,11)=V(:,2).*fem_j(:,4);
        V(:,12)=V(:,3).*fem_j(:,6);
        V(:,13)=N(:,3)==fem_j(:,13)|(N(:,3)==1 & fem_j(:,1)==1)|(N(:,3)==18 & fem_j(:,1)==2)|(N(:,3)==9 & fem_j(:,1)==3)|(N(:,3)==20 & fem_j(:,3)==4 & fem_j(:,13)~=24 & fem_j(:,13)~=83 & fem_j(:,13)~=87 & fem_j(:,13)~=105)|(N(:,3)==16 & (fem_j(:,13)==17|fem_j(:,13)==100))|(N(:,3)==25 & ((fem_j(:,13)>=26 & fem_j(:,13)<=30)|fem_j(:,13)==35|fem_j(:,13)==37|fem_j(:,13)==39|fem_j(:,13)==100|fem_j(:,13)==105|fem_j(:,13)==107))|(N(:,3)==31 & (fem_j(:,13)==32|fem_j(:,13)==33|fem_j(:,13)==40|fem_j(:,13)==41|fem_j(:,13)==85))|(N(:,3)==34 & fem_j(:,13)==35)|(N(:,3)==36 & fem_j(:,13)==37)|(N(:,3)==38 & fem_j(:,13)==39)|(N(:,3)==42 & fem_j(:,13)==43)|(N(:,3)==44 & (fem_j(:,13)==45|fem_j(:,13)==46))|(N(:,3)==53 & fem_j(:,13)==54)|(N(:,3)==56 & fem_j(:,13)==57)|(N(:,3)==58 & (fem_j(:,13)>=59 & fem_j(:,13)<=63))|(N(:,3)==79 & fem_j(:,1)==8)|(fem_j(:,13)==1 & N(:,1)==1)|(N(:,1)==2 & fem_j(:,13)==18)|(N(:,1)==3 & fem_j(:,13)==9)|(N(:,1)==4 & fem_j(:,13)==20 & N(:,3)~=24 & N(:,3)~=83 & N(:,3)~=87 & N(:,3)~=105)|((N(:,3)==17|N(:,3)==100) & fem_j(:,13)==16)|(fem_j(:,13)==25 & ((N(:,3)>=26 & N(:,3)<=30)|N(:,3)==35|N(:,3)==37|N(:,3)==39|N(:,3)==100|N(:,3)==105|N(:,3)==107))|(fem_j(:,13)==31 & (N(:,3)==32|N(:,3)==33|N(:,3)==40|N(:,3)==41|N(:,3)==85))|(N(:,3)==35 & fem_j(:,13)==34)|(N(:,3)==37 & fem_j(:,13)==36)|(N(:,3)==39 & fem_j(:,13)==38)|(N(:,3)==43 & fem_j(:,13)==42)|(fem_j(:,13)==44 & (N(:,3)==45|N(:,3)==46))|(N(:,3)==54 & fem_j(:,13)==53)|(N(:,3)==57 & fem_j(:,13)==56)|(fem_j(:,13)==58 & (N(:,3)>=59 & N(:,3)<=63))|(N(:,1)==8 & fem_j(:,13)==79);
        V(:,15)=(N(:,1)-fem_j(:,1)).*(N(:,1)<fem_j(:,1)).*(N(:,1)~=0);
        V(:,16)=(N(:,1)-fem_j(:,1)).*(N(:,1)>fem_j(:,1)).*(fem_j(:,1)~=0);
        V(:,25)=V(:,13).*fem_j(:,11);
        V(:,26)=(V(:,15)+V(:,16)).*fem_j(:,11);
        V(:,27)=V(:,1).*fem_j(:,11);
        V(:,28)=V(:,13).*fem_j(:,12);
        V(:,29)=(V(:,15)+V(:,16)).*fem_j(:,12);
        V(:,30)=V(:,1).*fem_j(:,12);
        V(:,17)=(N(:,4)-fem_j(:,3)).*(1-V(:,2)).*(1-fem_j(:,4));
        V(:,18)=(N(:,5)-fem_j(:,5)).*(1-V(:,3)).*(1-fem_j(:,6));
        V(:,19)=V(:,17).^2;
        V(:,20)=V(:,18).^2;
        V(:,21)=N(:,4).*fem_j(:,4);
        V(:,22)=V(:,2).*fem_j(:,3);
        V(:,23)=N(:,5).*fem_j(:,6);
        V(:,24)=V(:,3).*fem_j(:,5);
        X=single(10000*V*beta_brides(j,:)');
        [A,M]=sort(X,'descend');
        clear A;
        i=1;
        while i<8039
            J(M(i,1),j)=i;
            i=i+1;
        end;
        clear M;
        j=j+1;
    end;
    clear N X V beta_brides I fem_j females males j;

    load I;
    i=1;
    nturns=uint16(zeros(8038,1));
    rank=uint16(zeros(1,14172));
    choice=uint16(zeros(8038,1));
    onesMatrix=uint16(ones(8038,1));

    while i<8039
        if choice(i,1)==0
            k=nturns(i,1)+1;
            while k<14173
            D=uint16(find((I(k,i)*onesMatrix)==choice));
                if D & J(i,I(k,i))<J(D,I(k,i))
                    choice(D,1)=0;
                    choice(i,1)=I(k,i);
                    nturns(i,1)=k;
                    rank(1,I(k,i))=J(i,I(k,i));
                    k=14173;
                    i=D-1;
                elseif D & J(i,I(k,i))>=J(D,I(k,i))
                    k=k+1;
                else
                    choice(i,1)=I(k,i);
                    nturns(i,1)=k;
                    rank(1,I(k,i))=J(i,I(k,i));
                    k=14173;
                end
            end
        end
    i=i+1;
    end
    clear k D I onesMatrix J;
    load J2;
    i=1;
    while i<8039
        nturns_n(J2(1,i),1)=uint16(nturns(i,1));
        choice_n(J2(1,i),1)=uint16(choice(i,1));
        i=i+1;
    end;
    clear J2 i choice nturns;
    load('results_hetero');
    choice_matrix(:,x)=choice_n;
    nturns_matrix(:,x)=nturns_n;
    rank_female_matrix(:,x)=rank';
    clear choice_n nturns_n rank;
    save('results_hetero', 'choice_matrix', 'nturns_matrix', 'rank_female_matrix');
    clear nturns_n choice_n rank filename rank_female *_matrix;
    x=x+1
    toc
end;

clear;
load('results_hetero');
csvwrite('choice_hetero.csv', choice_matrix);
