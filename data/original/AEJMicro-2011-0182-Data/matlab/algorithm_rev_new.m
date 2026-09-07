choice_matrix=zeros(14172,1000);
nturns_matrix=zeros(14172,1000);
rank_female_matrix=zeros(8038,1000);
save('results_rev');
clear;

males=csvread('all_males_matlab.csv');
females=csvread('all_females_matlab.csv');
beta_brides=csvread('beta_brides_sigma.csv');
beta_brides=beta_brides(:,1:57);
beta_brides=beta_brides';
beta_grooms=csvread('beta_grooms_sigma.csv');
beta_grooms=beta_grooms(:,1:58);
beta_grooms=beta_grooms';

save stable;

x=1;
while x<251
    load stable.mat;
    clear beta_brides;
    B_grooms=beta_grooms(:,x);
    clear beta_grooms;
    V=single(zeros(14172,58));
    J=uint16(zeros(14172,8038));

    V(:,1)=females(:,5)==2;
    V(:,2)=females(:,5)==3;
    V(:,3)=females(:,5)==4;
    V(:,4)=females(:,5)==5;
    V(:,5)=females(:,5)==6;
    V(:,6)=females(:,5)==7;
    V(:,7)=females(:,5)==8;
    V(:,11)=females(:,6);
    V(:,23)=females(:,10);
    V(:,29)=females(:,12);
    V(:,31)=females(:,17)==2;
    V(:,32)=females(:,17)==3;
    V(:,33)=females(:,17)==4;
    V(:,34)=females(:,17)==5;
    V(:,35)=females(:,17)==6;
    V(:,38)=females(:,18);
    V(:,39)=females(:,22);
    V(:,40)=females(:,21);
    V(:,41)=females(:,23);
    V(:,43)=females(:,19);
    V(:,44)=females(:,24);
    V(:,45)=females(:,4);
    V(:,46)=females(:,13);
    V(:,47)=females(:,2)==2;
    V(:,49)=females(:,9);
    V(:,51)=females(:,1);
    V(:,53)=females(:,7);
    V(:,55)=females(:,15);
    V(:,56)=females(:,14);
    V(:,57)=females(:,16);
    V(:,58)=ones(14172,1);
    
    I=horzcat(females(:,5), females(:,17), females(:,2), females(:,31), females(:,3), females(:,11));
    clear females;
    N=single(ones(14172,1));
    i=1;

    while i<8039
        fem_j=horzcat(males(i,5)*N,males(i,6)*N, males(i,29)*N, males(i,30)*N, males(i,3)*N, males(i,10)*N, males(i,11)*N, males(i,12)*N, males(i,17)*N, males(i,19)*N, males(i,2)*N, males(i,9)*N, males(i,1)*N, males(i,7)*N, males(i,31)*N); 
		V(:,8)=I(:,4)==fem_j(:,15)|(I(:,4)==1 & fem_j(:,1)==1)|(I(:,4)==18 & fem_j(:,1)==2)|(I(:,4)==9 & fem_j(:,1)==3)|(I(:,4)==20 & fem_j(:,1)==4 & fem_j(:,15)~=24 & fem_j(:,15)~=83 & fem_j(:,15)~=87 & fem_j(:,15)~=105)|(I(:,4)==16 & (fem_j(:,15)==17|fem_j(:,15)==100))|(I(:,4)==25 & ((fem_j(:,15)>=26 & fem_j(:,15)<=30)|fem_j(:,15)==35|fem_j(:,15)==37|fem_j(:,15)==39|fem_j(:,15)==100|fem_j(:,15)==105|fem_j(:,15)==107))|(I(:,4)==31 & (fem_j(:,15)==32|fem_j(:,15)==33|fem_j(:,15)==40|fem_j(:,15)==41|fem_j(:,15)==85))|(I(:,4)==34 & fem_j(:,15)==35)|(I(:,4)==36 & fem_j(:,15)==37)|(I(:,4)==38 & fem_j(:,15)==39)|(I(:,4)==42 & fem_j(:,15)==43)|(I(:,4)==44 & (fem_j(:,15)==45|fem_j(:,15)==46))|(I(:,4)==53 & fem_j(:,15)==54)|(I(:,4)==56 & fem_j(:,15)==57)|(I(:,4)==58 & (fem_j(:,15)>=59 & fem_j(:,15)<=63))|(I(:,4)==79 & fem_j(:,1)==8)|(fem_j(:,15)==1 & I(:,1)==1)|(I(:,1)==2 & fem_j(:,15)==18)|(I(:,1)==3 & fem_j(:,15)==9)|(I(:,1)==4 & fem_j(:,15)==20 & I(:,4)~=24 & I(:,4)~=83 & I(:,4)~=87 & I(:,4)~=105)|((I(:,4)==17|I(:,4)==100) & fem_j(:,15)==16)|(fem_j(:,15)==25 & ((I(:,4)>=26 & I(:,4)<=30)|I(:,4)==35|I(:,4)==37|I(:,4)==39|I(:,4)==100|I(:,4)==105|I(:,4)==107))|(fem_j(:,15)==31 & (I(:,4)==32|I(:,4)==33|I(:,4)==40|I(:,4)==41|I(:,4)==85))|(I(:,4)==35 & fem_j(:,15)==34)|(I(:,4)==37 & fem_j(:,15)==36)|(I(:,4)==39 & fem_j(:,15)==38)|(I(:,4)==43 & fem_j(:,15)==42)|(fem_j(:,15)==44 & (I(:,4)==45|I(:,4)==46))|(I(:,4)==54 & fem_j(:,15)==53)|(I(:,4)==57 & fem_j(:,15)==56)|(fem_j(:,15)==58 & (I(:,4)>=59 & I(:,4)<=63))|(I(:,1)==8 & fem_j(:,15)==79);
        V(:,9)=(I(:,1)-fem_j(:,1)).*(I(:,1)>fem_j(:,1)).*(fem_j(:,1)~=0);
        V(:,10)=(I(:,1)-fem_j(:,1)).*(I(:,1)<fem_j(:,1)).*(I(:,1)~=0);     
        V(:,12)=fem_j(:,2).*V(:,11);
        V(:,13)=fem_j(:,3).*V(:,8);
        V(:,14)=fem_j(:,3).*(V(:,9)+V(:,10));
        V(:,15)=fem_j(:,3).*V(:,11);
        V(:,16)=fem_j(:,4).*V(:,8);
        V(:,17)=fem_j(:,4).*(V(:,9)+V(:,10));
        V(:,18)=fem_j(:,4).*V(:,11);
        V(:,19)=fem_j(:,6).*I(:,5);
        V(:,20)=V(:,23).*fem_j(:,5);
        V(:,21)=(fem_j(:,6)~=1 & V(:,23)~=1).*((fem_j(:,5)-I(:,5)));
        V(:,22)=V(:,21).^2;
        V(:,24)=fem_j(:,6).*V(:,23);
        V(:,25)=fem_j(:,8).*I(:,6);
        V(:,26)=V(:,29).*fem_j(:,7);
        V(:,27)=(fem_j(:,8)~=1 & V(:,29)~=1).*((fem_j(:,7)-I(:,6)));
        V(:,28)=V(:,27).^2;
        V(:,30)=fem_j(:,8).*V(:,29);
        V(:,36)=(fem_j(:,10)~=1& V(:,43)~=1).*(I(:,2)==fem_j(:,9));
        V(:,37)=(fem_j(:,10)~=1& V(:,43)~=1).*(I(:,2)<fem_j(:,9));
        V(:,42)=fem_j(:,10).*V(:,43);
        V(:,48)=(V(:,49)~=1 & fem_j(:,13)~=1).*(fem_j(:,12)==I(:,3));
        V(:,50)=fem_j(:,12).*V(:,49);
        V(:,52)=(V(:,53)~=1 & fem_j(:,14)~=1).*(V(:,51)==fem_j(:,13));
        V(:,54)=fem_j(:,14).*V(:,53);
        X=single(10000*V*B_grooms);
        [A,M]=sort(X,'descend');
        clear A X;
        j=1;
        while j<14173
            J(M(j,1),i)=j;
            j=j+1;
        end;
        clear M;
        i=i+1;
    end;

    clear N I V B_grooms B_brides fem_j males j i;

    K=mean(J');
    clear J;
    [A,J3]=sort(K, 'ascend');
    clear A K;
    J2=uint16(J3);
    clear J3;
    save('J2');

    load stable.mat;
    load J2;
    female=zeros(14172,35);
    i=1;
    while i<14173
        female(i,:)=females(J2(1,i),:);
        i=i+1;
    end;
    clear females i J2;
    females=female;
    clear female;
    save ('stable2');

        
    load stable2.mat;
    clear beta_grooms;
    B_brides=beta_brides(:,x);
    clear beta_brides;
    V=single(zeros(8038,57));
    I=uint16(zeros(8038,14172));

    V(:,1)=males(:,5)==2;
    V(:,2)=males(:,5)==3;
    V(:,3)=males(:,5)==4;
    V(:,4)=males(:,5)==5;
    V(:,5)=males(:,5)==6;
    V(:,6)=males(:,5)==7;
    V(:,7)=males(:,5)==8;
    V(:,11)=males(:,6);
    V(:,23)=males(:,10);
    V(:,29)=males(:,12);
    V(:,31)=males(:,17)==2;
    V(:,32)=males(:,17)==3;
    V(:,33)=males(:,17)==4;
    V(:,34)=males(:,17)==5;
    V(:,35)=males(:,17)==6;
    V(:,38)=males(:,18);
    V(:,39)=males(:,22);
    V(:,40)=males(:,21);
    V(:,41)=males(:,23);
    V(:,42)=males(:,19);
    V(:,44)=males(:,24);
    V(:,45)=males(:,25);
    V(:,46)=males(:,26);
    V(:,47)=males(:,2)==2;
    V(:,49)=males(:,9);
    V(:,51)=males(:,1);
    V(:,53)=males(:,7);
    V(:,55)=males(:,27);
    V(:,56)=males(:,28);
    V(:,57)=ones(8038,1);

    N=horzcat(males(:,5),males(:,17),males(:,2),males(:,31), males(:,3), males(:,11));
    clear males;
    J=single(ones(8038,1));

    j=1;
    while j<14173
        fem_j=horzcat(females(j,5)*J,females(j,6)*J, females(j,3)*J, females(j,10)*J, females(j,11)*J, females(j,12)*J, females(j,17)*J, females(j,18)*J, females(j,19)*J, females(j,4)*J, females(j,13)*J,females(j,2)*J,females(j,9)*J,females(j,1)*J, females(j,7)*J, females(j,15)*J, females(j,14)*J, females(j,16)*J, females(j,29)*J, females(j,30)*J, females(j,31)*J);
        V(:,8)=N(:,4)==fem_j(:,21)|(N(:,4)==1 & fem_j(:,1)==1)|(N(:,4)==18 & fem_j(:,1)==2)|(N(:,4)==9 & fem_j(:,1)==3)|(N(:,4)==20 & fem_j(:,1)==4 & fem_j(:,21)~=24 & fem_j(:,21)~=83 & fem_j(:,21)~=87 & fem_j(:,21)~=105)|(N(:,4)==16 & (fem_j(:,21)==17|fem_j(:,21)==100))|(N(:,4)==25 & ((fem_j(:,21)>=26 & fem_j(:,21)<=30)|fem_j(:,21)==35|fem_j(:,21)==37|fem_j(:,21)==39|fem_j(:,21)==100|fem_j(:,21)==105|fem_j(:,21)==107))|(N(:,4)==31 & (fem_j(:,21)==32|fem_j(:,21)==33|fem_j(:,21)==40|fem_j(:,21)==41|fem_j(:,21)==85))|(N(:,4)==34 & fem_j(:,21)==35)|(N(:,4)==36 & fem_j(:,21)==37)|(N(:,4)==38 & fem_j(:,21)==39)|(N(:,4)==42 & fem_j(:,21)==43)|(N(:,4)==44 & (fem_j(:,21)==45|fem_j(:,21)==46))|(N(:,4)==53 & fem_j(:,21)==54)|(N(:,4)==56 & fem_j(:,21)==57)|(N(:,4)==58 & (fem_j(:,21)>=59 & fem_j(:,21)<=63))|(N(:,4)==79 & fem_j(:,1)==8)|(fem_j(:,21)==1 & N(:,1)==1)|(N(:,1)==2 & fem_j(:,21)==18)|(N(:,1)==3 & fem_j(:,21)==9)|(N(:,1)==4 & fem_j(:,21)==20 & N(:,4)~=24 & N(:,4)~=83 & N(:,4)~=87 & N(:,4)~=105)|((N(:,4)==17|N(:,4)==100) & fem_j(:,21)==16)|(fem_j(:,21)==25 & ((N(:,4)>=26 & N(:,4)<=30)|N(:,4)==35|N(:,4)==37|N(:,4)==39|N(:,4)==100|N(:,4)==105|N(:,4)==107))|(fem_j(:,21)==31 & (N(:,4)==32|N(:,4)==33|N(:,4)==40|N(:,4)==41|N(:,4)==85))|(N(:,4)==35 & fem_j(:,21)==34)|(N(:,4)==37 & fem_j(:,21)==36)|(N(:,4)==39 & fem_j(:,21)==38)|(N(:,4)==43 & fem_j(:,21)==42)|(fem_j(:,21)==44 & (N(:,4)==45|N(:,4)==46))|(N(:,4)==54 & fem_j(:,21)==53)|(N(:,4)==57 & fem_j(:,21)==56)|(fem_j(:,21)==58 & (N(:,4)>=59 & N(:,4)<=63))|(N(:,1)==8 & fem_j(:,21)==79);        
	V(:,9)=(N(:,1)-fem_j(:,1)).*(N(:,1)<fem_j(:,1)).*(N(:,1)~=0);
        V(:,10)=(N(:,1)-fem_j(:,1)).*(N(:,1)>fem_j(:,1)).*(fem_j(:,1)~=0);
        V(:,12)=fem_j(:,2).*V(:,11);
        V(:,13)=fem_j(:,19).*V(:,8);
        V(:,14)=fem_j(:,19).*(V(:,9)+V(:,10));
	  V(:,15)=fem_j(:,19).*V(:,11);
        V(:,16)=fem_j(:,20).*V(:,8);
        V(:,17)=fem_j(:,20).*(V(:,9)+V(:,10));
        V(:,18)=fem_j(:,20).*V(:,11);
	   V(:,19)=fem_j(:,4).*N(:,5);
	   V(:,20)=V(:,23).*fem_j(:,3);
        V(:,21)=(fem_j(:,4)~=1 & V(:,23)~=1).*((N(:,5)-fem_j(:,3)));
        V(:,22)=V(:,21).^2;
        V(:,24)=fem_j(:,4).*V(:,23);
	   V(:,25)=fem_j(:,6).*N(:,6);
	   V(:,26)=V(:,29).*fem_j(:,5);
        V(:,27)=(fem_j(:,6)~=1 & V(:,29)~=1).*((N(:,6)-fem_j(:,5)));
        V(:,28)=V(:,27).^2;
        V(:,30)=fem_j(:,6).*V(:,29);
        V(:,36)=(fem_j(:,9)~=1& V(:,42)~=1).*(N(:,2)==fem_j(:,7));
        V(:,37)=(fem_j(:,9)~=1& V(:,42)~=1).*(N(:,2)>fem_j(:,7));
        V(:,43)=fem_j(:,9).*V(:,42);
        V(:,48)=(V(:,49)~=1 & fem_j(:,13)~=1).*(fem_j(:,12)==N(:,3));
        V(:,50)=fem_j(:,13).*V(:,49);
        V(:,52)=(V(:,53)~=1 & fem_j(:,15)~=1).*(V(:,51)==fem_j(:,14));
        V(:,54)=fem_j(:,15).*V(:,53);
        X=single(10000*V*B_brides);
        [A,B]=sort(X,'descend');
        I(:,j)=uint16(B);
        clear A B;
        j=j+1;
    end;

    clear J X V B_brides N fem_j females j;
    save('I');
    clear I;

    load stable2.mat;
    clear beta_brides;
    B_grooms=beta_grooms(:,x);
    clear beta_grooms;
    V=single(zeros(14172,58));
    J=uint16(zeros(14172,8038));

     V(:,1)=females(:,5)==2;
    V(:,2)=females(:,5)==3;
    V(:,3)=females(:,5)==4;
    V(:,4)=females(:,5)==5;
    V(:,5)=females(:,5)==6;
    V(:,6)=females(:,5)==7;
    V(:,7)=females(:,5)==8;
    V(:,11)=females(:,6);
    V(:,23)=females(:,10);
    V(:,29)=females(:,12);
    V(:,31)=females(:,17)==2;
    V(:,32)=females(:,17)==3;
    V(:,33)=females(:,17)==4;
    V(:,34)=females(:,17)==5;
    V(:,35)=females(:,17)==6;
    V(:,38)=females(:,18);
    V(:,39)=females(:,22);
    V(:,40)=females(:,21);
    V(:,41)=females(:,23);
    V(:,43)=females(:,19);
    V(:,44)=females(:,24);
    V(:,45)=females(:,4);
    V(:,46)=females(:,13);
    V(:,47)=females(:,2)==2;
    V(:,49)=females(:,9);
    V(:,51)=females(:,1);
    V(:,53)=females(:,7);
    V(:,55)=females(:,15);
    V(:,56)=females(:,14);
    V(:,57)=females(:,16);
    V(:,58)=ones(14172,1);

    I=horzcat(females(:,5), females(:,17), females(:,2), females(:,31), females(:,3), females(:,11));
    clear females;
    N=single(ones(14172,1));
    i=1;

    while i<8039
        fem_j=horzcat(males(i,5)*N,males(i,6)*N, males(i,29)*N, males(i,30)*N, males(i,3)*N, males(i,10)*N, males(i,11)*N, males(i,12)*N, males(i,17)*N, males(i,19)*N, males(i,2)*N, males(i,9)*N, males(i,1)*N, males(i,7)*N, males(i,31)*N); 
V(:,8)=I(:,4)==fem_j(:,15)|(I(:,4)==1 & fem_j(:,1)==1)|(I(:,4)==18 & fem_j(:,1)==2)|(I(:,4)==9 & fem_j(:,1)==3)|(I(:,4)==20 & fem_j(:,1)==4 & fem_j(:,15)~=24 & fem_j(:,15)~=83 & fem_j(:,15)~=87 & fem_j(:,15)~=105)|(I(:,4)==16 & (fem_j(:,15)==17|fem_j(:,15)==100))|(I(:,4)==25 & ((fem_j(:,15)>=26 & fem_j(:,15)<=30)|fem_j(:,15)==35|fem_j(:,15)==37|fem_j(:,15)==39|fem_j(:,15)==100|fem_j(:,15)==105|fem_j(:,15)==107))|(I(:,4)==31 & (fem_j(:,15)==32|fem_j(:,15)==33|fem_j(:,15)==40|fem_j(:,15)==41|fem_j(:,15)==85))|(I(:,4)==34 & fem_j(:,15)==35)|(I(:,4)==36 & fem_j(:,15)==37)|(I(:,4)==38 & fem_j(:,15)==39)|(I(:,4)==42 & fem_j(:,15)==43)|(I(:,4)==44 & (fem_j(:,15)==45|fem_j(:,15)==46))|(I(:,4)==53 & fem_j(:,15)==54)|(I(:,4)==56 & fem_j(:,15)==57)|(I(:,4)==58 & (fem_j(:,15)>=59 & fem_j(:,15)<=63))|(I(:,4)==79 & fem_j(:,1)==8)|(fem_j(:,15)==1 & I(:,1)==1)|(I(:,1)==2 & fem_j(:,15)==18)|(I(:,1)==3 & fem_j(:,15)==9)|(I(:,1)==4 & fem_j(:,15)==20 & I(:,4)~=24 & I(:,4)~=83 & I(:,4)~=87 & I(:,4)~=105)|((I(:,4)==17|I(:,4)==100) & fem_j(:,15)==16)|(fem_j(:,15)==25 & ((I(:,4)>=26 & I(:,4)<=30)|I(:,4)==35|I(:,4)==37|I(:,4)==39|I(:,4)==100|I(:,4)==105|I(:,4)==107))|(fem_j(:,15)==31 & (I(:,4)==32|I(:,4)==33|I(:,4)==40|I(:,4)==41|I(:,4)==85))|(I(:,4)==35 & fem_j(:,15)==34)|(I(:,4)==37 & fem_j(:,15)==36)|(I(:,4)==39 & fem_j(:,15)==38)|(I(:,4)==43 & fem_j(:,15)==42)|(fem_j(:,15)==44 & (I(:,4)==45|I(:,4)==46))|(I(:,4)==54 & fem_j(:,15)==53)|(I(:,4)==57 & fem_j(:,15)==56)|(fem_j(:,15)==58 & (I(:,4)>=59 & I(:,4)<=63))|(I(:,1)==8 & fem_j(:,15)==79);
        V(:,9)=(I(:,1)-fem_j(:,1)).*(I(:,1)>fem_j(:,1)).*(fem_j(:,1)~=0);
        V(:,10)=(I(:,1)-fem_j(:,1)).*(I(:,1)<fem_j(:,1)).*(I(:,1)~=0);     
        V(:,12)=fem_j(:,2).*V(:,11);
        V(:,13)=fem_j(:,3).*V(:,8);
        V(:,14)=fem_j(:,3).*(V(:,9)+V(:,10));
        V(:,15)=fem_j(:,3).*V(:,11);
        V(:,16)=fem_j(:,4).*V(:,8);
        V(:,17)=fem_j(:,4).*(V(:,9)+V(:,10));
        V(:,18)=fem_j(:,4).*V(:,11);
        V(:,19)=fem_j(:,6).*I(:,5);
        V(:,20)=V(:,23).*fem_j(:,5);
        V(:,21)=(fem_j(:,6)~=1 & V(:,23)~=1).*((fem_j(:,5)-I(:,5)));
        V(:,22)=V(:,21).^2;
        V(:,24)=fem_j(:,6).*V(:,23);
        V(:,25)=fem_j(:,8).*I(:,6);
        V(:,26)=V(:,29).*fem_j(:,7);
        V(:,27)=(fem_j(:,8)~=1 & V(:,29)~=1).*((fem_j(:,7)-I(:,6)));
        V(:,28)=V(:,27).^2;
        V(:,30)=fem_j(:,8).*V(:,29);
        V(:,36)=(fem_j(:,10)~=1& V(:,43)~=1).*(I(:,2)==fem_j(:,9));
        V(:,37)=(fem_j(:,10)~=1& V(:,43)~=1).*(I(:,2)<fem_j(:,9));
        V(:,42)=fem_j(:,10).*V(:,43);
        V(:,48)=(V(:,49)~=1 & fem_j(:,13)~=1).*(fem_j(:,12)==I(:,3));
        V(:,50)=fem_j(:,12).*V(:,49);
        V(:,52)=(V(:,53)~=1 & fem_j(:,14)~=1).*(V(:,51)==fem_j(:,13));
        V(:,54)=fem_j(:,14).*V(:,53);      
        X=single(10000*V*B_grooms);
        [A,M]=sort(X,'descend');
        clear A X;
        M=uint16(M);
        j=1;
        while j<14173
            J(M(j,1),i)=j;
            j=j+1;
        end;
        clear M;
	  J=uint16(J);
        i=i+1;
    end;
        
    clear N I V B_grooms fem_j males j;

    load I;
    i=1;
    nturns=uint16(zeros(14172,1));
    rank=uint16(zeros(1,8038));
    choice=uint16(zeros(14172,1));

    load I;
    i=1;
    nturns=uint16(zeros(14172,1));
    rank=uint16(zeros(1,8038));
    choice=uint16(zeros(14172,1));

    while i<14173
        if choice(i,1)==0 && nturns(i,1)<8038
            nturns(i,1)=nturns(i,1)+1;
            D=uint16(find(choice==I(nturns(i,1),i)));
            if D
                if J(i,I(nturns(i,1),i))<J(D,I(nturns(i,1),i))
                    choice(D,1)=0;
                    choice(i,1)=I(nturns(i,1),i);
                    rank(1,I(nturns(i,1),i))=J(i,I(nturns(i,1),i));
                    i=D-1;
                 else
                    i=i-1;
                end
            else
                choice(i,1)=I(nturns(i,1),i);
                rank(1,I(nturns(i,1),i))=J(i,I(nturns(i,1),i));
            end
        end
    i=i+1;
    end
    clear J D I;
    load J2;
    nturns_n=uint16(zeros(14172,1));
    choice_n=uint16(zeros(14172,1));
    i=1;
    while i<14173
        nturns_n(J2(1,i),1)=uint16(nturns(i,1));
        choice_n(J2(1,i),1)=uint16(choice(i,1));
        i=i+1;
    end;
    clear J2 nturns choice;
    load('results_rev');
    choice_matrix(:,x)=choice_n;
    nturns_matrix(:,x)=nturns_n;
    rank_female_matrix(:,x)=rank';
    clear choice_n nturns_n rank;
    save('results_rev', 'choice_matrix', 'nturns_matrix', 'rank_female_matrix');
    clear *_matrix;
    x=x+1
end;

clear;
load('results_rev');
csvwrite('choice_rev.csv', choice_matrix);
