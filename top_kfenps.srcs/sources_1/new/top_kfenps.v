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
	input   sys_clk_p,              //ϵͳʱ��
	input   sys_clk_n,             //ϵͳʱ��
	input   sys_rst_n,             //ϵͳ��λ
	input   key_launch,            //��������
	input   uart_rx,               //���ڽ��ն�

	output  uart_tx,            //���ڷ��Ͷ�
    output  [7:0] led                 //led
);

//ϵ�yʱ��
wire sys_clk;
//ip��
wire clk_200m;                              //200MHzʱ���ź�
wire clk_100m;                               //100MHzʱ���ź�
wire clk_50m;                              //50MHzʱ���ź�
wire rst_n;                                 //����ģ��ĸ�λ�ź�
wire locked;                                //locked�ź�����,���໷��ʼ�ȶ����ʱ�� 

//UART����
parameter integer CLK = 100_000_000;
parameter integer BPS = 115200;
wire [7:0] rx_data;
wire rx_done;

//�������ݴ���
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

//�������ݴ���
wire [7:0] tx_data;
wire tx_flag;

//���ڷ���
wire tx_done;

//��ʼ�������
wire launch_flag;
wire launch_trigger;

//ϵͳ��λ�����໷locked����,��Ϊ����ģ��ĸ�λ�ź� 
assign  rst_n = ~sys_rst_n & locked; 

IBUFGDS #(
    .DIFF_TERM ("FALSE"),
    .IBUF_LOW_PWR ("FALSE")
) IBUFGDS_i
(
    .I (sys_clk_p), //���ʱ����������
    .IB (sys_clk_n), // ���ʱ�Ӹ�������
    .O (sys_clk) //ʱ�ӻ������
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
    .clk(clk_100m),            //ϵͳʱ��
	.rst_n(rst_n),          //��λ�źţ��͵�ƽ��Ч
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
	.clk(clk_100m),            //ϵͳʱ��
	.rst_n(rst_n),          //��λ�źţ��͵�ƽ��Ч
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
	.clk(clk_100m),            //ϵͳʱ��
	.rst_n(rst_n),          //��λ�źţ��͵�ƽ��Ч
	.txprocess_en(enps_done),     //�˲���ʹ���źţ��ߵ�ƽ��Ч
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
    
//������ˮ��ģ��
flash_led flash_led_i(
    .clk                (clk_200m),
    .rst                (rst_n),
    .led                (led),
    .launch_flag        (launch_flag),
    .rx_flag            (rx_done)
);

////����ILAģ��
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
