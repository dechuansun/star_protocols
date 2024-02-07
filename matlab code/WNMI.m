%--------------------------------------------------- %
% window_length: length of the epoch
% data_set: raw data
% filter_data: binarized data
% index_1:start time frame index
% index_2:end time frame index
% e.g. window_length of the epoch is 160 frames, index_1 =1, index_2=150
% means to calculate the WNMI using time frames 1 to 150.
%--------------------------------------------------- %
function mutual_info=calculate_mutual_info(window_length,data_set,filter_data,index_1,index_2)

neuron_num=size(data_set,2);
epoch_num=size(data_set,1);
epoch_length=size(data_set,3);
ingredient=0:window_length;
trial_length=index_1(2)-index_1(1)+1;

Px=[0.5 0.5];
mutual_info=[];
window_data=[];
window_data_real=[];
for j=1:epoch_length
        temp_index=[j-floor(window_length/2) j+floor(window_length/2)-1];
        temp_index(temp_index<1)=1; temp_index(temp_index>epoch_length)=epoch_length; 
        group=squeeze(sum(data_set(:,:,temp_index(1):temp_index(2)),3));
        window_data(:,:,j)=group;
        
         group_real=squeeze(sum(filter_data(:,:,temp_index(1):temp_index(2)),3));  
        group_real(isnan(group_real))=0;
        window_data_real(:,:,j)=group_real;
end    

window_data_all=cat(1,window_data(:,:,index_1(1):index_1(2)),window_data(:,:,index_2(1):index_2(2)));
window_data_all=permute(window_data_all,[2,3,1]);
window_data_real_all=cat(1,window_data_real(:,:,index_1(1):index_1(2)),window_data_real(:,:,index_2(1):index_2(2)));
window_data_real_all=permute(window_data_real_all,[2,3,1]);

Py=[];
Pxy=[];

information=zeros(neuron_num,trial_length);
Wxy=[];

mean_fire_rate=mean(window_data_real_all,3);
mean_fire_rate=mean(mean_fire_rate,2);
for k=1:size(ingredient,2)
        temp=ingredient(k);  
        logical_index=(window_data_all==temp);
            
                Pxy(:,:,1,k)=sum(logical_index(:,:,1:epoch_num),3);        
                Pxy(:,:,2,k)=sum(logical_index(:,:,epoch_num+1:epoch_num*2),3);           

                if k==1
                     Wxy(:,:,1,k)= mean_fire_rate*ones(1,trial_length)*Inf;                   
                     Wxy(:,:,2,k)= Wxy(:,:,1,k);  

                else
                    temp_2=window_data_real_all.*logical_index;
                    temp_2=squeeze(mean(temp_2,3));
                    Wxy(:,:,1,k)=temp_2;       
                    Wxy(:,:,2,k)=Wxy(:,:,1,k);      
                end
                Py(:,:,k)=Pxy(:,:,1,k)+ Pxy(:,:,2,k);  

end

Py=Py/(epoch_num*2);
Pxy=Pxy/(epoch_num*2);  
Wxy=1./(1+exp(-1*(Wxy-mean_fire_rate)));
;


Uwx=zeros(neuron_num,trial_length);
Uwy=zeros(neuron_num,trial_length);

for k1=1:size(Px,2)
    for k2=1:size(ingredient,2)
        temp=Pxy(:,:,k1,k2).*Wxy(:,:,k1,k2).*log2(Pxy(:,:,k1,k2)./(Px(k1)*Py(:,:,k2)));
        temp(isnan(temp))=0;
        information=information+temp;
        
        temp_Uwx=Wxy(:,:,k1,k2).*Pxy(:,:,k1,k2).*(-log2(Px(k1))-1+(Px(k1)*Py(:,:,k2))./Pxy(:,:,k1,k2));
        temp_Uwx(isnan(temp_Uwx))=0;
        Uwx=Uwx+temp_Uwx;
        
        temp_Uwy=Wxy(:,:,k1,k2).*Pxy(:,:,k1,k2).*(-log2(Py(:,:,k2))-1+(Px(k1)*Py(:,:,k2))./Pxy(:,:,k1,k2));
        temp_Uwy(isnan(temp_Uwy))=0;
        Uwy=Uwy+temp_Uwy;
    end 
end 

mutual_info=information./min(Uwx,Uwy);    
mutual_info(isnan(mutual_info))=0; 


end