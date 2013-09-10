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
module LCD_Driver(
  input              clk,               // 50MHzʱ��
  input              rst_n,             // ��λ�ź�
  // LCD1602 Interface
  output reg [  7:0] lcd_data,          // ��������
  output             lcd_e,             // ʹ���ź�
  output reg         lcd_rs,            // ָ�����ѡ��
  output             lcd_rw             // ����дѡ��
);  

// +++++++++++++++++++++++++++++++++++++
// ��Ƶģ�� ��ʼ
// +++++++++++++++++++++++++++++++++++++
reg [15:0] cnt;                         // ������

always @ (posedge clk, negedge rst_n)
  if (!rst_n) 
    cnt <= 0;
  else
    cnt <= cnt + 1'b1;

// 500Khz ~ 1MHz �Կ�
wire lcd_clk = cnt[15];       // (2^16 / 50M) = 1.31ms                                   
// -------------------------------------
// ��Ƶģ�� ����
// -------------------------------------


// +++++++++++++++++++++++++++++++++++++
// LCD1602����ģ�� ��ʼ
// +++++++++++++++++++++++++++++++++++++
// ��������룺��40��״̬
parameter IDLE         = 8'h00;
// дָ���ʼ��
parameter DISP_SET     = 8'h01;         // ��ʾģʽ����
parameter DISP_OFF     = 8'h03;         // ��ʾ�ر�
parameter CLR_SCR      = 8'h02;         // ��ʾ����
parameter CURSOR_SET1  = 8'h06;         // ��ʾ����ƶ�����
parameter CURSOR_SET2  = 8'h07;         // ��ʾ�����������
// ��ʾ��һ��
parameter ROW1_ADDR    = 8'h05;         // д��1����ʼ��ַ
parameter ROW1_0       = 8'h04;
parameter ROW1_1       = 8'h0C;
parameter ROW1_2       = 8'h0D;
parameter ROW1_3       = 8'h0F;
parameter ROW1_4       = 8'h0E;
parameter ROW1_5       = 8'h0A;
parameter ROW1_6       = 8'h0B;
parameter ROW1_7       = 8'h09;
parameter ROW1_8       = 8'h08;
parameter ROW1_9       = 8'h18;
parameter ROW1_A       = 8'h19;
parameter ROW1_B       = 8'h1B;
parameter ROW1_C       = 8'h1A;
parameter ROW1_D       = 8'h1E;
parameter ROW1_E       = 8'h1F;
parameter ROW1_F       = 8'h1D;
// ��ʾ�ڶ���
parameter ROW2_ADDR    = 8'h1C;         // д��2����ʼ��ַ
parameter ROW2_0       = 8'h14;
parameter ROW2_1       = 8'h15;
parameter ROW2_2       = 8'h17;
parameter ROW2_3       = 8'h16;
parameter ROW2_4       = 8'h12;
parameter ROW2_5       = 8'h13;
parameter ROW2_6       = 8'h11;
parameter ROW2_7       = 8'h10;
parameter ROW2_8       = 8'h30;
parameter ROW2_9       = 8'h31;
parameter ROW2_A       = 8'h33;
parameter ROW2_B       = 8'h32;
parameter ROW2_C       = 8'h36;
parameter ROW2_D       = 8'h37;
parameter ROW2_E       = 8'h35;
parameter ROW2_F       = 8'h34;

reg [5:0] current_state, next_state;    // ��̬����̬

// FSM: always1
always @ (posedge lcd_clk, negedge rst_n)
  if(!rst_n)  current_state <= IDLE;
  else        current_state <= next_state;

// FSM: always2
always
begin
  case(current_state)
    IDLE        : next_state = DISP_SET;
    // дָ���ʼ��
    DISP_SET    : next_state = DISP_OFF;
    DISP_OFF    : next_state = CLR_SCR;
    CLR_SCR     : next_state = CURSOR_SET1;
    CURSOR_SET1 : next_state = CURSOR_SET2;
    CURSOR_SET2 : next_state = ROW1_ADDR;
    // ��ʾ��һ��
    ROW1_ADDR   : next_state = ROW1_0;
    ROW1_0      : next_state = ROW1_1;
    ROW1_1      : next_state = ROW1_2;
    ROW1_2      : next_state = ROW1_3;
    ROW1_3      : next_state = ROW1_4;
    ROW1_4      : next_state = ROW1_5;
    ROW1_5      : next_state = ROW1_6;
    ROW1_6      : next_state = ROW1_7;
    ROW1_7      : next_state = ROW1_8;
    ROW1_8      : next_state = ROW1_9;
    ROW1_9      : next_state = ROW1_A;
    ROW1_A      : next_state = ROW1_B;
    ROW1_B      : next_state = ROW1_C;
    ROW1_C      : next_state = ROW1_D;
    ROW1_D      : next_state = ROW1_E;
    ROW1_E      : next_state = ROW1_F;
    ROW1_F      : next_state = ROW2_ADDR;
    // ��ʾ�ڶ���
    ROW2_ADDR   : next_state = ROW2_0; 
    ROW2_0      : next_state = ROW2_1;
    ROW2_1      : next_state = ROW2_2;
    ROW2_2      : next_state = ROW2_3;
    ROW2_3      : next_state = ROW2_4;
    ROW2_4      : next_state = ROW2_5;
    ROW2_5      : next_state = ROW2_6;
    ROW2_6      : next_state = ROW2_7;
    ROW2_7      : next_state = ROW2_8;
    ROW2_8      : next_state = ROW2_9;
    ROW2_9      : next_state = ROW2_A;
    ROW2_A      : next_state = ROW2_B;
    ROW2_B      : next_state = ROW2_C;
    ROW2_C      : next_state = ROW2_D;
    ROW2_D      : next_state = ROW2_E;
    ROW2_E      : next_state = ROW2_F;
    ROW2_F      : next_state = ROW1_ADDR;
    //
    default     : next_state = IDLE ;
  endcase
end

// FSM: always3
always @ (posedge lcd_clk, negedge rst_n)
begin
  if(!rst_n)
  begin 
    lcd_rs   <= 0; 
    lcd_data <= 8'hxx; 
  end
  else
  begin 
    // дlcd_rs
    case(next_state)      
      IDLE        : lcd_rs <= 0;
      // дָ���ʼ��
      DISP_SET    : lcd_rs <= 0;
      DISP_OFF    : lcd_rs <= 0;
      CLR_SCR     : lcd_rs <= 0;
      CURSOR_SET1 : lcd_rs <= 0;
      CURSOR_SET2 : lcd_rs <= 0;
      // д���ݣ���ʾ��һ��
      ROW1_ADDR   : lcd_rs <= 0;
      ROW1_0      : lcd_rs <= 1;
      ROW1_1      : lcd_rs <= 1;
      ROW1_2      : lcd_rs <= 1;
      ROW1_3      : lcd_rs <= 1;
      ROW1_4      : lcd_rs <= 1;
      ROW1_5      : lcd_rs <= 1;
      ROW1_6      : lcd_rs <= 1;
      ROW1_7      : lcd_rs <= 1;
      ROW1_8      : lcd_rs <= 1;
      ROW1_9      : lcd_rs <= 1;
      ROW1_A      : lcd_rs <= 1;
      ROW1_B      : lcd_rs <= 1;
      ROW1_C      : lcd_rs <= 1;
      ROW1_D      : lcd_rs <= 1; 
      ROW1_E      : lcd_rs <= 1;
      ROW1_F      : lcd_rs <= 1;
      // д���ݣ���ʾ�ڶ���
      ROW2_ADDR   : lcd_rs <= 0;
      ROW2_0      : lcd_rs <= 1;
      ROW2_1      : lcd_rs <= 1;
      ROW2_2      : lcd_rs <= 1;
      ROW2_3      : lcd_rs <= 1;
      ROW2_4      : lcd_rs <= 1;
      ROW2_5      : lcd_rs <= 1;
      ROW2_6      : lcd_rs <= 1;
      ROW2_7      : lcd_rs <= 1;
      ROW2_8      : lcd_rs <= 1;
      ROW2_9      : lcd_rs <= 1;
      ROW2_A      : lcd_rs <= 1;
      ROW2_B      : lcd_rs <= 1;
      ROW2_C      : lcd_rs <= 1;
      ROW2_D      : lcd_rs <= 1; 
      ROW2_E      : lcd_rs <= 1;
      ROW2_F      : lcd_rs <= 1;
    endcase    
    
    // дlcd_data
    case(next_state)
      IDLE        : lcd_data <= 8'hxx;
      // дָ���ʼ��
      DISP_SET    : lcd_data <= 8'h38;
      DISP_OFF    : lcd_data <= 8'h08;
      CLR_SCR     : lcd_data <= 8'h01;
      CURSOR_SET1 : lcd_data <= 8'h06;
      CURSOR_SET2 : lcd_data <= 8'h0C;
      // д���ݣ���ʾ��һ��
      ROW1_ADDR   : lcd_data <= 8'h80;
      ROW1_0      : lcd_data <= "H";
      ROW1_1      : lcd_data <= "e";
      ROW1_2      : lcd_data <= "l";
      ROW1_3      : lcd_data <= "l";
      ROW1_4      : lcd_data <= "o";
      ROW1_5      : lcd_data <= " ";
      ROW1_6      : lcd_data <= "F";
      ROW1_7      : lcd_data <= "P";
      ROW1_8      : lcd_data <= "G";
      ROW1_9      : lcd_data <= "A";
      ROW1_A      : lcd_data <= " ";
      ROW1_B      : lcd_data <= "W";
      ROW1_C      : lcd_data <= "o";
      ROW1_D      : lcd_data <= "r"; 
      ROW1_E      : lcd_data <= "l";
      ROW1_F      : lcd_data <= "d";
      // д���ݣ���ʾ�ڶ���
      ROW2_ADDR   : lcd_data <= 8'hC0;
      ROW2_0      : lcd_data <= "Y";
      ROW2_1      : lcd_data <= "o";
      ROW2_2      : lcd_data <= "u";
      ROW2_3      : lcd_data <= "Z";
      ROW2_4      : lcd_data <= "h";
      ROW2_5      : lcd_data <= "i";
      ROW2_6      : lcd_data <= "y";
      ROW2_7      : lcd_data <= "u";
      ROW2_8      : lcd_data <= " ";
      ROW2_9      : lcd_data <= "1";
      ROW2_A      : lcd_data <= "1";
      ROW2_B      : lcd_data <= ".";
      ROW2_C      : lcd_data <= "9";
      ROW2_D      : lcd_data <= ".";
      ROW2_E      : lcd_data <= "1";
      ROW2_F      : lcd_data <= "0";
    endcase  
  end
end

assign lcd_e  = lcd_clk;       // ������ʱ�Ӹߵ�ƽ������                 
assign lcd_rw = 1'b0;          // ֻд
// -------------------------------------
// LCD1602����ģ�� ����
// -------------------------------------

endmodule
