/****************************************Copyright (c)**************************************************
**                                      Dongdong   Studio 
**                                     
**---------------------------------------File Info-----------------------------------------------------
** File name:			scan_clk
** Last modified Date:	2009-10-18
** Last Version:		1.0
** Descriptions:		scan_clk
**------------------------------------------------------------------------------------------------------
** Created by:		    dongdong
** Created date:		2009-10-18
** Version:				1.0
** Descriptions:		The original version
**
**------------------------------------------------------------------------------------------------------
** Modified by:			
** Modified date:		
** Version:				
** Descriptions:		
**
**------------------------------------------------------------------------------------------------------
********************************************************************************************************/
module scan_clk ( 
              //input 
              sys_clk,
              scan_clk,
              sys_rst_n,

              //output 
              da_clk,
              da_data
              );

//input ports

input                    sys_clk        ;      //system clock;
input                    scan_clk       ;      //scan clock;
input                    sys_rst_n      ;    //system reset, low is active;
                                      
//output ports                          
output [SIZE-1:0]        da_data        ;    //DA ����
output                   da_clk         ;    //DA ʱ��
//reg define                            
reg    [WIDTH1-1:0]       freq_count    ;
reg    [WIDTH2-1:0]       rom_addr      ;
reg    [WIDTH2-1:0]       scan_data     ;
reg    [WIDTH2-1:0]       counter       ;
reg    [WIDTH2-1:0]       load_counter  ;

reg                       rom_clk       ;

//wire define 


//parameter define 
parameter WIDTH1 = 32;
parameter WIDTH2 = 12;
parameter SIZE   = 10;

/*******************************************************************************************************
**                              Main Program    
**  
********************************************************************************************************/

assign da_clk = sys_clk        ;

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            load_counter <= 12'h000;
        end
        else  
            load_counter <= scan_data;         //internal scan gen 
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            counter <= 12'h0000;
        end
        else if (counter == 12'hfff) begin
            counter <= load_counter;
        end
        else  begin
            counter <= counter + 1'b1;
        end
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            rom_clk <= 1'b0;
        end
        else if (counter == 12'hfff) begin
            rom_clk <= 1'b1;
        end
        else  begin
            rom_clk <= 1'b0;
        end
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            rom_addr <= 32'h0000;
        end
        else if (rom_clk == 1'b1) 
            rom_addr <= rom_addr + 1'b1;       //gen ROM address 
end

always @(posedge scan_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            scan_data <= 12'h000;
        end
        else  
            scan_data <= scan_data + 1'b1;     
end

ROM DDS_ROM_U0 (
               .address (rom_addr) ,
               .clock   (rom_clk)  ,  
               .q       (da_data)   
               );


endmodule
//end of RTL code                       