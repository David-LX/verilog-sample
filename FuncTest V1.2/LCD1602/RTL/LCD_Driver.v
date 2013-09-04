/****************************************Copyright (c)**************************************************
**                                      Dongdong   Studio 
**                                     
**---------------------------------------File Info-----------------------------------------------------
** File name:           1602 LCD Driver Program
** Last modified Date:  2009-10-18
** Last Version:        1.0
** Descriptions:        driver 1602 LCD 
**------------------------------------------------------------------------------------------------------
** Created by:          LCD1602_TOP
** Created date:        2011-09-18
** Version:             1.0
** Descriptions:        The original version
**
**------------------------------------------------------------------------------------------------------
** Modified by:			
** Modified date:		
** Version:				
** Descriptions:		
**
**------------------------------------------------------------------------------------------------------
********************************************************************************************************/

//���ܼ�������1602Һ��ģ������ʾ�ַ��������е�һ����ʾ��Welcome to LCD"
//                                        �ڵڶ�����ʾ�� by DongDong  "
//Һ��ģ��Ϊ1602A�����������ο��������ֲ�

module LCD_Driver  (
// input
input                clk_lcd   ,
input                rst       ,

// output
output  wire         LCD_EN     ,
output  reg          RS         ,
output  wire         RW         ,
output  reg [7:0]    DB8          );

//LCD_ENΪLCDģ���ʹ���źţ��½��ش�����
//RS=0ʱΪдָ�RS=1ʱΪд����
//RW=0ʱ��LCDģ��ִ��д������RW=1ʱ��LCDģ��ִ�ж�����

reg     [111:0] Data_First_Buf,Data_Second_Buf;              //Һ����ʾ�����ݻ���
reg     LCD_EN_Sel                            ;
reg     [3:0] disp_count                      ;
reg     [3:0] state                           ;
parameter     Clear_Lcd = 4'b0000             ,              //��������긴λ 
              Set_Disp_Mode = 4'b0001         ,              //������ʾģʽ��8λ2��5x7����   
           	  Disp_On = 4'b0010               ,              //��ʾ��������겻��ʾ����겻������˸
              Shift_Down = 4'b0011            ,              //���ֲ���������Զ�����
              Write_Addr = 4'b0100            ,              //д����ʾ��ʼ��ַ
              Write_Data_First = 4'b0101      ,              //д���һ����ʾ������
              Write_Data_Second = 4'b0110     ,              //д��ڶ�����ʾ������
              Idel = 4'b0111;                                //����״̬
parameter     Data_First  = "Welcome to LCD",                //Һ����ʾ�ĵ�һ�е�����
              Data_Second = "  by DongDong  ";               //Һ����ʾ�ĵڶ��е�����          
       

assign  RW = 1'b0;                                           //RW=0ʱ��LCDģ��ִ��д����
assign  LCD_EN = LCD_EN_Sel ? clk_lcd : 1'b0;                //ͨ��LCD_EN_Sel�ź�������LCD_EN�Ŀ�����ر�

always @(posedge clk_lcd or negedge rst)
begin
   if(!rst)
      begin
          state <= Clear_Lcd;                               //��λ����������긴λ   
          RS <= 1'b0;                                       //��λ��RS=0ʱΪдָ�                       
          DB8 <= 8'b0;                                      //��λ��ʹDB8�������ȫ0
          LCD_EN_Sel <= 1'b1;                               //��λ������ҹ��ʹ���ź�

          disp_count <= 4'b0;
      end
   else 
      case(state)                                           //��ʼ��LCDģ��
      Clear_Lcd:
             begin
                state <= Set_Disp_Mode;
                DB8 <= 8'b00000001;                         //��������긴λ   
             end
      Set_Disp_Mode:
             begin
                state <= Disp_On;
                DB8 <= 8'b00111000;                         //������ʾģʽ��8λ2��5x8����         
             end
      Disp_On:
             begin
                state <= Shift_Down;
                DB8 <= 8'b00001100;                         //��ʾ��������겻��ʾ����겻������˸    
             end
      Shift_Down:
            begin
                state <= Write_Addr;
                DB8 <= 8'b00000110;                         //���ֲ���������Զ�����    
            end
      Write_Addr:
            begin
                state <= Write_Data_First;
                DB8 <= 8'b10000001;                         //д���һ����ʾ��ʼ��ַ����һ�еڶ���λ��    
                Data_First_Buf <= Data_First;               //����һ����ʾ�����ݸ���Data_First_Buf?
            end
      Write_Data_First:                                     //д��һ������
            begin
                if(disp_count == 14)                        //disp_count����14ʱ��ʾ��һ��������д��
                    begin
                        DB8 <= 8'b11000001;                 //����д�ڶ��е�ָ��
                        RS <= 1'b0;
                        disp_count <= 4'b0; 
                        Data_Second_Buf <= Data_Second;
                        state <= Write_Data_Second;         //д���һ�н���д�ڶ���״̬
                    end
                else
                    begin
                        DB8 <= Data_First_Buf[111:104];
                        Data_First_Buf <= (Data_First_Buf << 8);
                        RS <= 1'b1;                         //RS=1��ʾд����
                        disp_count <= disp_count + 1'b1;
                        state <= Write_Data_First; 
                    end
            end
      Write_Data_Second:                                    //д�ڶ�������
            begin
                if(disp_count == 14)
                    begin
                        LCD_EN_Sel <= 1'b0;
                        RS <= 1'b0;
                        disp_count <= 4'b0; 
                        state <= Idel;                      //д��������״̬
                    end
                else
                    begin
                        DB8 <= Data_Second_Buf[111:104];
                        Data_Second_Buf <= (Data_Second_Buf << 8);
                        RS <= 1'b1;
                        disp_count <= disp_count + 1'b1;
                        state <= Write_Data_Second; 
                    end              
            end
      Idel:     
            begin
                state <=  Idel;                             //��Idel״̬ѭ��  
            end
      default:  state <= Clear_Lcd;                         //��stateΪ����ֵ����state��ΪClear_Lcd 
      endcase 
end
endmodule


