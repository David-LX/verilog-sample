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

  // ---------------------------------------------------------------------------
  //HC164��������������Լ�LEDָʾ�ƣ���̬ɨ������ܵ��������Ӿ����������Խ�����
  //ʾ���������˵��Ӿ�ӡ���ھ�����ʧ����������Ĥ�ϱ���0��1���ʱ������Ӿ���
  //�������Խ�����ˢ�����ʿ���Ϊ10Hz(0.1s)��ͬʱ������Ҫ����λ���ݽ���ɨ�裬���
  //����ˢ���������Ӧ��Ϊ10Hz��4����߿���Ϊ50MHz(HC164���Թ�����50��175MHz)��
  //����ʵ��������ǿ��Զ�Ϊ 762.939453125 = 50MHz/2**16,
  //��˽ӿڴ�led,seg_value,dot���ݵı仯��������ܳ���Ϊ50MHz/2**14
  // ---------------------------------------------------------------------------

module hc164_driver(
    clk,
    rst_n,
    dot,
    seg_value,
    hc_cp,
    hc_si
    );

  // ---------------------------------------------------------------------------
  //
  //  input signals
  //  seg_value[15:0] :8λ������������ʾ�����ݣ��Ӹߵ���ÿ4bitΪ�����һλ��
  //  dot[7:0] :       8λ�������������ʾ��С����λ���Ӹߵ���
  //  hc_si :          ��ģ�����ݴ��������hc164���ݴ������롣
  //  hc_cp :          ��ģ�������hc164ʱ�����롣
  //  
  // ---------------------------------------------------------------------------
  input           clk;
  input           rst_n;   
  input   [7 :0]  dot;       
  input   [31:0]  seg_value; 
  output  reg     hc_cp;                //HC164 Clock input active Rising edges
  output          hc_si;                //HC164 Data input

  reg     [5 :0]  tx_cnt;
 
  // ---------------------------------------------------------------------------
  //
  //  �ź�����˵��
  //  hc_data : �͵�����hc164��16bit�����ݣ�ÿ��hc164��8bit����hc164 data input
  //  hc_data_H8bit: hc_data�ĵ�8λλ�����ݣ�
  //                 ��Ӧԭ��ͼ��HC_Q15,HC_Q14,HC_Q13,HC_Q12,HC_Q11,HC_Q10,HC_Q9,
  //                 HC_Q8�����λѡ�źţ��ߵ�ƽ��Ч��
  //  hc_data_Dpbit: hc_data�ĵ�7λ���ݣ���hc_data[7];��Ӧԭ��ͼ��HC_Q7����
  //                 ���С����λ���͵�ƽ��Ч�� 
  //  hc_data[6:0]: ��7bit������Ϊ����ܶ�ѡ�źţ��ߵ�ƽ��Ч
  //
  // ---------------------------------------------------------------------------
  reg   [6:0]   hex2led;        //hex-to-seven-segment decoder output 
  reg   [7:0]   hc_data_H8bit;  
  reg           hc_data_Dpbit;    
  
  wire  [15:0]  hc_data = {hc_data_H8bit,
                          hc_data_Dpbit,
                          hex2led[6:0]
                          };
  // ---------------------------------------------------------------------------
  //
  //  ֮������Ҫȡ��������Ϊ��hc_si��ֵʱ�����λ��ʼ,��ԭ��ͼ�����ϣ�������λ
  //  ��ʼ�������ݡ�
  //
  // ---------------------------------------------------------------------------
  wire  [15:0]  hc_data_inv = {
                          hc_data[0],
                          hc_data[1],
                          hc_data[2],
                          hc_data[3],
                          hc_data[4],
                          hc_data[5],
                          hc_data[6],
                          hc_data[7],
                          hc_data[8],
                          hc_data[9],
                          hc_data[10],
                          hc_data[11],
                          hc_data[12],
                          hc_data[13],
                          hc_data[14],
                          hc_data[15]
                          };

  reg [15:0]  clk_cnt;
  always @ ( posedge clk or negedge rst_n )
    if ( !rst_n ) clk_cnt <= 16'd0;
    else  clk_cnt <= clk_cnt + 1'b1;
      
  // ---------------------------------------------------------------------------
  // 
  //  ���ݹ�4λ������������������������ÿλ��ֵ��λ�룬�Լ�ÿλ��С���������
  //  ��Ϣ��ÿһλ��ֵ��ͨ��hex2ledģ��任�������λ�롣
  //
  // ---------------------------------------------------------------------------
  reg [2:0] seg_led_num;
  always @ ( posedge clk or negedge rst_n )
    if (!rst_n ) seg_led_num <= 3'b000;
    else if ( clk_cnt == 16'hFFFF ) seg_led_num <= seg_led_num + 1'b1;

  reg   [3:0] hex;
  always @ ( * )
    case ( seg_led_num )
      3'b000: hex = seg_value[31:28];
      3'b001: hex = seg_value[27:24];
      3'b010: hex = seg_value[23:20];
      3'b011: hex = seg_value[19:16];
      3'b100: hex = seg_value[15:12];
      3'b101: hex = seg_value[11:8];
      3'b110: hex = seg_value[7:4];
      3'b111: hex = seg_value[3:0];
    endcase 
  
  // ---------------------------------------------------------------------------
  // hex-to-seven-segment decoder
  //
  // segment encoding
  //      0
  //      ---  
  //  5  |   | 1
  //      ---   <- 6
  //  4  |   | 2
  //      --- .  7
  //       3 
  //  Q[7:0] = p7 - p0 
  // ---------------------------------------------------------------------------
  always @ ( * )
    begin
      case (hex)                        //��ֵ 
	      4'h1  : hex2led = 7'b1111_001;	//1          
	      4'h2  : hex2led = 7'b0100_100;	//2   
	      4'h3  : hex2led = 7'b0110_000;	//3   
	      4'h4  : hex2led = 7'b0011_001;	//4   
	      4'h5  : hex2led = 7'b0010_010;	//5   
	      4'h6  : hex2led = 7'b0000_010;	//6   
	      4'h7  : hex2led = 7'b1111_000;	//7   
	      4'h8  : hex2led = 7'b0000_000;	//8   
	      4'h9  : hex2led = 7'b0011_000;	//9   
	      4'hA  : hex2led = 7'b0001_000;	//A   
	      4'hB  : hex2led = 7'b0000_011;	//b   
	      4'hC  : hex2led = 7'b1000_110;	//C   
	      4'hD  : hex2led = 7'b0100_001;	//d   
	      4'hE  : hex2led = 7'b0000_110;	//E   
	      4'hF  : hex2led = 7'b0001_110;	//F   
	    default : hex2led = 7'b1000_000;	//0   
    endcase
  end
 
  always @ ( * )
    case ( seg_led_num )
      3'b000:hc_data_H8bit[7:0] = 8'b10000000;
      3'b001:hc_data_H8bit[7:0] = 8'b01000000;
      3'b010:hc_data_H8bit[7:0] = 8'b00100000;
      3'b011:hc_data_H8bit[7:0] = 8'b00010000;
      3'b100:hc_data_H8bit[7:0] = 8'b00001000;
      3'b101:hc_data_H8bit[7:0] = 8'b00000100;
      3'b110:hc_data_H8bit[7:0] = 8'b00000010;
      3'b111:hc_data_H8bit[7:0] = 8'b00000001;
    endcase  

  always @ ( * )
    case ( seg_led_num )
      3'b000:hc_data_Dpbit = dot[7];
      3'b001:hc_data_Dpbit = dot[6];
      3'b010:hc_data_Dpbit = dot[5];
      3'b011:hc_data_Dpbit = dot[4];
      3'b100:hc_data_Dpbit = dot[3];
      3'b101:hc_data_Dpbit = dot[2];
      3'b110:hc_data_Dpbit = dot[1];
      3'b111:hc_data_Dpbit = dot[0];
    endcase  
  
  // ---------------------------------------------------------------------------
  // 
  // HC164 �� hc_si �Լ�hc_cp�źŵĲ�����ͨ��һ��6λ�ļ�����������.hc_si���ź�
  // hc_data_inv�����λ��ʼ���ͣ�ԭ��ͼ����Ҫ�����λ���ͣ�����ڴ�֮ǰ��Ҫ����
  // ���ź�ȡ����
  //
  // ---------------------------------------------------------------------------  
  always @ ( posedge clk or negedge rst_n )
    if (!rst_n ) tx_cnt <= 6'd0;
    else if ( clk_cnt[15] ) tx_cnt <= 6'd0;      
    else if ((!clk_cnt[15]) && (tx_cnt <= 6'd32 )) tx_cnt <= tx_cnt + 1'b1;

  always @ ( posedge clk or negedge rst_n )
    if (!rst_n)  hc_cp <= 1'b0;
    else if ( clk_cnt[15] ) hc_cp <= 1'b0;
    else if ((!clk_cnt[15]) && (tx_cnt < 6'd32 )) hc_cp <= !hc_cp;

  assign  hc_si = hc_data_inv[tx_cnt[4:1]];
    
endmodule