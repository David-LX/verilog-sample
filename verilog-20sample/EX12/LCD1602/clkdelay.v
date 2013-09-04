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

module	clkdelay(
				clk,
				clkout	
				);

input		clk; //50MHzʱ������
output      clkout;//ʱ���ź������50MHz

//----------------------------------------
// ϵͳʱ��50M ��Ƶ
parameter	DIV	= 25_000_000;
reg	 [24:0] count;
reg  clk_delay;

always @(posedge clk)
begin
   if( count == DIV)//��Ƶ�Ƚ�
	 clk_delay=1;
   else
     begin
	 count <= count + 1'b1;//��1����
	 clk_delay=0;
	 end
end

assign clkout=clk_delay&clk;

endmodule
