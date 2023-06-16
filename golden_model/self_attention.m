%% datatype: double 
L = 32;
D = 96;
In = randn(L,D);
W  = randn(D,D/2,6);
QKV = pagemtimes(In, W);
QK = cat(3, QKV(:,:,1) * QKV(:,:,3)', QKV(:,:,2) * QKV(:,:,4)');
Att = [QK(:,:,1) * QKV(:,:,5) , QK(:,:,2) * QKV(:,:,6)];

%% datatype: 8bit fi
q_type = fi([],1,8,3); % WordLength: 8; FractionLength: 3   ranging from -16 to 15.875
q_In = cast(In,'like',q_type);
q_W = cast(W,'like',q_type);
% calculate Q K V matrix and quantify
for i = 1:6
    fi_QKV(:,:,i) = q_In * q_W(:,:,i);
end
scale_factor_QKV = -2;
fi_QKV_scale = bitshift(fi_QKV, scale_factor_QKV); % fi_QKV >> 2
q_QKV = cast(fi_QKV_scale,'like',q_type);
% calculate Q * K^T and quantify
fi_QK(:,:,1) = q_QKV(:,:,1) * q_QKV(:,:,3)';
fi_QK(:,:,2) = q_QKV(:,:,2) * q_QKV(:,:,4)';
scale_factor_QK = -4;
fi_QK_scale = bitshift(fi_QK, scale_factor_QK); % fi_QK >> 4
q_QK = cast(fi_QK_scale,'like',q_type);
% calculate QK * V and quantify
fi_Att = [q_QK(:,:,1) * q_QKV(:,:,5) , q_QK(:,:,2) * q_QKV(:,:,6)];
scale_factor_Att = -4;
fi_Att_scale = bitshift(fi_Att, scale_factor_Att); % fi_Att >> 4
q_Att = cast(fi_Att_scale,'like',q_type);

%% write Input.dat
fid=fopen('./dat_file/Input.dat','wt');
fprintf(fid,'%d\n',size(q_In,1));
fprintf(fid,'%d\n',size(q_In,2));
for i=1:size(q_In,1)
    for j=1:size(q_In,2)
        fprintf(fid,'%s',bin(q_In(i,j)));
    end
    fprintf(fid,'\n');
end
fclose(fid);

%% write Weight.dat
fid=fopen('./dat_file/Weight.dat','wt');
fprintf(fid,'%d\n',size(q_W,1));
fprintf(fid,'%d\n',size(q_W,2));
fprintf(fid,'%d\n',size(q_W,3));
for k=1:size(q_W,3)
    for i=1:size(q_W,1)
        for j=1:size(q_W,2)
            fprintf(fid,'%s',bin(q_W(i,j,k)));
        end
        fprintf(fid,'\n');
    end
end
fclose(fid);

%% write QKV.dat
fid=fopen('./dat_file/QKV.dat','wt');
fprintf(fid,'%d\n',size(q_QKV,1));
fprintf(fid,'%d\n',size(q_QKV,2));
fprintf(fid,'%d\n',size(q_QKV,3));
for k=1:size(q_QKV,3)
    for i=1:size(q_QKV,1)
        for j=1:size(q_QKV,2)
            fprintf(fid,'%s',bin(q_QKV(i,j,k)));
        end
        fprintf(fid,'\n');
    end
end
fclose(fid);

%% write QK.dat
fid=fopen('./dat_file/QK.dat','wt');
fprintf(fid,'%d\n',size(q_QK,1));
fprintf(fid,'%d\n',size(q_QK,2));
fprintf(fid,'%d\n',size(q_QK,3));
for k=1:size(q_QK,3)
    for i=1:size(q_QK,1)
        for j=1:size(q_QK,2)
            fprintf(fid,'%s',bin(q_QK(i,j,k)));
        end
        fprintf(fid,'\n');
    end
end
fclose(fid);

%% write Result.dat
fid=fopen('./dat_file/Result.dat','wt');
fprintf(fid,'%d\n',size(q_Att,1));
fprintf(fid,'%d\n',size(q_Att,2));
for i=1:size(q_Att,1)
    for j=1:size(q_Att,2)
        fprintf(fid,'%s',bin(q_Att(i,j)));
    end
    fprintf(fid,'\n');
end
fclose(fid);