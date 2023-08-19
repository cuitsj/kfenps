module rx_process(
	input                clk,            //ʱ��
	input                rst_n,          //��λ
	input                rxprocess_en,     //ʹ��
	input [7:0]          uart_data,    //��������
	input                launch_flag,

	output reg signed [15:0]    IR0,  //��������
    output reg signed [15:0]    IR1,  //
    output reg signed [15:0]    IR2,  //
    output reg signed [15:0]    IR5,  //
    output reg signed [15:0]    IR6,  //
    output reg signed [15:0]    IR7,  //
	output reg                 rxprocess_done   //������ɱ�־
);

reg rxprocess_flag;//��ʼ�����־

reg [7:0] uart_data_buff;//�������ݻ���
reg signed [15:0]    IR0_BUFF; //�������ݻ���
reg signed [15:0]    IR1_BUFF; //
reg signed [15:0]    IR2_BUFF; //
reg signed [15:0]    IR5_BUFF; //
reg signed [15:0]    IR6_BUFF; //
reg signed [15:0]    IR7_BUFF; //

reg [3:0] data_cnt;//��������ݸ�������

//��һ�ģ�
always @(posedge clk) begin
    if (!rst_n||!launch_flag) begin
        rxprocess_flag <= 0;
        uart_data_buff <= 0;
    end
    else if (rxprocess_en) begin//���洮�����ݣ���ʼ�����־��һ��
        rxprocess_flag <= 1;
        uart_data_buff <= uart_data;
    end
    else begin//��û��ʼ�����ڴ���Ĺ�����
        rxprocess_flag <= 0;
        uart_data_buff <= 0;
    end 
end
    
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        IR0 <= 0;
        IR1 <= 0;
        IR2 <= 0;
        IR5 <= 0;
        IR6 <= 0;
        IR7 <= 0;
        IR0_BUFF <= 0;
        IR1_BUFF <= 0;
        IR2_BUFF <= 0;
        IR5_BUFF <= 0;
        IR6_BUFF <= 0;
        IR7_BUFF <= 0;
        data_cnt<= 0;
        rxprocess_done <= 0;
    end
    else if (rxprocess_flag) begin
        case (data_cnt)
            0:begin
                IR0_BUFF[7:0] <= uart_data_buff;
                data_cnt <= data_cnt + 1'b1;
                rxprocess_done <= 0;
            end
            1:begin
                IR0_BUFF[15:8] <= uart_data_buff;
                data_cnt <= data_cnt + 1'b1;
                rxprocess_done <= 0;
            end
            
            2:begin
                IR1_BUFF[7:0] <= uart_data_buff;
                data_cnt <= data_cnt + 1'b1;
                rxprocess_done <= 0;
            end
            3:begin
                IR1_BUFF[15:8] <= uart_data_buff;
                data_cnt <= data_cnt + 1'b1;
                rxprocess_done <= 0;
            end
            
            4:begin
                IR2_BUFF[7:0] <= uart_data_buff;
                data_cnt <= data_cnt + 1'b1;
                rxprocess_done <= 0;
            end
            5:begin
                IR2_BUFF[15:8] <= uart_data_buff;
                data_cnt <= data_cnt + 1'b1;
                rxprocess_done <= 0;
            end
            
            6:begin
                IR5_BUFF[7:0] <= uart_data_buff;
                data_cnt <= data_cnt + 1'b1;
                rxprocess_done <= 0;
            end
            7:begin
                IR5_BUFF[15:8] <= uart_data_buff;
                data_cnt <= data_cnt + 1'b1;
                rxprocess_done <= 0;
            end
            
            8:begin
                IR6_BUFF[7:0] <= uart_data_buff;
                data_cnt <= data_cnt + 1'b1;
                rxprocess_done <= 0;
            end
            9:begin
                IR6_BUFF[15:8] <= uart_data_buff;
                data_cnt <= data_cnt + 1'b1;
                rxprocess_done <= 0;
            end
            
            10:begin
                IR7_BUFF[7:0] <= uart_data_buff;
                data_cnt <= data_cnt + 1'b1;
                rxprocess_done <= 0;
            end
           11:begin
                IR0 <= IR0_BUFF;
                IR1 <= IR1_BUFF;
                IR2 <= IR2_BUFF;
                IR5 <= IR5_BUFF;
                IR6 <= IR6_BUFF;
                IR7 <= {uart_data_buff,IR7_BUFF[7:0]};
                IR0_BUFF <= 0;
                IR1_BUFF <= 0;
                IR2_BUFF <= 0;
                IR5_BUFF <= 0;
                IR6_BUFF <= 0;
                IR7_BUFF <= 0;
                data_cnt <= 0;
                rxprocess_done <= 1;
            end
            default:begin
                IR0 <= 0;
                IR1 <= 0;
                IR2 <= 0;
                IR5 <= 0;
                IR6 <= 0;
                IR7 <= 0;
                IR0_BUFF <= 0;
                IR1_BUFF <= 0;
                IR2_BUFF <= 0;
                IR5_BUFF <= 0;
                IR6_BUFF <= 0;
                IR7_BUFF <= 0;
                data_cnt <= 0;
                rxprocess_done <= 0;
            end
        endcase
    end
    else begin
        IR0 <= 0;
        IR1 <= 0;
        IR2 <= 0;
        IR5 <= 0;
        IR6 <= 0;
        IR7 <= 0;
        IR0_BUFF <= IR0_BUFF;
        IR1_BUFF <= IR1_BUFF;
        IR2_BUFF <= IR2_BUFF;
        IR5_BUFF <= IR5_BUFF;
        IR6_BUFF <= IR6_BUFF;
        IR7_BUFF <= IR7_BUFF;
        rxprocess_done <= 0;
    end
end

endmodule
