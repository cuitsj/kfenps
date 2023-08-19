module tx_process(
	input                       clk,            //ϵͳʱ��
	input                       rst_n,          //��λ�źţ��͵�ƽ��Ч
	input                       txprocess_en,     //�˲���ʹ���źţ��ߵ�ƽ��Ч
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

//��һ�ģ���������
always @(posedge clk) begin
    if (!rst_n) begin
        txprocess_flag <= 0;
        leftspeed_buff <= 0;
        rightspeed_buff <= 0;
    end
    else if (txprocess_en) begin//tnps��������
        txprocess_flag <= 1;
        leftspeed_buff <= leftspeed;
        rightspeed_buff <= rightspeed;
    end
    else if (launch_flag&&launch_trigger)begin//���Ϳ�ʼ�����ź�
        txprocess_flag <= 1;
        leftspeed_buff <= 0;
        rightspeed_buff <= 0;
    end
    else if (tx_cnt == 7) begin//txprocess4��������ȫ����
        txprocess_flag <= 0;
        leftspeed_buff <= 0;
        rightspeed_buff <= 0;
    end
    else begin  //���ݴ�������л��߻�û��ʼ����
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
    else if (txprocess_flag&&tx_done==0) begin //���͹�����
        tx_data <= 0;
        tx_flag <= 0;
        tx_cnt <= tx_cnt;
    end
    else begin //���ݴ������
        tx_data <= 0;
        tx_flag <= 0;
        tx_cnt <= 0;
    end
end

endmodule
