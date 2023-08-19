`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/04 20:52:15
// Design Name: 
// Module Name: top_enps
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_kfenps(
	input   sys_clk_p,              //系统时钟
	input   sys_clk_n,             //系统时钟
	input   sys_rst_n,             //系统复位
	input   key_launch,            //启动按键
	input   uart_rx,               //串口接收端

	output  uart_tx,            //串口发送端
    output  [7:0] led                 //led
);

//系統时钟
wire sys_clk;
//ip核
wire clk_200m;                              //200MHz时钟信号
wire clk_100m;                               //100MHz时钟信号
wire clk_50m;                              //50MHz时钟信号
wire rst_n;                                 //所有模块的复位信号
wire locked;                                //locked信号拉高,锁相环开始稳定输出时钟 

//UART接收
parameter integer CLK = 100_000_000;
parameter integer BPS = 115200;
wire [7:0] rx_data;
wire rx_done;

//接收数据处理
wire signed [15:0] IR0;
wire signed [15:0] IR1;
wire signed [15:0] IR2;
wire signed [15:0] IR5;
wire signed [15:0] IR6;
wire signed [15:0] IR7;
wire rxprecess_done;

//ENPS
wire signed [15:0] leftspeed;
wire signed [15:0] rightspeed;
wire enps_done;

//发送数据处理
wire [7:0] tx_data;
wire tx_flag;

//串口发送
wire tx_done;

//开始按键检测
wire launch_flag;
wire launch_trigger;

//系统复位与锁相环locked相与,作为其它模块的复位信号 
assign  rst_n = ~sys_rst_n & locked; 

IBUFGDS #(
    .DIFF_TERM ("FALSE"),
    .IBUF_LOW_PWR ("FALSE")
) IBUFGDS_i
(
    .I (sys_clk_p), //差分时钟正端输入
    .IB (sys_clk_n), // 差分时钟负端输入
    .O (sys_clk) //时钟缓冲输出
 );
 
 
   clk_wiz_0 clk_wiz_0_i
   (
    // Clock out ports
    .clk_out1(clk_200m),     // output clk_out1
    .clk_out2(clk_100m),     // output clk_out2
    .clk_out3(clk_50m),     // output clk_out3
    // Status and control signals
    .reset(sys_rst_n), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1

uart_rx #(
    .CLK(CLK),
    .BPS(BPS)) 
u_uart_rx(
    .clk(clk_100m),
    .rst(rst_n),
    .rx_pin(uart_rx),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .launch_flag(launch_flag)
);

rx_process rx_process_i(
    .clk(clk_100m),            //系统时钟
	.rst_n(rst_n),          //复位信号，低电平有效
	.rxprocess_en(rx_done),     //
	.uart_data(rx_data),    //

	.IR0(IR0),  //
    .IR1(IR1),  //
    .IR2(IR2),  //
    .IR5(IR5),  //
    .IR6(IR6),  //
    .IR7(IR7),  //
	.rxprocess_done(rxprecess_done),   //
	.launch_flag(launch_flag)
);

kfenps kfenps_i(
	.clk(clk_100m),            //系统时钟
	.rst_n(rst_n),          //复位信号，低电平有效
	.enps_en(rxprecess_done),     //
	.IR0(IR0),  //
    .IR1(IR1),  //
    .IR2(IR2),  //
    .IR5(IR5),  //
    .IR6(IR6),  //
    .IR7(IR7),  //
    
    .leftspeed(leftspeed),
    .rightspeed(rightspeed),
	.enps_done(enps_done),   //
	.launch_flag(launch_flag)
);
    
tx_process tx_process_i(
	.clk(clk_100m),            //系统时钟
	.rst_n(rst_n),          //复位信号，低电平有效
	.txprocess_en(enps_done),     //滤波器使能信号，高电平有效
    .tx_done(tx_done),
    .leftspeed(leftspeed),
    .rightspeed(rightspeed),
    .tx_data(tx_data),
	.tx_flag(tx_flag),   //
	.launch_flag(launch_flag),
    .launch_trigger(launch_trigger)
);

uart_tx #(
    .CLK(CLK),
    .BPS(BPS))
u_uart_tx(
    .clk(clk_100m),
    .rst(rst_n),
    .tx_en(tx_flag),
    .tx_data(tx_data),
    .tx_pin(uart_tx),
    .tx_done(tx_done)
);

key_launch key_launch_i(
    .clk(clk_200m),
    .rst_n(rst_n),
    .key(key_launch),
    .launch_flag(launch_flag),
    .launch_trigger(launch_trigger)
    );
    
//例化流水灯模块
flash_led flash_led_i(
    .clk                (clk_200m),
    .rst                (rst_n),
    .led                (led),
    .launch_flag        (launch_flag),
    .rx_flag            (rx_done)
);

////例化ILA模块
//ila_top_enps ila_top_enps_i(
//.clk(clk_200m),
//.probe0(enps_done),//1
//.probe1(tx_done),//1
//.probe2(leftspeed),//16
//.probe3(rightspeed),//16
//.probe4(tx_data),//8
//.probe5(tx_flag)//1
//);

endmodule
