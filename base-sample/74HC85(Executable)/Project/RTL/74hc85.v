/**********************************************版权申明*************************************************
**
**--------------------------------------------文件信息--------------------------------------------------
** 文件名称：        	74HC85.v
** 最后修改日期：    	2013-07-01
** 最新版本：        	V1.2
** 功能描述：        	完成一个4位比较器的功能
**                                            
********************************************************************************************************/
module	compare4(
input	         [3:0]		key,				//	比较值
 
output  wire	[7:0]		LED 			   //	比较结果输出端
				);

// reg define
reg	[2:0]		f_out 			;
		
// wire define
wire	[4:0]		a_in  			;
wire	[3:0]		b_in  			;

//******************************************************************************
//  模块名称：4位比较器模块
//  功能描述：完成4位比较器的功能
//******************************************************************************
// assign  i_in is 3'b111 for run in our FPGA devlop board
assign i_in = 3'b111;                  //	扩展输入端

assign a_in = { key[3:2], key[3:2] };  // 第一个4位比较值
assign b_in = { key[1:0], key[1:0] };  //	第二个4位比较值

assign LED = { 5'h0, f_out };          //	比较结果

// 74HC85 RTL Code
always@( * ) begin
	if ( a_in > b_in )
		 f_out =	3'b100;				   	//	输出a大于b			
	else if( a_in < b_in )
       f_out = 3'b010;					   //	输出a小于b
	else begin
		case( i_in )
		3'b100:
				f_out = 3'b100;			   //	输出a大于b
		3'b010:
				f_out = 3'b010;			   //	输出a小于b
		3'b001:						
				f_out = 3'b001;			   //	输出a等于b
  	   default:
				f_out = 3'b001; 		      //	输出a等于b
		endcase
	end
end

endmodule

// 淘宝店铺：
// http://shop67541132.taobao.com
// http://shop69029874.taobao.com

