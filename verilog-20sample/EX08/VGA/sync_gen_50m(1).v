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
module sync_gen_50m(
                    clk,
                    rst_n,
                    hsync,
                    vsync,
                    valid,
                    x_cnt,
                    y_cnt
                    );

input           clk;
input           rst_n;
output          hsync;
output          vsync;
output          valid;
output  [9:0]   x_cnt;
output  [9:0]   y_cnt;

reg             hsync;
reg             vsync;
reg             valid;
reg     [9:0]   x_cnt;
reg     [9:0]   y_cnt;

  // ---------------------------------------------------------------------------
  // ����Always �п���ʹ����ͬ���ж�����
  // ---------------------------------------------------------------------------
  always @ ( posedge clk or negedge rst_n )
    if ( !rst_n )
      x_cnt <= 10'd0;
    else if ( x_cnt == 10'd1000 )
      x_cnt <= 10'd0;
    else
      x_cnt <= x_cnt + 1'b1;
          
  always @ ( posedge clk or negedge rst_n )
    if ( !rst_n )
      y_cnt <= 10'd0;
    else if ( y_cnt == 10'd665 )
      y_cnt <= 10'd0;    
    else if ( x_cnt == 10'd1000 )
      y_cnt <= y_cnt + 1'b1;    

  // ---------------------------------------------------------------------------
  // hsync <= x_cnt <= 10'd50���е�һ����<=��Ϊ��ֵ��䣬�ڶ�����<=��Ϊ�Ƚ����
  // ������Ĳ���Ϊ���ȽϺ��ٸ�ֵ��
  // ---------------------------------------------------------------------------        
  always @ ( posedge clk or negedge rst_n )
    if ( !rst_n )
      begin
        hsync <= 1'b0;
        vsync <= 1'b0;
      end
    else
      begin
        hsync <= x_cnt <= 10'd50;  //����hsync�ź�
        vsync <= y_cnt <= 10'd6;   //����vsync�ź�
      end    
  
  always @ ( posedge clk or negedge rst_n )                     
    if ( !rst_n )
      valid <= 1'b0;
    else
      valid <= ( ( x_cnt > 10'd180 ) && ( x_cnt < 10'd980) &&
                 ( y_cnt > 10'd35)   && ( y_cnt < 10'd635) ); 
                      
endmodule 
