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

`timescale 1ns / 1ps
module RTC_TOP(
			clk,
			rst_n,
			RTC_SCL,
			RTC_SDA,
			HC_CP,
			HC_SI,
		);
		
input clk;		// 50MHz
input rst_n;	//��λ�źţ�����Ч

output RTC_SCL;		// PCF8563��ʱ�Ӷ˿�
inout  RTC_SDA;		// PCF8563�����ݶ˿�

output HC_CP;       //7�����������
output HC_SI;       //7�����������

// ---------------------------------------------------------------------------
// ����PCF8563T I2C ����������
// ---------------------------------------------------------------------------
i2c_drive i2c_drive(
			.clk(clk),
			.rst_n(rst_n),
			.wr_n(1'b1),
			.rd_n(1'b0),
			.scl(RTC_SCL),
			.sda(RTC_SDA),
			.write_data(write_data),
			.addr(addr),
			.read_data(read_data),
			.idle_state(idle_state)
		);
// ---------------------------------------------------------------------------
// ����hc164����������
// ---------------------------------------------------------------------------
  hc164_driver hc164_driver_inst(
      .clk         ( clk ),
      .rst_n       (rst_n),
      .dot         ( 8'b1010_1011 ),
      .seg_value   ( {day,hur,min,sec}),
      .hc_cp       ( HC_CP ), 
      .hc_si       ( HC_SI )  
      );

/******************************************************************************************/
reg[7:0]  write_data;	
wire[7:0] read_data;
reg [7:0] addr;
wire      idle_state;	
//reg[7:0]  seg_dot;

reg [7:0]sec;
reg [7:0]min;
reg [7:0]hur;
reg [7:0]day;

reg [1:0]code_ctl;
parameter SEC_TIME = 2'd0;
parameter MNT_TIME = 2'd1;
parameter HUR_TIME = 2'd2;
parameter DAY_TIME = 2'd3;


always @(posedge idle_state or negedge rst_n)
if(!rst_n)
	begin 
	addr<=8'h05;
	sec<=8'd0;
	hur<=8'd0;
	min<=8'd0;
	day<=8'd0;
	
	code_ctl<=SEC_TIME;
	end
else
	begin
    case(code_ctl)
      SEC_TIME:
		begin
			
				addr<=8'h02; //������Ĵ����ĵ�ַ
				day<={2'b0,read_data[5:0]};
				code_ctl<=MNT_TIME; //�ȴ�������Ĵ����ĵ�ַ
		end
	  MNT_TIME:
        begin

				addr<=8'h03; //���ͷּĴ����ĵ�ַ
				sec<={1'b0,read_data[6:0]};

				code_ctl<=HUR_TIME;//�ȴ����ͷּĴ����ĵ�ַ
			end
	  HUR_TIME:
		begin

				addr<=8'h04; //����Сʱ�Ĵ����ĵ�ַ
				min<={1'b0,read_data[6:0]};

				code_ctl<=DAY_TIME; //�ȴ�����Сʱ�Ĵ����ĵ�ַ
		end
	   DAY_TIME:
		begin

				addr<=8'h05; //����Сʱ�Ĵ����ĵ�ַ
				hur<={2'b0,read_data[5:0]};

				code_ctl<=SEC_TIME; //�ȴ�����Сʱ�Ĵ����ĵ�ַ
		end
    endcase
	end

endmodule		
