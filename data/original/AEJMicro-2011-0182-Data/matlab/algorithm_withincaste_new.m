size_male=[220;2094;269;127;2275;1554;1008;123;368];
size_female=[252;3601;581;251;4112;2520;1816;265;774];
z=0;
while z<9;
    filename=['all_males_matlab_caste',num2str(z),'.csv'];
    males=csvread(filename);
    filename=['all_females_matlab_caste',num2str(z),'.csv'];
    females=csvread(filename);
    beta_brides=csvread('beta_brides_sigma.csv');
    beta_brides=beta_brides(:,1:57);
    beta_brides=beta_brides';
    beta_grooms=csvread('beta_grooms_sigma.csv');
    beta_grooms=beta_grooms(:,1:58);
    beta_grooms=beta_grooms';
    save ('stable', 'males','females', 'beta_brides', 'beta_grooms');
    clear males females beta_brides beta_grooms filename;
    
     filename=['results_caste',num2str(z)];
     choice_matrix=zeros(size_male(z+1,1),1000);
     nturns_matrix=zeros(size_male(z+1,1),1000);
     rank_female_matrix=zeros(size_female(z+1,1),1000);
     save(filename, 'choice_matrix', 'nturns_matrix', 'rank_female_matrix');
     clear choice_matrix nturns_matrix rank_female_matrix filename;
    
    x=1;
    while x<251
        load stable.mat;
        clear beta_grooms;
        B_brides=beta_brides(:,x);
        clear beta_brides;
        V=single(zeros(size_male(z+1,1),57));
        J=uint16(zeros(size_male(z+1,1),size_female(z+1,1)));
        A=single(zeros(size_female(z+1,1),1));

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
        V(:,57)=ones(size_male(z+1,1),1);

        N=horzcat(males(:,5),males(:,17),males(:,2),males(:,31), males(:,3), males(:,11));
        clear males;
        I=single(ones(size_male(z+1,1),1));

      
        j=1;
        while j<size_female(z+1,1)+1
            fem_j=horzcat(females(j,5)*I,females(j,6)*I, females(j,3)*I, females(j,10)*I, females(j,11)*I, females(j,12)*I, females(j,17)*I, females(j,18)*I, females(j,19)*I, females(j,4)*I, females(j,13)*I,females(j,2)*I,females(j,9)*I,females(j,1)*I, females(j,7)*I, females(j,15)*I, females(j,14)*I, females(j,16)*I, females(j,29)*I, females(j,30)*I, females(j,31)*I);
            V(:,8)=N(:,4)==fem_j(:,21)|(N(:,4)==1 & fem_j(:,1)==1)|(N(:,4)==18 & fem_j(:,1)==2)|(N(:,4)==9 & fem_j(:,1)==3)|(N(:,4)==20 & fem_j(:,1)==4 & fem_j(:,21)~=24 & fem_j(:,21)~=83 & fem_j(:,21)~=87 & fem_j(:,21)~=105)|(N(:,4)==16 & (fem_j(:,21)==17|fem_j(:,21)==100))|(N(:,4)==25 & ((fem_j(:,21)>=26 & fem_j(:,21)<=30)|fem_j(:,21)==35|fem_j(:,21)==37|fem_j(:,21)==39|fem_j(:,21)==100|fem_j(:,21)==105|fem_j(:,21)==107))|(N(:,4)==31 & (fem_j(:,21)==32|fem_j(:,21)==33|fem_j(:,21)==40|fem_j(:,21)==41|fem_j(:,21)==85))|(N(:,4)==34 & fem_j(:,21)==35)|(N(:,4)==36 & fem_j(:,21)==37)|(N(:,4)==38 & fem_j(:,21)==39)|(N(:,4)==42 & fem_j(:,21)==43)|(N(:,4)==44 & (fem_j(:,21)==45|fem_j(:,21)==46))|(N(:,4)==53 & fem_j(:,21)==54)|(N(:,4)==56 & fem_j(:,21)==57)|(N(:,4)==58 & (fem_j(:,21)>=59 & fem_j(:,21)<=63))|(N(:,4)==79 & fem_j(:,1)==8)|(fem_j(:,21)==1 & N(:,1)==1)|(N(:,1)==2 & fem_j(:,21)==18)|(N(:,1)==3 & fem_j(:,21)==9)|(N(:,1)==4 & fem_j(:,21)==20 & N(:,4)~=24 & N(:,4)~=83 & N(:,4)~=87 & N(:,4)~=105)|((N(:,4)==17|N(:,4)==100) & fem_j(:,21)==16)|(fem_j(:,21)==25 & ((N(:,4)>=26 & N(:,4)<=30)|N(:,4)==35|N(:,4)==37|N(:,4)==39|N(:,4)==100|N(:,4)==105|N(:,4)==107))|(fem_j(:,21)==31 & (N(:,4)==32|N(:,4)==33|N(:,4)==40|N(:,4)==41|N(:,4)==85))|(N(:,4)==35 & fem_j(:,21)==34)|(N(:,4)==37 & fem_j(:,21)==36)|(N(:,4)==39 & fem_j(:,21)==38)|(N(:,4)==43 & fem_j(:,21)==42)|(fem_j(:,21)==44 & (N(:,4)==45|N(:,4)==46))|(N(:,4)==54 & fem_j(:,21)==53)|(N(:,4)==57 & fem_j(:,21)==56)|(fem_j(:,21)==58 & (N(:,4)>=59 & N(:,4)<=63))|(N(:,1)==8 & fem_j(:,21)==79);                    V(:,19)=fem_j(:,4).*N(:,5);
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
            i=1;
            while i<size_male(z+1,1)+1
                if V(i,8)==0
                    X(i,1)=-10000000;
                end;
                i=i+1;
            end;
            [A,M]=sort(X,'descend');
            i=1;
            while i<size_male(z+1,1)+1
                J(M(i,1),j)=i;
                if A(i,1)==-10000000;
                    J(M(i,1),j)=20000;
                end;
                i=i+1;
            end;
            clear A M;
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
        while i<size_male(z+1,1)+1
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
        V=single(zeros(size_female(z+1,1),57));
        I=uint16(zeros(size_female(z+1,1),size_male(z+1,1)));
        A=single(zeros(size_female(z+1,1),1));
        B=uint16(zeros(size_female(z+1,1),1));

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
        V(:,58)=ones(size_female(z+1,1),1);

        J=horzcat(females(:,5), females(:,17), females(:,2), females(:,31), females(:,3), females(:,11));
        clear females;
        N=single(ones(size_female(z+1,1),1));
        i=1;

        while i<size_male(z+1,1)+1
            fem_j=horzcat(males(i,5)*N,males(i,6)*N, males(i,29)*N, males(i,30)*N, males(i,3)*N, males(i,10)*N, males(i,11)*N, males(i,12)*N, males(i,17)*N, males(i,19)*N, males(i,2)*N, males(i,9)*N, males(i,1)*N, males(i,7)*N, males(i,31)*N); 
            V(:,8)=J(:,4)==fem_j(:,15)|(J(:,4)==1 & fem_j(:,1)==1)|(J(:,4)==18 & fem_j(:,1)==2)|(J(:,4)==9 & fem_j(:,1)==3)|(J(:,4)==20 & fem_j(:,1)==4 & fem_j(:,15)~=24 & fem_j(:,15)~=83 & fem_j(:,15)~=87 & fem_j(:,15)~=105)|(J(:,4)==16 & (fem_j(:,15)==17|fem_j(:,15)==100))|(J(:,4)==25 & ((fem_j(:,15)>=26 & fem_j(:,15)<=30)|fem_j(:,15)==35|fem_j(:,15)==37|fem_j(:,15)==39|fem_j(:,15)==100|fem_j(:,15)==105|fem_j(:,15)==107))|(J(:,4)==31 & (fem_j(:,15)==32|fem_j(:,15)==33|fem_j(:,15)==40|fem_j(:,15)==41|fem_j(:,15)==85))|(J(:,4)==34 & fem_j(:,15)==35)|(J(:,4)==36 & fem_j(:,15)==37)|(J(:,4)==38 & fem_j(:,15)==39)|(J(:,4)==42 & fem_j(:,15)==43)|(J(:,4)==44 & (fem_j(:,15)==45|fem_j(:,15)==46))|(J(:,4)==53 & fem_j(:,15)==54)|(J(:,4)==56 & fem_j(:,15)==57)|(J(:,4)==58 & (fem_j(:,15)>=59 & fem_j(:,15)<=63))|(J(:,4)==79 & fem_j(:,1)==8)|(fem_j(:,15)==1 & J(:,1)==1)|(J(:,1)==2 & fem_j(:,15)==18)|(J(:,1)==3 & fem_j(:,15)==9)|(J(:,1)==4 & fem_j(:,15)==20 & J(:,4)~=24 & J(:,4)~=83 & J(:,4)~=87 & J(:,4)~=105)|((J(:,4)==17|J(:,4)==100) & fem_j(:,15)==16)|(fem_j(:,15)==25 & ((J(:,4)>=26 & J(:,4)<=30)|J(:,4)==35|J(:,4)==37|J(:,4)==39|J(:,4)==100|J(:,4)==105|J(:,4)==107))|(fem_j(:,15)==31 & (J(:,4)==32|J(:,4)==33|J(:,4)==40|J(:,4)==41|J(:,4)==85))|(J(:,4)==35 & fem_j(:,15)==34)|(J(:,4)==37 & fem_j(:,15)==36)|(J(:,4)==39 & fem_j(:,15)==38)|(J(:,4)==43 & fem_j(:,15)==42)|(fem_j(:,15)==44 & (J(:,4)==45|J(:,4)==46))|(J(:,4)==54 & fem_j(:,15)==53)|(J(:,4)==57 & fem_j(:,15)==56)|(fem_j(:,15)==58 & (J(:,4)>=59 & J(:,4)<=63))|(J(:,1)==8 & fem_j(:,15)==79);
            V(:,20)=V(:,23).*fem_j(:,5);
		V(:,21)=(fem_j(:,6)~=1 & V(:,23)~=1).*((fem_j(:,5)-J(:,5)));
            V(:,22)=V(:,21).^2;
            V(:,24)=fem_j(:,6).*V(:,23);
            V(:,25)=fem_j(:,8).*J(:,6);
            V(:,26)=V(:,29).*fem_j(:,7);
		V(:,27)=(fem_j(:,8)~=1 & V(:,29)~=1).*((fem_j(:,7)-J(:,6)));
		V(:,28)=V(:,27).^2;
		V(:,30)=fem_j(:,8).*V(:,29);
		V(:,36)=(fem_j(:,10)~=1 & V(:,43)~=1).*(J(:,2)==fem_j(:,9));
		V(:,37)=(fem_j(:,10)~=1 & V(:,43)~=1).*(J(:,2)<fem_j(:,9));
		V(:,42)=fem_j(:,10).*V(:,43);
		V(:,48)=(V(:,49)~=1 & fem_j(:,13)~=1).*(fem_j(:,12)==J(:,3));
		V(:,50)=fem_j(:,12).*V(:,49);
            V(:,52)=(V(:,53)~=1 & fem_j(:,14)~=1).*(V(:,51)==fem_j(:,13));
            V(:,54)=V(:,53).*fem_j(:,14);
            X=single(10000*V*B_grooms);
            j=1;
            while j<size_female(z+1,1)+1
                if V(j,8)==0
                    X(j,1)=-10000000;
                end;
                j=j+1;
            end;
            [A,B]=sort(X,'descend');
            I(:,i)=uint16(B);
            j=1;
            while j<size_female(z+1,1)+1
                if A(j,1)==-10000000;
                    I(j,i)=0;
                end;
                j=j+1;
            end;
            clear A B;
            i=i+1;
        end;

        clear J X V B_grooms N fem_j males j;
        save('I');

        load stable2.mat;
        clear beta_grooms;
        B_brides=beta_brides(:,x);
        clear beta_brides;
        V=single(zeros(size_male(z+1,1),57));
        A=single(zeros(size_female(z+1,1),1));

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
        V(:,57)=ones(size_male(z+1,1),1);

        N=horzcat(males(:,5),males(:,17),males(:,2),males(:,31), males(:,3), males(:,11));
        clear males;
        I=single(ones(size_male(z+1,1),1));
      
        j=1;
        while j<size_female(z+1,1)+1
            fem_j=horzcat(females(j,5)*I,females(j,6)*I, females(j,3)*I, females(j,10)*I, females(j,11)*I, females(j,12)*I, females(j,17)*I, females(j,18)*I, females(j,19)*I, females(j,4)*I, females(j,13)*I,females(j,2)*I,females(j,9)*I,females(j,1)*I, females(j,7)*I, females(j,15)*I, females(j,14)*I, females(j,16)*I, females(j,29)*I, females(j,30)*I, females(j,31)*I);
            V(:,8)=N(:,4)==fem_j(:,21)|(N(:,4)==1 & fem_j(:,1)==1)|(N(:,4)==18 & fem_j(:,1)==2)|(N(:,4)==9 & fem_j(:,1)==3)|(N(:,4)==20 & fem_j(:,1)==4 & fem_j(:,21)~=24 & fem_j(:,21)~=83 & fem_j(:,21)~=87 & fem_j(:,21)~=105)|(N(:,4)==16 & (fem_j(:,21)==17|fem_j(:,21)==100))|(N(:,4)==25 & ((fem_j(:,21)>=26 & fem_j(:,21)<=30)|fem_j(:,21)==35|fem_j(:,21)==37|fem_j(:,21)==39|fem_j(:,21)==100|fem_j(:,21)==105|fem_j(:,21)==107))|(N(:,4)==31 & (fem_j(:,21)==32|fem_j(:,21)==33|fem_j(:,21)==40|fem_j(:,21)==41|fem_j(:,21)==85))|(N(:,4)==34 & fem_j(:,21)==35)|(N(:,4)==36 & fem_j(:,21)==37)|(N(:,4)==38 & fem_j(:,21)==39)|(N(:,4)==42 & fem_j(:,21)==43)|(N(:,4)==44 & (fem_j(:,21)==45|fem_j(:,21)==46))|(N(:,4)==53 & fem_j(:,21)==54)|(N(:,4)==56 & fem_j(:,21)==57)|(N(:,4)==58 & (fem_j(:,21)>=59 & fem_j(:,21)<=63))|(N(:,4)==79 & fem_j(:,1)==8)|(fem_j(:,21)==1 & N(:,1)==1)|(N(:,1)==2 & fem_j(:,21)==18)|(N(:,1)==3 & fem_j(:,21)==9)|(N(:,1)==4 & fem_j(:,21)==20 & N(:,4)~=24 & N(:,4)~=83 & N(:,4)~=87 & N(:,4)~=105)|((N(:,4)==17|N(:,4)==100) & fem_j(:,21)==16)|(fem_j(:,21)==25 & ((N(:,4)>=26 & N(:,4)<=30)|N(:,4)==35|N(:,4)==37|N(:,4)==39|N(:,4)==100|N(:,4)==105|N(:,4)==107))|(fem_j(:,21)==31 & (N(:,4)==32|N(:,4)==33|N(:,4)==40|N(:,4)==41|N(:,4)==85))|(N(:,4)==35 & fem_j(:,21)==34)|(N(:,4)==37 & fem_j(:,21)==36)|(N(:,4)==39 & fem_j(:,21)==38)|(N(:,4)==43 & fem_j(:,21)==42)|(fem_j(:,21)==44 & (N(:,4)==45|N(:,4)==46))|(N(:,4)==54 & fem_j(:,21)==53)|(N(:,4)==57 & fem_j(:,21)==56)|(fem_j(:,21)==58 & (N(:,4)>=59 & N(:,4)<=63))|(N(:,1)==8 & fem_j(:,21)==79);                    V(:,19)=fem_j(:,4).*N(:,5);
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
            i=1;
            while i<size_male(z+1,1)+1
                if V(i,8)==0
                    X(i,1)=-10000000;
                end;
                i=i+1;
            end;
            [A,M]=sort(X,'descend');
            i=1;
            while i<size_male(z+1,1)+1
                J(M(i,1),j)=i;
                if A(i,1)==-10000000;
                    J(M(i,1),j)=20000;
                end;
                i=i+1;
            end;
            clear A M;
            j=j+1;
        end;

        clear N X V B_grooms B_brides I fem_j females males j;

        load I;
        i=1;
        nturns=uint16(zeros(size_male(z+1,1),1));
        rank=uint16(zeros(1,size_female(z+1,1)));
        choice=uint16(zeros(size_male(z+1,1),1));
        ones=uint16(ones(size_male(z+1,1),1));

        while i<size_male(z+1,1)+1
            if choice(i,1)==0
                k=nturns(i,1)+1;
                while k<size_female(z+1,1)+1
                    if I(k,i)==0
                        k=size_female(z+1,1)+1;
                    else
                        D=uint16(find((I(k,i)*ones)==choice));
                        if D & J(i,I(k,i))<J(D,I(k,i))
                            choice(D,1)=0;
                            choice(i,1)=I(k,i);
                            nturns(i,1)=k;
                            rank(1,I(k,i))=J(i,I(k,i));
                            k=size_female(z+1,1)+1;
                            i=D-1;
                        elseif D & J(i,I(k,i))>=J(D,I(k,i))
                            k=k+1;
                        elseif D==0 & J(i,I(k,i))==20000;
                            k=k+1;
                        else
                            choice(i,1)=I(k,i);
                            nturns(i,1)=k;
                            rank(1,I(k,i))=J(i,I(k,i));
                            k=size_female(z+1,1)+1;
                        end
                    end;
                end
            end
        i=i+1;
        end
        clear I D k ones;
        load J2;
        i=1;
        while i<size_male(z+1,1)+1
            nturns_n(J2(1,i),1)=uint16(nturns(i,1));
            choice_n(J2(1,i),1)=uint16(choice(i,1));
            i=i+1;
        end;
        clear J2 choice nturns i;
        filename=['results_caste',num2str(z)];
        load(filename);
        choice_matrix(:,x)=choice_n;
        nturns_matrix(:,x)=nturns_n;
        rank_female_matrix(:,x)=rank';
        clear choice_n nturns_n rank;
        save(filename, 'choice_matrix', 'nturns_matrix', 'rank_female_matrix');
        clear nturns_n choice_n rank filename rank_female *_matrix;  
        x=x+1;
    end;
    
    filename=['results_caste',num2str(z)];
    load(filename);
    filename=['choice_caste',num2str(z),'.csv'];
    csvwrite(filename, choice_matrix);
    clear *_matrix;
    z=z+1
end;
