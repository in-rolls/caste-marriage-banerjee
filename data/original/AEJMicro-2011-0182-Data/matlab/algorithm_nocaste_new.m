choice_matrix=zeros(8038,1000);
nturns_matrix=zeros(8038,1000);
rank_female_matrix=zeros(14172,1000);
save('results');
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
    clear beta_grooms;
    B_brides=beta_brides(:,x);
    clear beta_brides;
    V=single(zeros(8038,57));
    J=uint16(zeros(8038,14172));
    A=single(zeros(14172,1));
    
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
    I=single(ones(8038,1));

    j=1;
    while j<14173
        fem_j=horzcat(females(j,5)*I,females(j,6)*I, females(j,3)*I, females(j,10)*I, females(j,11)*I, females(j,12)*I, females(j,17)*I, females(j,18)*I, females(j,19)*I, females(j,4)*I, females(j,13)*I,females(j,2)*I,females(j,9)*I,females(j,1)*I, females(j,7)*I, females(j,15)*I, females(j,14)*I, females(j,16)*I, females(j,29)*I, females(j,30)*I, females(j,31)*I);
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

    clear N X V B_grooms B_brides I fem_j females males j;

    K=mean(J');
    [A,J3]=sort(K, 'ascend');
    J2=uint16(J3);
    clear A;
    clear K;
    clear J3;
    clear J;
    clear i;
    save('J2');

    load stable.mat;
    load J2;
    i=1;
    while i<8039
        male(i,:)=males(J2(1,i),:);
        i=i+1;
    end;
    clear males;
    males=male;
    clear male;
    clear J2;
    save ('stable2');

    load stable2.mat;
    clear beta_brides;
    B_grooms=beta_grooms(:,x);
    clear beta_grooms;
    V=single(zeros(14172,58));
    I=uint16(zeros(14172,8038));
    A=single(zeros(14172,1));
    B=uint16(zeros(14172,1));

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

    J=horzcat(females(:,5), females(:,17), females(:,2), females(:,31), females(:,3), females(:,11));
    clear females;
    N=single(ones(14172,1));
    i=1;

    while i<8039
        fem_j=horzcat(males(i,5)*N,males(i,6)*N, males(i,29)*N, males(i,30)*N, males(i,3)*N, males(i,10)*N, males(i,11)*N, males(i,12)*N, males(i,17)*N, males(i,19)*N, males(i,2)*N, males(i,9)*N, males(i,1)*N, males(i,7)*N, males(i,31)*N); 
		V(:,19)=fem_j(:,6).*J(:,5);
	   V(:,20)=V(:,23).*fem_j(:,5);
        V(:,21)=(fem_j(:,6)~=1 & V(:,23)~=1).*((fem_j(:,5)-J(:,5)));
        V(:,22)=V(:,21).^2;
        V(:,24)=fem_j(:,6).*V(:,23);
	   V(:,25)=fem_j(:,8).*J(:,6);
	   V(:,26)=V(:,29).*fem_j(:,7);
        V(:,27)=(fem_j(:,8)~=1 & V(:,29)~=1).*((fem_j(:,7)-J(:,6)));
        V(:,28)=V(:,27).^2;
        V(:,30)=fem_j(:,8).*V(:,29);
        V(:,36)=(fem_j(:,10)~=1& V(:,43)~=1).*(J(:,2)==fem_j(:,9));
        V(:,37)=(fem_j(:,10)~=1& V(:,43)~=1).*(J(:,2)<fem_j(:,9));
        V(:,42)=fem_j(:,10).*V(:,43);
        V(:,48)=(V(:,49)~=1 & fem_j(:,13)~=1).*(fem_j(:,12)==J(:,3));
        V(:,50)=fem_j(:,12).*V(:,49);
        V(:,52)=(V(:,53)~=1 & fem_j(:,14)~=1).*(V(:,51)==fem_j(:,13));
        V(:,54)=fem_j(:,14).*V(:,53);
        X=single(10000*V*B_grooms);
        [A,B]=sort(X,'descend');
        I(:,i)=uint16(B);
        clear A B;
        i=i+1;
    end;

    clear J X V B_grooms N fem_j males j;
    save('I');

    load stable2.mat;
    clear beta_grooms;
    B_brides=beta_brides(:,x);
    clear beta_brides;
    V=single(zeros(8038,57));
    J=uint16(zeros(8038,14172));
    A=single(zeros(14172,1));

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
    I=single(ones(8038,1));

    j=1;
    while j<14173
        fem_j=horzcat(females(j,5)*I,females(j,6)*I, females(j,3)*I, females(j,10)*I, females(j,11)*I, females(j,12)*I, females(j,17)*I, females(j,18)*I, females(j,19)*I, females(j,4)*I, females(j,13)*I,females(j,2)*I,females(j,9)*I,females(j,1)*I, females(j,7)*I, females(j,15)*I, females(j,14)*I, females(j,16)*I, females(j,29)*I, females(j,30)*I, females(j,31)*I);
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

    clear N X V B_grooms B_brides I fem_j females males j;

    load I;
    i=1;
    nturns=uint16(zeros(8038,1));
    rank=uint16(zeros(1,14172));
    choice=uint16(zeros(8038,1));
    ones=uint16(ones(8038,1));

    while i<8039
        if choice(i,1)==0
            k=nturns(i,1)+1;
            while k<14173
            D=uint16(find((I(k,i)*ones)==choice));
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
    load J2;
    i=1;
    while i<8039
        nturns_n(J2(1,i),1)=uint16(nturns(i,1));
        choice_n(J2(1,i),1)=uint16(choice(i,1));
        i=i+1;
    end;
    clear choice D k ones;
    load('results');
    choice_matrix(:,x)=choice_n;
    nturns_matrix(:,x)=nturns_n;
    rank_female_matrix(:,x)=rank';
    clear choice_n nturns_n rank;
    save('results', 'choice_matrix', 'nturns_matrix', 'rank_female_matrix');
    clear nturns_n choice_n rank filename rank_female *_matrix;
    x=x+1;
end;

clear;
load('results');
csvwrite('choice_nocaste.csv', choice_matrix);
