////////////////////////////////////////////////////////////////////////////////
//  Company: �ɶ������ܿƼ� Ruichuang Smart Technology                      //
//           http://ruicstech.taobao.com                                      // 
//  Engineer:      Youzhiyu                                                   //
//  QQ      :      4016682                                                    //
//  Target Device: MAXII240T100C5N                                            //
//  Tool versions: Quartus II 7.2                                             //
//  Create Date:   2011-09-06 10:09                                           //
//  Description:                                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
// 	   Copyright (C) 2011-2012  Youzhiyu   All rights reserved                //
//----------------------------------------------------------------------------//
////////////////////////////////////////////////////////////////////////////////

module	autoreset(
				clk,
				rst_n,
				clkout,
				arst_n		
				);

input		clk; //50MHzʱ������
input		rst_n; //��λ�ź����룬�͵�ƽ��Ч
output	    arst_n;//��λ�ź�������͵�ƽ��Ч
output      clkout;//ʱ���ź������50MHz

//----------------------------------------
// ϵͳʱ��50M ��Ƶ
parameter	DIV	= 25_000_00;
reg	 [24:0] count;
reg  clk_div;
always @(posedge clk)
begin
   if( count == DIV)//��Ƶ�Ƚ�
	 begin
	 count <= 0;
	 clk_div = ~clk_div;//�ź�ȡ��
	 end
   else
	 count <= count + 1'b1;//��1����
end
//----------------------------------------

//----------------------------------------
reg	 [7:0] cnt;
reg  rst_tmp;
always @(posedge clk_div)
begin
   if (cnt<1)
     begin
       rst_tmp=0;
       cnt =cnt+1;
     end
   else
       rst_tmp=1;
end
//----------------------------------------
assign arst_n=rst_tmp&rst_n;
assign clkout=rst_tmp&clk;
endmodule