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

`timescale 1ns/1ns

module song_top(
	              clk,
	              rst_n,
	              sp
               );
               
  input	   clk;//50MHzʱ������
  input	   rst_n; 
  output   sp;
//--------------------------------
  reg [23:0]  clk_cnt1;
  always @ (posedge clk)
    if (!rst_n )
        clk_cnt1 <= 24'd0;
    else
        clk_cnt1 <= clk_cnt1 + 1'b1;

  wire  clk_6mhz = clk_cnt1[2];//ʱ��8��Ƶ�źţ�ʵ��ֵΪ50MHz/8
  wire  clk_4hz  = clk_cnt1[23];//2��24���ݷ�Ƶ��ʵ��ֵΪ2.98Hz
      
  wire  [3 :0]  high,med,low;   
 //-------------------------------- 
  song song_inst(
    .clk_6mhz   (clk_6mhz), 
    .clk_4hz    (clk_4hz),
    .sp         ( sp    ),
    .high       ( high  ),
    .med        ( med   ),
    .low        ( low   )
    );

endmodule
