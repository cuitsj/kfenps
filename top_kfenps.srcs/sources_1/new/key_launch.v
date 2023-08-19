module key_launch (
    input clk,
    input rst_n,
    input key,
    output reg launch_flag,//开始标志
    output reg launch_trigger//触发开始标志，串口发送00，00
);

parameter DELAY_TIME = 2000_000;//延时10ms
localparam s0 = 1'b0,s1 = 1'b1;
reg [31:0] cnt;
reg state;
reg click_n;
reg click_nr;
reg click_nrr;
reg click_np;

always @ (posedge clk)begin
    if (!rst_n) begin
        click_n <= 1'b1;
        cnt <= 0;
        state <= s0;
    end
    else begin
        case (state)
            s0 : begin
                if (key == 1'b1) begin //按键按下
                        if (cnt < DELAY_TIME - 1) begin
                            cnt <= cnt + 1'b1;
                        end
                        else begin 
                            state <= s1;
                            cnt <= 19'd0;
                            click_n <= 1'b0;
                        end
                end
                else begin //没有按下
                    click_n <= 1'b1;
                    cnt <= 19'd0;
                    state <= s0;
                end
            end
            s1 : begin
                if (key == 1'b0)begin //按键抬起
                    if (cnt < DELAY_TIME - 1)begin
                        cnt <= cnt + 1'b1;
                    end
                    else begin
                        click_n <= 1'b1;
                        state <= s0;
                        cnt <= 19'd0;
                    end
                end
                else begin //没有抬起
                    click_n <= 1'b0;
                    cnt <= 19'd0;
                    state <= s1;
                end
            end
            default : state <= s0;
        endcase
    end
end

//打两拍，检测click_n的上升沿
always @(posedge clk) begin
    if (!rst_n) begin
        click_nr <= 1'b1;
        click_nrr <= 1'b1;
        click_np <= 0;
    end
    else begin
        click_nr <= click_n;
        click_nrr <= click_nr;
        click_np <= ({click_nrr,click_nr}==2'b01)?1:0;
    end
end

//按一次按键，开始标志翻转一次
always @(posedge clk) begin
        if (!rst_n) begin
            launch_flag <= 0;
             launch_trigger <= 0;
        end
        else if (click_np) begin
            launch_flag <= ~launch_flag;
            launch_trigger <= 1'b1;
        end
        else begin
            launch_trigger <= 1'b0;
            launch_flag <= launch_flag;
        end
end

endmodule
