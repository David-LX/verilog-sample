/****************************************Copyright (c)**************************************************
**                                      Dongdong   Studio 
**                                     
**---------------------------------------File Info-----------------------------------------------------
** File name:			bin2gray
** Last modified Date:	2009-10-18
** Last Version:		1.0
** Descriptions:		bin 2 gray
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
module divider2_4 ( 
              //input 
			  sys_clk,
		      sys_rst_n,


              //output 
              clk_1,
              clk_2,

              );

//input ports

input                    sys_clk;      //system clock;
input                    sys_rst_n;    //system reset, low is active;


//output ports
output                   clk_1;
output                   clk_2;

//reg define 

reg    [1:0]             counter;

reg                      clk_1;
reg                      clk_2;

//wire define 


//parameter define 
parameter WIDTH = 8;
parameter SIZE  = 8;

/*******************************************************************************************************
**                              Main Program    
**  
********************************************************************************************************/

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            counter <= 2'b0;
        end
        else  
            counter  <= counter +2'b1;
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            clk_1 <= 1'b0;
        end
        else if ((counter == 2'b00) || (counter == 2'b10))
            clk_1  <= 1'b1;
        else if ((counter == 2'b01) || (counter == 2'b11))
            clk_1  <= 1'b0;
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            clk_2 <= 1'b0;
        end
        else if (counter == 2'b00) 
            clk_2  <= 1'b1;
        else if (counter == 2'b10)
            clk_2  <= 1'b0;
end

endmodule
//end of RTL code                       