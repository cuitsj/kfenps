module uart_rx#(
    parameter integer CLK = 200_000_000,
    parameter integer BPS = 115200
)(
    input   clk,
    input   rst,
    input   rx_pin,
    input   launch_flag,
    
    output reg [7:0] rx_data,
    output reg rx_done
);


localparam  BPS_CNT = CLK/BPS;

reg rx_pinr;
reg rx_pinrr;
reg rx_flag;
reg [3:0] rx_cnt;
reg [15:0] clk_cnt;
reg [7:0] data_buff;

wire rx_start;

//下降沿是开始信号
assign rx_start = rx_pinrr &(~rx_pinr);

//输入管脚信号打两拍
always @(posedge clk) begin
    if (!rst||!launch_flag) begin
        rx_pinr <= 0;
        rx_pinrr <= 0;
    end
    else begin
        rx_pinr <= rx_pin;
        rx_pinrr <= rx_pinr;
    end
end

//接收过程标志置位
always @(posedge clk) begin
    if (!rst||!launch_flag) begin 
        rx_flag <= 0;
        rx_data <= 0;
        rx_done <= 0;
    end
    else if (rx_start) begin//接收开始
        rx_flag <= 1;
        rx_data <= 0;
        rx_done <= 0;
    end
    else if (rx_cnt == 4'd9 && clk_cnt == BPS_CNT/2) begin//接收结束
        rx_flag <= 0;
        rx_data <= data_buff;
        rx_done <= 1;
    end
    else begin//接收的过程中或者没开始
        rx_flag <= rx_flag;
        rx_data <= 0;
        rx_done <= 0;
    end
end

 //波特率计数，接收数据位个数计数
always @(posedge clk) begin
    if (!rst||!launch_flag) begin
        clk_cnt <= 0;
        rx_cnt <= 0;
    end
    else if (rx_flag) begin//接收状态，开始计数
        if (clk_cnt == BPS_CNT - 1) begin//计数到一位数据的时间
            clk_cnt <= 0;
            rx_cnt <= rx_cnt + 1'b1;//接收的数据位数计数
        end
        else clk_cnt <= clk_cnt + 1'b1;//波特率计数
    end
    else begin//接收过程结束
        clk_cnt <= 0;
        rx_cnt <= 0;
    end
end

//将信号线上的数据存入数据缓存寄存器
always @(posedge clk) begin
    if (!rst||!launch_flag) data_buff <= 0;
    else if (rx_flag) begin
        if (clk_cnt == BPS_CNT/2) begin
            case (rx_cnt)
                4'd1:data_buff[0] <= rx_pinrr;
                4'd2:data_buff[1] <= rx_pinrr;
                4'd3:data_buff[2] <= rx_pinrr;
                4'd4:data_buff[3] <= rx_pinrr;
                4'd5:data_buff[4] <= rx_pinrr;
                4'd6:data_buff[5] <= rx_pinrr;
                4'd7:data_buff[6] <= rx_pinrr;
                4'd8:data_buff[7] <= rx_pinrr;
                default:;
            endcase
        end
        else data_buff <= data_buff;
    end
    else data_buff <= 0;
end
    
endmodule
