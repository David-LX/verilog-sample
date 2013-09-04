// Clock_Gen.v
/****************ΪLCD_Drvierģ�����500Hz��ʱ���ź�**************/
module Clock_Gen(clk_48M,rst,clk_LCD);
input   clk_48M,rst;                //rstΪȫ�ָ�λ�źţ��ߵ�ƽ��Ч��              
output  clk_LCD;   
wire    clk_counter;
reg     [11:0]  cnt;                  //��ʱ�ӽ��м�����Ƶ
wire    clk_equ;
reg     [9:0] count;
reg     clk_BUF;
parameter       counter= 50;     //���ٷ�Ƶ
/********************************************************************************
** ģ�����ƣ���Ƶ��
** ����������ͨ��������ʵ�ַ�Ƶ����.
********************************************************************************/
always@(posedge clk_48M)
begin
 if(!rst)                            //�͵�ƽ��λ
  cnt <= 12'd0;
 else
 if(clk_equ)
  cnt <= 12'd0;
 else
     cnt <= cnt+1'b1;
end
assign clk_equ = (cnt==counter);
assign clk_counter = clk_equ;               
always @(posedge clk_counter or negedge rst)
begin                                   //���ü�������Ƶ����500Hzʱ��
    if(!rst)
        begin 
            clk_BUF <= 1'b0;
            count <= 10'b0;
        end
    else
    begin   
        if(count == 10'd1000) 
            begin
                clk_BUF <= ~clk_BUF;
                count <= 10'b0;
            end     
        else
            begin
                clk_BUF <= clk_BUF;     //clk_BUFΪ500Hz��ʱ���ź�
                count <= count + 1'b1;
            end
    end
end
assign  clk_LCD = clk_BUF;
//clk_LCDΪLCD_Drvierģ������Ҫ��500Hz��ʱ���ź�
endmodule
