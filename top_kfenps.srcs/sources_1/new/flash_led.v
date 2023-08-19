module flash_led(
    input clk,
    input rst,
    input launch_flag,
    input rx_flag,
    
    output [7:0] led
);

    parameter DELAY_TIME = 2000_000;//延时10ms

    reg [7:0] led_buff;
    reg [31:0] cnt;
    reg move_flag;
    
    reg [31:0] cnt_10ms;
    reg [31:0] cnt_3s;
    reg stop_flash;//3秒没收到数据停止流水灯

    //延时10ms
    always @(posedge clk) begin
        if (!rst||!launch_flag) cnt_10ms <= 0;
        else if (cnt_10ms == DELAY_TIME-1||rx_flag) cnt_10ms <= 0;
        else cnt_10ms <= cnt_10ms + 1;
    end
    
    always @(posedge clk) begin
        if (!rst||!launch_flag) begin
            cnt_3s <= 0;
        end
        else if (cnt_10ms == DELAY_TIME-1 && cnt_3s==32'd299||rx_flag) begin//3秒钟到
            cnt_3s <= 0;
        end
        else if (cnt_10ms == DELAY_TIME-1) begin
            cnt_3s <= cnt_3s + 1;
        end
        else begin
            cnt_3s <= cnt_3s;
        end
    end
    
    always @(posedge clk) begin
        if (!rst||!launch_flag) begin
            stop_flash <= 0;
        end
        else if (cnt_10ms == DELAY_TIME-1 && cnt_3s==32'd299 && !rx_flag) begin//3秒钟到
            stop_flash <= 1;
        end
        else if (rx_flag) begin//收到数据
            stop_flash <= 0;
        end
        else begin
            stop_flash <= stop_flash;
        end
    end
    
    always @(posedge clk) begin
        if (!rst||!launch_flag||stop_flash) begin
            move_flag <= 0;
            cnt <= 0;
        end
        else if (cnt == 32'h1312cff) begin
            move_flag <= 1;
            cnt <= 0;
        end
        else begin
            move_flag <= 0;
            cnt <= cnt + 1;
        end
    end

    always @(posedge clk) begin
        if (!rst) led_buff <= 8'b0000_0001;
        else if (move_flag&&launch_flag&&!stop_flash) begin
            led_buff <= {led_buff[6:0],led_buff[7]};
        end
        else led_buff <= led_buff;
    end

    assign led = led_buff;
endmodule