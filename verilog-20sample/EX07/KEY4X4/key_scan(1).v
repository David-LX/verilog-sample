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
module key_scan(
  input            clk,
  input            rst_n,
  input      [3:0] row,            // ������� ��
  output reg [3:0] col,            // ������� ��
  output reg [7:0] key_val         // ����ֵ     
);

//++++++++++++++++++++++++++++++++++++++
// ��Ƶ���� ��ʼ
//++++++++++++++++++++++++++++++++++++++
reg [19:0] cnt;                         // ������

always @ (posedge clk, negedge rst_n)
  if (!rst_n)
    cnt <= 0;
  else
    cnt <= cnt + 1'b1;

wire key_clk = cnt[19];                // (2^20/50M = 21)ms 
//--------------------------------------
// ��Ƶ���� ����
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// ״̬������ ��ʼ
//++++++++++++++++++++++++++++++++++++++
// ״̬�����٣����������
parameter NO_KEY_PRESSED = 6'b000_001;  // û�а�������  
parameter SCAN_COL0      = 6'b000_010;  // ɨ���0�� 
parameter SCAN_COL1      = 6'b000_100;  // ɨ���1�� 
parameter SCAN_COL2      = 6'b001_000;  // ɨ���2�� 
parameter SCAN_COL3      = 6'b010_000;  // ɨ���3�� 
parameter KEY_PRESSED    = 6'b100_000;  // �а�������

reg [5:0] current_state, next_state;    // ��̬����̬

always @ (posedge key_clk, negedge rst_n)
  if (!rst_n)
    current_state <= NO_KEY_PRESSED;
  else
    current_state <= next_state;

// ��������ת��״̬
always @ *
  case (current_state)
    NO_KEY_PRESSED :                    // û�а�������
        if (row != 4'hF)
          next_state = SCAN_COL0;
        else
          next_state = NO_KEY_PRESSED;
    SCAN_COL0 :                         // ɨ���0�� 
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL1;
    SCAN_COL1 :                         // ɨ���1�� 
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL2;    
    SCAN_COL2 :                         // ɨ���2��
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL3;
    SCAN_COL3 :                         // ɨ���3��
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;
    KEY_PRESSED :                       // �а�������
        if (row != 4'hF)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;                      
  endcase

reg       key_pressed_flag;             // ���̰��±�־
reg [3:0] col_val, row_val;             // ��ֵ����ֵ

// ���ݴ�̬������Ӧ�Ĵ�����ֵ
always @ (posedge key_clk, negedge rst_n)
  if (!rst_n)
  begin
    col              <= 4'h0;
    key_pressed_flag <=    0;
  end
  else
    case (next_state)
      NO_KEY_PRESSED :                  // û�а�������
      begin
        col              <= 4'h0;
        key_pressed_flag <=    0;       // ����̰��±�־
      end
      SCAN_COL0 :                       // ɨ���0��
        col <= 4'b1110;
      SCAN_COL1 :                       // ɨ���1��
        col <= 4'b1101;
      SCAN_COL2 :                       // ɨ���2��
        col <= 4'b1011;
      SCAN_COL3 :                       // ɨ���3��
        col <= 4'b0111;
      KEY_PRESSED :                     // �а�������
      begin
        col_val          <= col;        // ������ֵ
        row_val          <= row;        // ������ֵ
        key_pressed_flag <= 1;          // �ü��̰��±�־  
      end
    endcase
//--------------------------------------
// ״̬������ ����
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// ɨ������ֵ���� ��ʼ
//++++++++++++++++++++++++++++++++++++++
always @ (posedge key_clk, negedge rst_n)
  if (!rst_n)
    key_val <= 4'h0;
  else
    if (key_pressed_flag)
      case ({col_val, row_val})
        8'b1110_1110 : key_val <= 8'h01;
        8'b1110_1101 : key_val <= 8'h02;
        8'b1110_1011 : key_val <= 8'h03;
        8'b1110_0111 : key_val <= 8'h04;
        
        8'b1101_1110 : key_val <= 8'h05;
        8'b1101_1101 : key_val <= 8'h06;
        8'b1101_1011 : key_val <= 8'h07;
        8'b1101_0111 : key_val <= 8'h08;
        
        8'b1011_1110 : key_val <= 8'h09;
        8'b1011_1101 : key_val <= 8'h10;
        8'b1011_1011 : key_val <= 8'h11;
        8'b1011_0111 : key_val <= 8'h12;
        
        8'b0111_1110 : key_val <= 8'h13; 
        8'b0111_1101 : key_val <= 8'h14;
        8'b0111_1011 : key_val <= 8'h15;
        8'b0111_0111 : key_val <= 8'h16; 
         default: key_val=8'h00;
       
      endcase   

endmodule