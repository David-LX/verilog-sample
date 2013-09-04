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

module	clk_div(
				clk_in,
				clk_out		
				);

input		clk_in; //50MHzʱ������
output	    clk_out;//1Hzʱ�����
reg		    clk_out;

// ϵͳʱ��50M ��Ƶϵ�� 25M �õ�  1hz�ź�
parameter	DIV	= 25_000_000;

// 2 ^ 25	 = 32*1024*1024		
reg	 [24:0] count;

always @(posedge clk_in)
begin
		if( count == DIV)//��Ƶ�Ƚ�
		   begin
			  count <= 0;
			  clk_out = ~clk_out;//�ź�ȡ��
		   end
		else
			count <= count + 1'b1;//��1����
end
endmodule