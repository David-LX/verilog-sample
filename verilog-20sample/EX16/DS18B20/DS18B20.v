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


module DS18B20(nReset,ClkEnable,rd,clk,data,icdata);

input nReset,ClkEnable,rd,clk;//clk 1Mhz
output [7:0] data;
inout icdata;

reg [7:0] data;
reg icdata;
initial data = 8'bzzzzzzzz; 

parameter state_0 	= 0;
parameter state_1 	= 1;
parameter state_2 	= 2;
parameter state_3 	= 3;
parameter state_4 	= 4;
parameter state_5 	= 5;
parameter state_6 	= 6;
parameter state_7 	= 7;
parameter state_8 	= 8;
parameter state_9 	= 9;
parameter state_10 	= 10;
parameter state_11 	= 11;
parameter state_12 	= 12;
parameter state_13 	= 13;
parameter state_14 	= 14;
parameter state_15 	= 15;

always@(negedge clk or negedge nReset)
begin
	if(!nReset)
	begin
	end
	else if(ClkEnable)
	begin
		CmdSETDS18B20;		
	end		
end

reg [7:0] inter_bus_in;
always@(rd)
begin
 if(!rd)
	inter_bus_in <= Result;	
  else 
     inter_bus_in <= 8'bzzzzzzzz;

	data <= inter_bus_in;
end	

reg Flag_Rst;									//��λ��ɱ�־
reg [4:0] Rststate;								//��λ״̬	
reg [10:1] CountRstStep;						//��λ������ 1024
task Rst_DS18B20;
begin
	case(Rststate)
	state_0 : 									//out 1 ,keep 1us
	begin
		Flag_Rst <= 0;							//��λ������
		icdata <= 1;							//��������
		Rststate <= state_1;
		CountRstStep <= 0;
	end	
	state_1 : 
	begin
		icdata <= 0;							//��������
		if(CountRstStep > 600)					//����ʱ��600us
		begin
			CountRstStep <= 0;					//��������0
			Rststate <= state_2;				
		end	
		else	
		begin			
			CountRstStep <= CountRstStep + 1;	
			Rststate <= state_1;				//��ʱδ��
		end
	end	
	state_2 :									
	begin
		icdata <= 1;							//��������
		if(CountRstStep > 50)					//����ʱ��50us
		begin
			CountRstStep <= 0;					//��������0
			Rststate <= state_3;
		end
		else
		begin
			CountRstStep <= CountRstStep + 1;
			Rststate <= state_2;				//��ʱδ��
		end		
	end
	state_3	:
	begin
		icdata <= 1'bz;							//�ͷ�����
		Rststate <= state_4;
	end
	state_4 :
	begin
		Rststate <= state_5;
	end
	state_5 :
	begin
		if(icdata == 1)							//��ʼ�����
		begin
			CountRstStep <= 0;
			Rststate <= state_6;				//����			
		end
		else
		begin
			if(CountRstStep > 300)
			begin
				CountRstStep <= 0;
				Rststate <= state_0;
			end
			else
			begin
				CountRstStep <= CountRstStep + 1;
				Rststate <= state_5;
			end	
		end
	end
	state_6 :
	begin
		if(CountRstStep == 200)
		begin
			CountRstStep <= 0;
			Rststate <= state_7;		
		end
		else
		begin
			CountRstStep <= CountRstStep + 1;
			Rststate <= state_6;		
		end
	end	
	state_7 :
	begin
		Flag_Rst <= 1;							//��ʼ�����
		CountRstStep <= 0;
		Rststate <= state_0;					//�ص�ԭ��
	end
	default : 
	begin
		Rststate <= state_0;						 
		CountRstStep <= 0;
	end	
	endcase
end
endtask

reg[3:0] i;					//һ����8��λ�����һ���������������ж�

reg Flag_Write;							//д������ɱ�־��дλ
reg[4:0] Writestate;							//д����״̬
task Write_DS18B20;
input [7:0] dcmd;								//����
reg[7:0] indcmd;
reg wBit;
begin
	case(Writestate)
	state_0 :
	begin
		Flag_Write <= 0;						//д���������
		Writestate <= state_1;	
		indcmd <= dcmd;	
		i <= 0;		
	end
	state_1 :
	begin				
		if(i < 8)
		begin
//			wBit <= dcmd & 1;					//����ȡ1λ
			wBit_DS18B20(indcmd[0]);	
			if(Flag_wBit)						//д��1λ
			begin
				indcmd = indcmd >> 1;		//����1λ
				i <= i + 1;						//λ����1
			end
			Writestate <= state_1;				//�ظ���дλ
		end
		else 									//д��8λ
		begin
			Writestate <= state_2;				
			i <= 0;
		end	
	end
	state_2 :
	begin
		Flag_Write <= 1;						//д�������
		indcmd <= 0;
		Writestate <= state_0;
	end
	default :
	begin
		Flag_Write <= 0;
		Writestate <= state_0;
	end
	endcase
end
endtask	

reg Flag_wBit;									//дλ��ɱ�־
reg[4:0] WriteBitstate;							//дλ����
reg[8:1] CountWbitStep;							//дλ������
task wBit_DS18B20;
input wiBit;										//λ��Ϣ
begin
	case(WriteBitstate)
	state_0 :
	begin
		Flag_wBit <= 0;							//дλ������
		icdata <= 1;							//��������
		WriteBitstate <= state_1;
		CountWbitStep <= 0;
	end	
	state_1 :
	begin
		icdata <= 0;							//��������
		if(wiBit)WriteBitstate <= state_2;		//д1������
		else WriteBitstate <= state_4;			//д0������
	end	
	state_2 :
	begin
		if(CountWbitStep >= 3)					//ά�ֵ͵�ƽ3us
		begin
			CountWbitStep <= 0;
			icdata <= 1;						//���ߵ�ƽ
			WriteBitstate <= state_3;
		end
		else
		begin
			CountWbitStep <= CountWbitStep + 1;	//��������
			WriteBitstate <= state_2;
		end	
	end
	state_3 :
	begin
		if(CountWbitStep >= 60)					//ά�����ߵ�ƽ60us
		begin
			CountWbitStep <= 0;
			WriteBitstate <= state_6;
		end
		else
		begin
			CountWbitStep <= CountWbitStep + 1;	//��������
			WriteBitstate <= state_3;
		end	
	end	
	state_4 :
	begin
		if(CountWbitStep >= 60)					//ά�ֵ͵�ƽ60us
		begin
			CountWbitStep <= 0;
			WriteBitstate <= state_5;
		end
		else
		begin
			icdata <= 0;
			CountWbitStep <= CountWbitStep + 1;
			WriteBitstate <= state_4;
		end			
	end
	state_5 :
	begin
		if(CountWbitStep >= 3)					//��������3us
		begin
			CountWbitStep <= 0;
			WriteBitstate <= state_6;
		end
		else
		begin
			icdata <= 1;
			CountWbitStep <= CountWbitStep + 1;
			WriteBitstate <= state_5;
		end			
	end	
	state_6 :									
	begin
		Flag_wBit <= 1;							//дλ�������
		CountWbitStep <= 0;
		WriteBitstate <= state_0;
	end
	default :
	begin
		Flag_wBit <= 0;
		CountWbitStep <= 0;
		WriteBitstate <= state_0;	
	end	
	endcase
end
endtask

reg[3:0] j;
reg[7:0] ResultDS18B20;	//�����Ľ��
reg Flag_Read;									//�������־
reg [16:1] Readstate;							//������״̬
task Read_DS18B20;
begin
	case(Readstate)
	state_0 : 
	begin
		Flag_Read <= 0;							//�����������
		Readstate <= state_1;
		j <= 1;
	end
	state_1 :
	begin
		rBit_DS18B20;
		if(Flag_rBit)
		begin
			if(temp)ResultDS18B20 = ResultDS18B20 | 8'b1000_0000;
			if(j < 8)
			begin
				ResultDS18B20 = ResultDS18B20 >> 1;	
				j <= j  + 1;
				Readstate <= state_1;
			end	
			else
			begin
				Readstate <= state_2;				//����1��byte
				j <= 1;
			end			
		end
		else Readstate <= state_1;		
	end
	state_2 :	
	begin
		Flag_Read <= 1;							//���������
		Readstate <= state_0;
	end
	default :	
	begin
		Flag_Read <= 0;
		Readstate <= state_0;
	end
	endcase
end	
endtask			

reg Flag_rBit,temp;									//��λ�����־
reg[16:1] ReadBitstate;							//��λ����״̬
reg[6:1] CountRbitStep;							//��λ�����ʱ��
task rBit_DS18B20;
begin
	case(ReadBitstate)
	state_0 :
	begin
		Flag_rBit <= 0;							//��λ���������
		icdata <= 1;							//��������
		CountRbitStep <= 0;
		ReadBitstate <= state_1;
	end
	state_1 :
	begin
		if(CountRbitStep >= 3)					//���ֵ͵�ƽ3us
		begin
			icdata <= 1;						//�ٽ���������
			icdata <= 1'bz;						//��Ϊ����
			CountRbitStep <= 0;
			ReadBitstate <= state_2;
		end
		else
		begin
			icdata <= 0;						//��������
			CountRbitStep <= CountRbitStep + 1;
			ReadBitstate <= state_1;
		end		
	end
	state_2 :
	begin
		if(CountRbitStep >= 10)					//ά������״̬10us
		begin
			if(icdata)temp <= 1;				//���1
			else temp <= 0;						//���0
			CountRbitStep <= 0;
			ReadBitstate <= state_3;
		end
		else
		begin
			CountRbitStep <= CountRbitStep + 1;
			ReadBitstate <= state_2;			
		end
	end
	state_3 :
	begin
		if(CountRbitStep >= 60)					//ά��60us����
		begin
			CountRbitStep <= 0;
			ReadBitstate <= state_4;	
		end
		else
		begin
			CountRbitStep <= CountRbitStep + 1;
			ReadBitstate <= state_3;	
		end					
	end
	state_4 :
	begin
		Flag_rBit <= 1;							//��λ�������
		CountRbitStep <= 0;
		ReadBitstate <= state_0;	
	end
	default :
	begin
		Flag_rBit <= 0;
		CountRbitStep <= 0;
		ReadBitstate <= state_0;		
	end
	endcase
end	
endtask	

reg Flag_CmdSET;
reg [16:1] CmdSETstate;
reg [16:1] Count65535;
reg [4:1] Count12;
reg [7:0] Resultl,Resulth,Result;
task CmdSETDS18B20;
begin
	case(CmdSETstate)
	state_0 :
	begin
		Flag_CmdSET <= 0;
		Rst_DS18B20;
		if(!Flag_Rst)CmdSETstate <= state_0;
		else CmdSETstate <= state_1;	
	end
	state_1 :
	begin
//		Write_DS18B20(8'hcc);//
		Write_DS18B20(8'h44);
		if(!Flag_Write)CmdSETstate <= state_1;
		else CmdSETstate <= state_2;
	end
	state_2 :	
	begin
//		Write_DS18B20(8'h44);//
		Write_DS18B20(8'hcc);
		if(!Flag_Write)CmdSETstate <= state_2;
		else CmdSETstate <= state_3;
	end
	state_3 :
	begin
		if(Count65535 == 65535)
		begin
			Count65535 <= 0;
			CmdSETstate <= state_4;
		end
		else
		begin
			Count65535 <= Count65535 + 1;
			CmdSETstate <= state_3;
		end				
	end
	state_4 :
	begin
		if(Count12 == 12)
		begin
			Count12 <= 0;
			CmdSETstate <= state_5;
		end
		else
		begin
			Count12 <= Count12 + 1;
			CmdSETstate <= state_3;
		end				
	end		
	state_5 :
	begin
		Rst_DS18B20;
		if(!Flag_Rst)CmdSETstate <= state_5;
		else CmdSETstate <= state_6;		
	end
	state_6 :
	begin
//		Write_DS18B20(8'hcc);//
		Write_DS18B20(8'hbe);
		if(!Flag_Write)CmdSETstate <= state_6;
		else CmdSETstate <= state_7;
	end	
	state_7 :	
	begin
//		Write_DS18B20(8'hbe);//
		Write_DS18B20(8'hcc);
		if(!Flag_Write)CmdSETstate <= state_7;
		else CmdSETstate <= state_8;
	end	
	state_8 :
	begin
		Read_DS18B20;
		if(!Flag_Read)CmdSETstate <= state_8;
		else 
		begin
			Resultl = ResultDS18B20;
			CmdSETstate <= state_9;
		end	
	end		
	state_9 :
	begin
		Read_DS18B20;
		if(!Flag_Read)CmdSETstate <= state_9;
		else 
		begin
			Resulth = ResultDS18B20;
			CmdSETstate <= state_10;
		end	
	end		
	state_10 :
	begin
		Result = (Resulth << 4)|(Resultl >> 4);
		CmdSETstate <= state_11;
	end	
	state_11 :	
	begin
		Flag_CmdSET <= 1;
		CmdSETstate <= state_0;
	end
	default :
	begin
		Flag_CmdSET <= 0;
		CmdSETstate <= state_0;	
	end
	endcase
end
endtask
endmodule