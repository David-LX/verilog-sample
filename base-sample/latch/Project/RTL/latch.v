module latch8 ( 
             //input 
             oe_n      ,
             le        ,
             data_in   ,
             //output 
             data_out );

// I/O�˿����� 
input        oe_n             ; // ��̬ʹ���ź�
input        le               ; // ����ʹ���ź� 
input  [7:0] data_in          ; // 8λ�������� 
output [7:0] data_out         ; // 8λ������� 
reg    [7:0] data_out         ;

//******************************************************** 
// ������������ɰ�λ�������Ĺ��� 
//******************************************************** 

always @ (*) begin 
	if ( oe_n == 1'b1 )    // ������� 
	   data_out = 8'hzz; 
    else if ( le == 1'b1 ) // ����͸�����
	   data_out = data_in;
    else ;
end

endmodule 
