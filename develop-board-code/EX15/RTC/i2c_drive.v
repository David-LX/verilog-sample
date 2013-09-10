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

module i2c_drive(
			clk,
			rst_n,
			wr_n,
			rd_n,
			scl,
			sda,
			write_data,
			addr,
			read_data,
			idle_state
		);

input  clk;		// 50MHz
input  rst_n;	//��λ�źţ�����Ч
input  wr_n;	//д�����źţ��͵�ƽ��Ч
input  rd_n;	//�������źţ��͵�ƽ��Ч
output scl;		// I2C��ʱ�Ӷ˿�
inout  sda;		// I2C�����ݶ˿�
input  [7:0] write_data; //д��ָ����Ԫ������
input  [7:0] addr;        //д��/�����ĵ�ַ
output [7:0] read_data;	 //����ָ����Ԫ������
output reg idle_state;       //i2c���߿���״̬���͵�ƽָʾ����
//--------------------------------------------
//��д�źż��
reg sw1_r,sw2_r;	//��д�ź�����Ĵ�����ÿ20ms���һ��
reg [19:0] cnt_20ms;//20ms�����Ĵ���
reg  clr_sw;        //��� ��д�ź�����Ĵ���ֵ  �ı�־

always @ (posedge clk or negedge rst_n)
	if(!rst_n) 
	   cnt_20ms <= 20'd0;
	else 
	   cnt_20ms <= cnt_20ms+1'b1;	//���ϼ���

always @ (posedge clk or negedge rst_n)
	if(!rst_n) 
		begin
			sw1_r <= 1'b1;	//��д�ź�����Ĵ�����λ
			sw2_r <= 1'b1;
		end
	else if(cnt_20ms == 20'h7ffff) 
		begin
			sw1_r <= wr_n;	//д�ź�ֵ����
			sw2_r <= rd_n;	//���ź�ֵ����
		end
	else if(clr_sw)
	    begin
            sw1_r<=1'b1;
            sw2_r<=1'b1;
        end
//---------------------------------------------
//��Ƶ����
reg[2:0] cnt;	    // cnt=0:scl�����أ�cnt=1:scl�ߵ�ƽ�м䣬cnt=2:scl�½��أ�cnt=3:scl�͵�ƽ�м�
reg[8:0] cnt_delay;	//500ѭ������������iic����Ҫ��ʱ��
reg scl_r;		    //ʱ������Ĵ���

always @ (posedge clk or negedge rst_n)
	if(!rst_n) 
	   cnt_delay <= 9'd0;
	else if(cnt_delay == 9'd499) 
	   cnt_delay <= 9'd0;	//������10usΪscl�����ڣ���100KHz
	else 
	   cnt_delay <= cnt_delay+1'b1;	//ʱ�Ӽ���

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) 
	   cnt <= 3'd5;
	else 
	  begin
		 case (cnt_delay)
			9'd124:	cnt <= 3'd1;	//cnt=1:scl�ߵ�ƽ�м�,�������ݲ���
			9'd249:	cnt <= 3'd2;	//cnt=2:scl�½���
			9'd374:	cnt <= 3'd3;	//cnt=3:scl�͵�ƽ�м�,�������ݱ仯
			9'd499:	cnt <= 3'd0;	//cnt=0:scl������
			default: cnt <= 3'd5;
		  endcase
	  end
end


`define SCL_POS		(cnt==3'd0)		//cnt=0:scl������
`define SCL_HIG		(cnt==3'd1)		//cnt=1:scl�ߵ�ƽ�м�,�������ݲ���
`define SCL_NEG		(cnt==3'd2)		//cnt=2:scl�½���
`define SCL_LOW		(cnt==3'd3)		//cnt=3:scl�͵�ƽ�м�,�������ݱ仯


always @ (posedge clk or negedge rst_n)
	if(!rst_n) 
	    scl_r <= 1'b0;
	else if(cnt==3'd0) 
	    scl_r <= 1'b1;	//scl�ź�������
   	else if(cnt==3'd2) 
        scl_r <= 1'b0;	//scl�ź��½���

assign scl = scl_r;	//����i2c����Ҫ��ʱ��
//---------------------------------------------

//PCF8563T�ĵ�ַ		
`define	DEVICE_READ		8'b1010_0011	//��Ѱַ������ַ����������
`define DEVICE_WRITE	8'b1010_0010	//��Ѱַ������ַ��д������
	
reg[7:0] db_r;		//��i2c�ϴ��͵����ݼĴ���


//---------------------------------------------
//����дʱ��
parameter 	IDLE 	= 4'd0;
parameter 	START1 	= 4'd1;
parameter 	ADD1 	= 4'd2;
parameter 	ACK1 	= 4'd3;
parameter 	ADD2 	= 4'd4;
parameter 	ACK2 	= 4'd5;
parameter 	START2 	= 4'd6;
parameter 	ADD3 	= 4'd7;
parameter 	ACK3	= 4'd8;
parameter 	DATA 	= 4'd9;
parameter 	ACK4	= 4'd10;
parameter 	STOP1 	= 4'd11;
parameter 	STOP2 	= 4'd12;
	

reg[3:0] cstate;//״̬�Ĵ���
reg sda_r;		//������ݼĴ���
reg sda_link;	//�������sda�ź�inout�������λ		
reg[3:0] num;	//

reg [7:0] tmp_data;

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) 
		begin
			cstate <= IDLE;
			sda_r <= 1'b1;
			sda_link <= 1'b0;
			num <= 4'd0;
			tmp_data <= 8'b0000_0000;
			idle_state<=1'b0;
			clr_sw<=1'b0;
		end
	else 	  
		case (cstate)
			IDLE:	
				begin
				    clr_sw<=1'b0;
					sda_link <= 1'b1;			//������sdaΪinput
					sda_r <= 1'b1;
					if(!sw1_r || !sw2_r) 
						begin//��д�ź���һ����Ч		
						  db_r <= `DEVICE_WRITE;	//��������ַ��д������
						  cstate <= START1;	
						  idle_state<=1'b1;
						 // clr_sw<=1'b0;
						end
					else 
					   begin
					      cstate <= IDLE;	//�κζ�д�ź���Ч
					   end
				end
			START1: 
				begin
					if(`SCL_HIG) 
					    begin//sclΪ�ߵ�ƽ�ڼ�
						  sda_link <= 1'b1;	//������sdaΪoutput
						  sda_r <= 1'b0;	//����������sda��������ʼλ�ź�
						  cstate <= ADD1;
						  num <= 4'd0;		//num��������
						end
					else 
					    cstate <= START1; //�ȴ�scl�ߵ�ƽ�м�λ�õ���
				end
			ADD1:	
				begin
					if(`SCL_LOW) 
						begin
							if(num == 4'd8) 
								begin	
									num <= 4'd0;			//num��������
									sda_r <= 1'b1;
									sda_link <= 1'b0;		//sda��Ϊ����̬(input)
									cstate <= ACK1;
								end
							else 
								begin
									cstate <= ADD1;
									num <= num+1'b1;
									case (num)
										4'd0: sda_r <= db_r[7];
										4'd1: sda_r <= db_r[6];
										4'd2: sda_r <= db_r[5];
										4'd3: sda_r <= db_r[4];
										4'd4: sda_r <= db_r[3];
										4'd5: sda_r <= db_r[2];
										4'd6: sda_r <= db_r[1];
										4'd7: sda_r <= db_r[0];
										default: ;
									endcase
								end
						end
					else 
					   cstate <= ADD1;
				end
			ACK1:	
				begin
					if(`SCL_NEG) 
						begin	//ע��24C01/02/04/08/16�������Բ�����Ӧ��λ
							cstate <= ADD2;	//�ӻ���Ӧ�ź�
						    db_r <= addr;	// 1��ַ		
						end
					else 
					   cstate <= ACK1;		//�ȴ��ӻ���Ӧ
				end
			ADD2:	
				begin
					if(`SCL_LOW) 
						begin
							if(num==4'd8) 
								begin	
									num <= 4'd0;			//num��������
									sda_r <= 1'b1;
									sda_link <= 1'b0;		//sda��Ϊ����̬(input)
									cstate <= ACK2;
								end
							else 
								begin
									sda_link <= 1'b1;		//sda��Ϊoutput
									num <= num+1'b1;
									case (num)
										4'd0: sda_r <= db_r[7];
										4'd1: sda_r <= db_r[6];
										4'd2: sda_r <= db_r[5];
										4'd3: sda_r <= db_r[4];
										4'd4: sda_r <= db_r[3];
										4'd5: sda_r <= db_r[2];
										4'd6: sda_r <= db_r[1];
										4'd7: sda_r <= db_r[0];
										default: ;
									endcase		
									cstate <= ADD2;					
								end
						end
					else 
					    cstate <= ADD2;				
				end
			ACK2:	begin
					if(`SCL_NEG) 
						begin		//�ӻ���Ӧ�ź�
						   if(!sw1_r) 
							  begin
								cstate <= DATA; 	//д����	
								db_r <= write_data;	//д�������						
							  end	
						   else if(!sw2_r) 
							  begin
								db_r <= `DEVICE_READ;	//��������ַ�������������ض���ַ����Ҫִ�иò������²���
								cstate <= START2;		//������
							  end
						end
					else 
					   cstate <= ACK2;	//�ȴ��ӻ���Ӧ
				end
			START2: begin	//��������ʼλ
					if(`SCL_LOW) 
						begin
						sda_link <= 1'b1;	//sda��Ϊoutput
						sda_r <= 1'b1;		//����������sda
						cstate <= START2;
						end
					else if(`SCL_HIG) 
						begin	//sclΪ�ߵ�ƽ�м�
						sda_r <= 1'b0;		//����������sda��������ʼλ�ź�
						cstate <= ADD3;
						end	 
					else 
					    cstate <= START2;
				end
			ADD3:	begin	//�Ͷ�������ַ
					if(`SCL_LOW) begin
							if(num==4'd8) 
								begin	
									num <= 4'd0;			//num��������
									sda_r <= 1'b1;
									sda_link <= 1'b0;		//sda��Ϊ����̬(input)
									cstate <= ACK3;
								end
							else begin
									num <= num+1'b1;
									case (num)
										4'd0: sda_r <= db_r[7];
										4'd1: sda_r <= db_r[6];
										4'd2: sda_r <= db_r[5];
										4'd3: sda_r <= db_r[4];
										4'd4: sda_r <= db_r[3];
										4'd5: sda_r <= db_r[2];
										4'd6: sda_r <= db_r[1];
										4'd7: sda_r <= db_r[0];
										default: ;
									endcase											
									cstate <= ADD3;					
								end
						end
					else cstate <= ADD3;				
				end
			ACK3:	begin
					if(/*!sda*/`SCL_NEG) 
						begin
							cstate <= DATA;	//�ӻ���Ӧ�ź�
							sda_link <= 1'b0;
						end
					else 
					   cstate <= ACK3; 		//�ȴ��ӻ���Ӧ
				end
			DATA:	begin
					if(!sw2_r) 
						begin	 //������
							if(num<=4'd7) 
								begin
								cstate <= DATA;
								if(`SCL_HIG) 
									begin	
									  num <= num+1'b1;	
									  case (num)
										4'd0: tmp_data[7] <= sda;
										4'd1: tmp_data[6] <= sda;  
										4'd2: tmp_data[5] <= sda; 
										4'd3: tmp_data[4] <= sda; 
										4'd4: tmp_data[3] <= sda; 
										4'd5: tmp_data[2] <= sda; 
										4'd6: tmp_data[1] <= sda; 
										4'd7: tmp_data[0] <= sda; 
										default: ;
									  endcase																		
									end
								end
							  else if((`SCL_LOW) && (num==4'd8)) 
								begin
								   num <= 4'd0;			//num��������
								   cstate <= ACK4;
								end
							  else 
							     cstate <= DATA;
						end
					else if(!sw1_r) begin	//д����
							sda_link <= 1'b1;	
							if(num<=4'd7) begin
								cstate <= DATA;
								if(`SCL_LOW) begin
									sda_link <= 1'b1;		//������sda��Ϊoutput
									num <= num+1'b1;
									case (num)
										4'd0: sda_r <= db_r[7];
										4'd1: sda_r <= db_r[6];
										4'd2: sda_r <= db_r[5];
										4'd3: sda_r <= db_r[4];
										4'd4: sda_r <= db_r[3];
										4'd5: sda_r <= db_r[2];
										4'd6: sda_r <= db_r[1];
										4'd7: sda_r <= db_r[0];
										default: ;
										endcase	
									end
							 	end
							else if((`SCL_LOW) && (num==4'd8)) begin
									num <= 4'd0;
									sda_r <= 1'b1;
									sda_link <= 1'b0;		//sda��Ϊ����̬
									cstate <= ACK4;
								end
							else cstate <= DATA;
						end
				end
			ACK4: begin
					if(/*!sda*/`SCL_NEG) begin
						cstate <= STOP1;	
						clr_sw<=1'b1;					
						end
					else cstate <= ACK4;
				end
			STOP1:	begin
					if(`SCL_LOW) begin
							sda_link <= 1'b1;
							sda_r <= 1'b0;
							cstate <= STOP1;
						end
					else if(`SCL_HIG) begin
							sda_r <= 1'b1;	//sclΪ��ʱ��sda���������أ������źţ�
							cstate <= STOP2;
						end
					else cstate <= STOP1;
				end
			STOP2:	begin
					if(`SCL_LOW) sda_r <= 1'b1;
					else if(cnt_20ms==20'h7fff0) 
					   begin
					     cstate <= IDLE;
					     idle_state<=1'b0;
					   end
					else 
					  cstate <= STOP2;
				end
			default: 
			   begin
				  cstate <= IDLE;
			   end
			endcase
end

assign sda = sda_link ? sda_r:1'bz;
assign read_data=idle_state?8'bzzzz_zzzz:tmp_data;	
//---------------------------------------------
endmodule


