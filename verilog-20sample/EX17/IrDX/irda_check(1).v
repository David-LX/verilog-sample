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

module irda_check (clk, rst_n, irda, irda_data);
  input   clk;//50MHz clock
  input   rst_n;//��λ�źţ��͵�ƽ��Ч
  input   irda;   //������չܽ�
  output  irda_data;//�������ݵ����
  
  reg [15:0] irda_data;    // save irda data,than send to 7 segment led
  reg [31:0] get_data;     // use for saving 32 bytes irda data
  reg [5:0]  data_cnt;     // 32 bytes irda data counter
  reg [2:0]  cs,ns;
  reg error_flag;          // 32 bytes data�ڼ䣬���ݴ����־

  parameter   IDLE       = 3'b000,
              LEADER_9   = 3'b001,
              LEADER_4   = 3'b010,
              DATA_STATE = 3'b100;

  //----------------------------------------------------------------------------
  reg irda_reg0;       //Ϊ�˱�������̬,������������Ĵ�������һ����ʹ�á�
  reg irda_reg1;       //����ſ���ʹ�ã����³����д���irda��״̬
  reg irda_reg2; //Ϊ��ȷ��irda�ı��أ��ٴ�һ�μĴ��������³����д���irda��ǰһ״̬
  wire irda_neg_pulse; //ȷ��irda���½���
  wire irda_pos_pulse; //ȷ��irda��������
  wire irda_chang;     //ȷ��irda��������
    
  always @ (posedge clk) //�ڴ˲��ø���Ĵ���
    if(!rst_n)
      begin
        irda_reg0 <= 1'b0;
        irda_reg1 <= 1'b0;
        irda_reg2 <= 1'b0;
      end
    else
      begin
        irda_reg0 <= irda;
        irda_reg1 <= irda_reg0;
        irda_reg2 <= irda_reg1;
      end 
      
  assign irda_chang = irda_neg_pulse | irda_pos_pulse;
  assign irda_neg_pulse = irda_reg2 & (~irda_reg1);
  assign irda_pos_pulse = (~irda_reg2) & irda_reg1;

  //----------------------------------------------------------------------------
  //��Ʒ�Ƶ�ͼ������֣���PT2222�Ĺ淶�����Ƿ�����С�ĵ�ƽ����ʱ����0.56ms����
  //�����ڽ��в���ʱ��һ�㶼�����С�ĵ�ƽ����16�Ρ�Ҳ����˵Ҫ��0.56ms���ٲ���16
  //�Ρ�
  //              0.56ms/16=35us 
  //�ڿ��������Դ�����ƵΪ50MHz����ʱ������Ϊ20ns������������Ҫ�ķ�Ƶ����Ϊ��
  //              35000/20=1750
  //���������������������counter��һ��counter���ڼ�1750��ʱ����Ƶ��
  //һ��counter���ڼ����Ƶ֮��ͬһ�ֵ�ƽ��scan���ĵ���������������������ж�
  //��leader��9ms ����4.5ms���������ݵ� 0 ���� 1��
  //----------------------------------------------------------------------------
  reg [10:0] counter;  //��Ƶ1750��
  reg [8:0]  counter2; //������Ƶ��ĵ���
  wire check_9ms;  // check leader 9ms time
  wire check_4ms;  // check leader 4.5ms time
  wire low;        // check  data=0 time
  wire high;       // check  data=1 time
  
  always @ (posedge clk)
    if (!rst_n)
      counter <= 11'd0;
    else if (irda_chang)  //irda��ƽ�����ˣ������¿�ʼ����
      counter <= 11'd0;
    else if (counter == 11'd1750)
      counter <= 11'd0;
    else
      counter <= counter + 1'b1;
   
  always @ (posedge clk)
    if (!rst_n)
      counter2 <= 9'd0;
    else if (irda_chang)  //irda��ƽ�����ˣ������¿�ʼ�Ƶ�
      counter2 <= 9'd0;
    else if (counter == 11'd1750)
      counter2 <= counter2 +1'b1;

  assign check_9ms = ((217 < counter2) & (counter2 < 297)); //257
  assign check_4ms = ((88 < counter2) & (counter2 < 168));  //128
  assign low  = ((6 < counter2) & (counter2 < 26));         // 16
  assign high = ((38 < counter2) & (counter2 < 58));        // 48

  //----------------------------------------------------------------------------
  // generate statemachine
  always @ (posedge clk)
    if (!rst_n)
      cs <= IDLE;
    else 
      cs <= ns;
      
  always @ ( * )
    case (cs)
      IDLE: 
        if (~irda_reg1) 
          ns = LEADER_9;
        else
          ns = IDLE;
      LEADER_9:
        if (irda_pos_pulse)   //leader 9ms check
          begin
            if (check_9ms)
              ns = LEADER_4;
            else
              ns = IDLE;
          end
        else  //�걸��if---else--- ;��ֹ����latch
          ns =LEADER_9;
      LEADER_4:
        if (irda_neg_pulse)  // leader 4.5ms check
          begin
            if (check_4ms)
              ns = DATA_STATE;
            else
              ns = IDLE;
          end
        else
          ns = LEADER_4;
      DATA_STATE:
        if ((data_cnt == 6'd32) & irda_reg2 & irda_reg1)
          ns = IDLE;
        else if (error_flag)
          ns = IDLE;
        else
          ns = DATA_STATE;
      default:
        ns = IDLE;
    endcase

  //״̬���е����,��ʱ���·������
  always @ (posedge clk)
    if (!rst_n)
      begin
        data_cnt <= 6'd0;
        get_data <= 32'd0;
        error_flag <= 1'b0;
      end
    else if (cs == IDLE)
      begin
        data_cnt <= 6'd0;
        get_data <= 32'd0;
        error_flag <= 1'b0;
      end
    else if (cs == DATA_STATE)
      begin
        if (irda_pos_pulse)  // low 0.56ms check
          begin
            if (!low)  //error
              error_flag <= 1'b1;
          end
        else if (irda_neg_pulse)  //check 0.56ms/1.68ms data 0/1
          begin
            if (low)
              get_data[0] <= 1'b0;
            else if (high)
              get_data[0] <= 1'b1;
            else
              error_flag <= 1'b1;
              
            get_data[31:1] <= get_data[30:0];
            data_cnt <= data_cnt + 1'b1;
          end
      end

  always @ (posedge clk)
    if (!rst_n)
      irda_data <= 16'd0;
    else if ((data_cnt ==6'd32) & irda_reg1)
      irda_data <= get_data[15:0];
    
endmodule