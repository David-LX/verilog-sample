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
module mat_keyscan(clk,rst_n,col,val,seg_data); //�ӿ�����
input clk,rst_n;
input [3:0] val; //4��
output reg [3:0] col; //4��
output reg [7:0] seg_data; //��������¼��ı��
wire [7:0] data;
assign data= key_data; //
parameter clk_20ms_par = 1000000; //��ʱ20ms����Ҫ�ļ�������
reg clk_20ms; //����Ϊ20ms�ĸ�����
reg [19:0] clk_20ms_r; //���ڼ����ļĴ���

//���ڲ���һ������Ϊ20ms�ĸ�����clk_20ms
always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
	begin
		clk_20ms_r <= 20'b0;
	end
	else
	begin
		if(clk_20ms_r == clk_20ms_par)
		begin
			clk_20ms_r <= 20'b0;
			clk_20ms <= 1'b1;
		end
		else
		begin
			clk_20ms_r <= clk_20ms_r+1'b1;
			clk_20ms <= 1'b0;
		end
	end
end

wire [7:0] colval;
assign colval = {col[3:0],val[3:0]}; //����ֵ����ֵ���

parameter coln = 5'b00_001,
col0 = 5'b00_010,
col1 = 5'b00_100,
col2 = 5'b01_000,
col3 = 5'b10_000;
reg [4:0] state;
reg [7:0] key_data_buf,key_data;
reg [1:0] delay;

always@(posedge clk,negedge rst_n)
begin
if(!rst_n) //��λʱ�ԼĴ��������ֵ
begin
	delay <= 2'b0;
	col <= 4'hf;
	state <= coln;
end
else
begin
	case(state)
	coln:
   	state <= col0;
	col0: //col1��col2�������ͬ����ȥ
		begin
			delay <= 2'b0;
			col <= 4'b1110; //��һ������͵�ƽ������ȫ�����Ϊ�ߵ�ƽ
			key_data_buf <= colval; //�Ĵ��ֵ
			if(clk_20ms)
				delay <= delay+1'b1;
			if(delay == 2'b01) //����20ms����������������ʱ������if���
			begin
				if(key_data_buf == colval) //��֮ǰ��ֵ��ͬ���򽫵�ǰ��ֵ���棬ͬʱ״̬ת��
				begin
					key_data <= key_data_buf; //���õ���ֵ����key_data
					state <= col1;
				end
				else
				begin
					state <= coln; //���ص���ʼ״̬
				end
			end
		end
	col1:
		begin
			delay <= 2'b0;
			col <= 4'b1101; //�ڶ�������͵�ƽ������ȫ�����Ϊ�ߵ�ƽ
			key_data_buf <= colval;
			if(clk_20ms)
				delay <= delay+1'b1;
			if(delay == 2'b01)
			begin
				if(key_data_buf == colval)
				begin
					key_data <= key_data_buf;
					state <= col2;
				end
				else
				begin
					state <= coln;
				end
			end
		end
	col2:
		begin
			delay <= 2'b0;
			col <= 4'b1011;
			key_data_buf <= colval;
			if(clk_20ms)
				delay <= delay+1'b1;
			if(delay == 2'b01)
			begin
				if(key_data_buf == colval)
				begin
					key_data <= key_data_buf;
					state <= col3;
				end
				else
				begin
					state <= coln;
				end
			end
		end
	col3:
		begin
			delay <= 2'b0;
			col <= 4'b0111;
			key_data_buf <= colval;
			if(clk_20ms)
				delay <= delay+1'b1;
			if(delay == 2'b01)
			begin
				if(key_data_buf == colval)
				begin
					key_data <= key_data_buf;
					state <= col0;
				end
				else
				begin
					state <= coln;
				end
			end
		end
	default: state <= coln; //ȱʡֵ���ڣ���ֹ�����ܷɡ�
	endcase
	end
end
/*
parameter dis_0 = 8'h03, //��ʾ 0 
dis_1 = 8'h01, // 1
dis_2 = 8'h25, // 2
dis_3 = 8'h0d, // 3
dis_4 = 8'h99, // 4
dis_5 = 8'h49, // 5
dis_6 = 8'h41, // 6
dis_7 = 8'h1f, // 7
dis_8 = 8'h01, // 8
dis_9 = 8'h09, // 9
dis_a = 8'h11, // a
dis_b = 8'hc1, // b
dis_c = 8'h63, // c
dis_d = 8'h85, // d
dis_e = 8'h61, // e
dis_f = 8'h71, // f
dis_k = 8'hff,//light all off
dis_l = 8'h00;//light all on
*/

parameter dis_0 = 8'h00, //��ʾ 0 
			dis_1 = 8'h01, // 1
			dis_2 = 8'h02, // 2
			dis_3 = 8'h03, // 3
			dis_4 = 8'h04, // 4
			dis_5 = 8'h05, // 5
			dis_6 = 8'h06, // 6
			dis_7 = 8'h07, // 7
			dis_8 = 8'h08, // 8
			dis_9 = 8'h09, // 9
			dis_a = 8'h10, 
			dis_b = 8'h11, 
			dis_c = 8'h12, 
			dis_d = 8'h13, 
			dis_e = 8'h14, 
			dis_f = 8'h15, 
			dis_k = 8'h16;

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
	begin
		seg_data <= dis_0;
	end
	else
	begin
		case(data)
			8'b1110_1110: seg_data <= dis_1; //ɨ�赽��һ�е�һ��
			8'b1110_1101: seg_data <= dis_2; //ɨ�赽��һ�еڶ���
			8'b1110_1011: seg_data <= dis_3; //����
			8'b1110_0111: seg_data <= dis_4;
			
			8'b1101_1110: seg_data <= dis_5;
			8'b1101_1101: seg_data <= dis_6;
			8'b1101_1011: seg_data <= dis_7;
			8'b1101_0111: seg_data <= dis_8;
			
			8'b1011_1110: seg_data <= dis_9;
			8'b1011_1101: seg_data <= dis_a;
			8'b1011_1011: seg_data <= dis_b;
			8'b1011_0111: seg_data <= dis_c;
			
			8'b0111_1110: seg_data <= dis_d;
			8'b0111_1101: seg_data <= dis_e;
			8'b0111_1011: seg_data <= dis_f;
			8'b0111_0111: seg_data <= dis_k;
			default: ;
		endcase
	end
end

endmodule