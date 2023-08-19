module tx_process(
	input                       clk,            //系统时钟
	input                       rst_n,          //复位信号，低电平有效
	input                       txprocess_en,     //滤波器使能信号，高电平有效
    input                       tx_done,
    input signed [15:0]         leftspeed,
    input signed [15:0]         rightspeed,
    input                       launch_flag,
    input                       launch_trigger,
    
    output reg [7:0]            tx_data,
	output reg                  tx_flag   //
);

reg [2:0] tx_cnt;

reg txprocess_flag;
reg signed [15:0] leftspeed_buff;
reg signed [15:0] rightspeed_buff;

//打一拍，缓存数据
always @(posedge clk) begin
    if (!rst_n) begin
        txprocess_flag <= 0;
        leftspeed_buff <= 0;
        rightspeed_buff <= 0;
    end
    else if (txprocess_en) begin//tnps发来数据
        txprocess_flag <= 1;
        leftspeed_buff <= leftspeed;
        rightspeed_buff <= rightspeed;
    end
    else if (launch_flag&&launch_trigger)begin//发送开始触发信号
        txprocess_flag <= 1;
        leftspeed_buff <= 0;
        rightspeed_buff <= 0;
    end
    else if (tx_cnt == 7) begin//txprocess4个数据完全发完
        txprocess_flag <= 0;
        leftspeed_buff <= 0;
        rightspeed_buff <= 0;
    end
    else begin  //数据处理过程中或者还没开始处理
        txprocess_flag <= txprocess_flag;
        leftspeed_buff <= leftspeed_buff;
        rightspeed_buff <= rightspeed_buff;
    end 
end

always @(posedge clk) begin
    if(!rst_n) begin
        tx_data <= 0;
        tx_cnt <= 0;
        tx_flag <= 0;
    end
    else if (txprocess_flag&&tx_done) begin
        case (tx_cnt)
            0:begin
                tx_data <= leftspeed_buff[7:0];
                tx_cnt <= tx_cnt + 1'b1;
                tx_flag <= 1'b1;
            end
            1:begin
                tx_data <= 0;
                tx_cnt <= tx_cnt + 1'b1;
                tx_flag <= 0;
            end
            2:begin
                tx_data <= leftspeed_buff[15:8];
                tx_cnt <= tx_cnt + 1'b1;
                tx_flag <= 1'b1;
            end
            3:begin
                tx_data <= 0;
                tx_cnt <= tx_cnt + 1'b1;
                tx_flag <= 0;
            end
            4:begin
                tx_data <= rightspeed_buff[7:0];
                tx_cnt <= tx_cnt + 1'b1;
                tx_flag <= 1'b1;
            end
            5:begin
                tx_data <= 0;
                tx_cnt <= tx_cnt + 1'b1;
                tx_flag <= 0;
            end
            6:begin
                tx_data <= rightspeed_buff[15:8];
                tx_cnt <= tx_cnt + 1'b1;
                tx_flag <= 1'b1;
            end
            7:begin
                tx_data <= 0;
                tx_cnt <= 0;
                tx_flag <= 0;
            end
        endcase
    end
    else if (txprocess_flag&&tx_done==0) begin //发送过程中
        tx_data <= 0;
        tx_flag <= 0;
        tx_cnt <= tx_cnt;
    end
    else begin //数据处理完毕
        tx_data <= 0;
        tx_flag <= 0;
        tx_cnt <= 0;
    end
end

endmodule
