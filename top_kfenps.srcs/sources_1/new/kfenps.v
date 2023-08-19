module kfenps#(
    parameter integer Q = 60,
    parameter integer R = 8
)(
	input                       clk,            
	input                       rst_n,         
	input                       enps_en,    
	input signed [15:0]    IR0, 
    input signed [15:0]    IR1,  
    input signed [15:0]    IR2, 
    input signed [15:0]    IR5, 
    input signed [15:0]    IR6, 
    input signed [15:0]    IR7, 
    input           launch_flag,
    
    output reg signed [15:0]         leftspeed,
    output reg signed [15:0]         rightspeed,
	output reg                  enps_done   //一次滤波完成后置1
);

reg m1e1,m2e1,m3e1,m4e1,m5e1,m6e1,m7e1;    //膜1的酶变量
reg m1e2,m2e2,m3e2,m4e2,m5e2,m6e2,m7e2;
reg f1,f2,f3,f4,f5,f6,f7;  //变量
reg signed [15:0] IR0_last,IR1_last,IR2_last,IR5_last,IR6_last,IR7_last;
reg signed [15:0] Pt_last0,Pt_last1,Pt_last2,Pt_last5,Pt_last6,Pt_last7;
reg signed [15:0] IR0_KF,IR1_KF,IR2_KF,IR5_KF,IR6_KF,IR7_KF;
reg signed [7:0] Q0,Q1,Q2,Q5,Q6,Q7;
reg signed [7:0] R0,R1,R2,R5,R6,R7;

reg enps_flag;
reg signed [15:0] IR0_BUFF;
reg signed [15:0] IR1_BUFF;
reg signed [15:0] IR2_BUFF;
reg signed [15:0] IR5_BUFF;
reg signed [15:0] IR6_BUFF;
reg signed [15:0] IR7_BUFF;

//除法器IP核
reg div_start;
wire finish_div1,finish_div2,finish_div3,finish_div4,finish_div5,finish_div6,finish_div7,finish_div8,finish_div9,finish_div10,finish_div11,finish_div12;
wire div_done;
wire signed [31:0] dout1,dout2,dout3,dout4,dout5,dout6,dout7,dout8,dout9,dout10,dout11,dout12;
reg signed [15:0] dout_int1,dout_int2,dout_int3,dout_int4,dout_int5,dout_int6,dout_int7,dout_int8,dout_int9,dout_int10,dout_int11,dout_int12;

//assign div_done=(finish_div1&&finish_div2&&finish_div3&&finish_div4&&finish_div5&&finish_div6&&finish_div7&&finish_div8&&finish_div9&&finish_div10&&finish_div11&&finish_div12)?1'b1:1'b0;

//膜2
kfenps_div kfenps_div1 (
  .aclk(clk),                                      // input wire aclk
  .aresetn(rst_n),                                // input wire aresetn
  .s_axis_divisor_tvalid(div_start),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(Pt_last0+Q0+R0),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_start),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata((IR0_BUFF-IR0_last)*(Pt_last0+Q0)),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(finish_div1),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout1)            // output wire [31 : 0] m_axis_dout_tdata
);

//assign dout_int1=dout1[31:16];

kfenps_div kfenps_div2 (
  .aclk(clk),                                      // input wire aclk
  .aresetn(rst_n),                                // input wire aresetn
  .s_axis_divisor_tvalid(div_start),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata((Pt_last0+Q0+R0)),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_start),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata((Pt_last0*R0+Q0*R0)),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(finish_div2),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout2)            // output wire [31 : 0] m_axis_dout_tdata
);

//assign dout_int2=dout2[31:16];

//膜3
kfenps_div kfenps_div3 (
  .aclk(clk),                                      // input wire aclk
  .aresetn(rst_n),                                // input wire aresetn
  .s_axis_divisor_tvalid(div_start),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(Pt_last1+Q1+R1),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_start),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata((IR1_BUFF-IR1_last)*(Pt_last1+Q1)),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(finish_div3),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout3)            // output wire [31 : 0] m_axis_dout_tdata
);

//assign dout_int3=dout3[31:16];

kfenps_div kfenps_div4 (
  .aclk(clk),                                      // input wire aclk
  .aresetn(rst_n),                                // input wire aresetn
  .s_axis_divisor_tvalid(div_start),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata((Pt_last1+Q1+R1)),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_start),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata((Pt_last1*R1+Q1*R1)),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(finish_div4),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout4)            // output wire [31 : 0] m_axis_dout_tdata
);

//assign dout_int4=dout4[31:16];

//膜4
kfenps_div kfenps_div5 (
  .aclk(clk),                                      // input wire aclk
  .aresetn(rst_n),                                // input wire aresetn
  .s_axis_divisor_tvalid(div_start),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(Pt_last2+Q2+R2),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_start),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata((IR2_BUFF-IR2_last)*(Pt_last2+Q2)),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(finish_div5),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout5)            // output wire [41 : 0] m_axis_dout_tdata
);

//assign dout_int5=dout5[31:16];

kfenps_div kfenps_div6 (
  .aclk(clk),                                      // input wire aclk
  .aresetn(rst_n),                                // input wire aresetn
  .s_axis_divisor_tvalid(div_start),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata((Pt_last2+Q2+R2)),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_start),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata((Pt_last2*R2+Q2*R2)),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(finish_div6),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout6)            // output wire [31 : 0] m_axis_dout_tdata
);
//assign dout_int6=dout6[31:16];

//膜5
kfenps_div kfenps_div7 (
  .aclk(clk),                                      // input wire aclk
  .aresetn(rst_n),                                // input wire aresetn
  .s_axis_divisor_tvalid(div_start),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(Pt_last5+Q5+R5),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_start),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata((IR5_BUFF-IR5_last)*(Pt_last5+Q5)),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(finish_div7),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout7)            // output wire [41 : 0] m_axis_dout_tdata
);

//assign dout_int7=dout7[31:16];

kfenps_div kfenps_div8 (
  .aclk(clk),                                      // input wire aclk
  .aresetn(rst_n),                                // input wire aresetn
  .s_axis_divisor_tvalid(div_start),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata((Pt_last5+Q5+R5)),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_start),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata((Pt_last5*R5+Q5*R5)),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(finish_div8),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout8)            // output wire [31 : 0] m_axis_dout_tdata
);
//assign dout_int8=dout8[31:16];

//膜6
kfenps_div kfenps_div9 (
  .aclk(clk),                                      // input wire aclk
  .aresetn(rst_n),                                // input wire aresetn
  .s_axis_divisor_tvalid(div_start),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(Pt_last6+Q6+R6),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_start),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata((IR6_BUFF-IR6_last)*(Pt_last6+Q6)),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(finish_div9),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout9)            // output wire [41 : 0] m_axis_dout_tdata
);

//assign dout_int9=dout9[31:16];

kfenps_div kfenps_div10 (
  .aclk(clk),                                      // input wire aclk
  .aresetn(rst_n),                                // input wire aresetn
  .s_axis_divisor_tvalid(div_start),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata((Pt_last6+Q6+R6)),      // input wire [16 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_start),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata((Pt_last6*R6+Q6*R6)),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(finish_div10),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout10)            // output wire [31 : 0] m_axis_dout_tdata
);
//assign dout_int10=dout10[31:16];

//膜7
kfenps_div kfenps_div11 (
  .aclk(clk),                                      // input wire aclk
  .aresetn(rst_n),                                // input wire aresetn
  .s_axis_divisor_tvalid(div_start),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(Pt_last7+Q7+R7),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_start),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata((IR7_BUFF-IR7_last)*(Pt_last7+Q7)),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(finish_div11),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout11)            // output wire [41 : 0] m_axis_dout_tdata
);

//assign dout_int11=dout11[31:16];

kfenps_div kfenps_div12 (
  .aclk(clk),                                      // input wire aclk
  .aresetn(rst_n),                                // input wire aresetn
  .s_axis_divisor_tvalid(div_start),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata((Pt_last7+Q7+R7)),      // input wire [16 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(div_start),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata((Pt_last7*R7+Q7*R7)),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(finish_div12),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout12)            // output wire [31 : 0] m_axis_dout_tdata
);
//assign dout_int12=dout12[31:16];

//打一拍，缓存数据
always @(posedge clk) begin
    if (!rst_n||!launch_flag) begin
        enps_flag <= 0;
        IR0_BUFF <= 0;
        IR1_BUFF <= 0;
        IR2_BUFF <= 0;
        IR5_BUFF <= 0;
        IR6_BUFF <= 0;
        IR7_BUFF <= 0;
        enps_done <= 0;
    end
    else if (enps_en==1'b1) begin//缓存数据开始做除法
        enps_flag <= 0;
        IR0_BUFF <= IR0;
        IR1_BUFF <= IR1;
        IR2_BUFF <= IR2;
        IR5_BUFF <= IR5;
        IR6_BUFF <= IR6;
        IR7_BUFF <= IR7;
        enps_done <= 0;
    end
    else if (finish_div1&&finish_div2&&finish_div3&&finish_div4&&finish_div5&&finish_div6&&finish_div7&&finish_div8&&finish_div9&&finish_div10&&finish_div11&&finish_div12&&div_start) begin//除法完成，开始enps
        enps_flag <= 1;
        IR0_BUFF <= IR0_BUFF;
        IR1_BUFF <= IR1_BUFF;
        IR2_BUFF <= IR2_BUFF;
        IR5_BUFF <= IR5_BUFF;
        IR6_BUFF <= IR6_BUFF;
        IR7_BUFF <= IR7_BUFF;
        enps_done <= 0;
    end
    else if (m1e2==1'b1) begin//ENPS完成
        enps_flag <= 0;
        IR0_BUFF <= 0;
        IR1_BUFF <= 0;
        IR2_BUFF <= 0;
        IR5_BUFF <= 0;
        IR6_BUFF <= 0;
        IR7_BUFF <= 0;
        enps_done <= 1;
    end
    else begin  //除法过程中或者ENPS过程中
        enps_flag <= enps_flag;
        IR0_BUFF <= IR0_BUFF;
        IR1_BUFF <= IR1_BUFF;
        IR2_BUFF <= IR2_BUFF;
        IR5_BUFF <= IR5_BUFF;
        IR6_BUFF <= IR6_BUFF;
        IR7_BUFF <= IR7_BUFF;
        enps_done <= 0;
    end 
end

always @(posedge clk) begin
    if (!rst_n||!launch_flag) begin
        div_start <= 0;
        dout_int1<=0;
        dout_int2<=0;
        dout_int3<=0;
        dout_int4<=0;
        dout_int5<=0;
        dout_int6<=0;
        dout_int7<=0;
        dout_int8<=0;
        dout_int9<=0;
        dout_int10<=0;
        dout_int11<=0;
        dout_int12<=0;
    end
    else if (enps_en) begin//开始做除法
        div_start <= 1;
    end
    else if (finish_div1&&finish_div2&&finish_div3&&finish_div4&&finish_div5&&finish_div6&&finish_div7&&finish_div8&&finish_div9&&finish_div10&&finish_div11&&finish_div12&&div_start) begin//除法完成，开始enps
        div_start <= 0;
        dout_int1<=dout1[31:16];
        dout_int2<=dout2[31:16];
        dout_int3<=dout3[31:16];
        dout_int4<=dout4[31:16];
        dout_int5<=dout5[31:16];
        dout_int6<=dout6[31:16];
        dout_int7<=dout7[31:16];
        dout_int8<=dout8[31:16];
        dout_int9<=dout9[31:16];
        dout_int10<=dout10[31:16];
        dout_int11<=dout11[31:16];
        dout_int12<=dout12[31:16];
    end
    //!!!!!!不能添加else保持不变语句！！！！
end

/**********************膜1********************************/
//生成分规则1
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        leftspeed <= 0;
        f1 <= 0;
    end
    else if (enps_flag) begin
        if (m1e2 > f1 || m1e2 > IR0_KF ||  m1e2 > IR1_KF ||  m1e2 > IR2_KF ||  m1e2 > leftspeed)begin
            leftspeed <= f1+550-IR0_KF*8-IR1_KF*4-IR2_KF*2+0*leftspeed;
        end
    end
end

//生成分规则2
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        rightspeed <= 0;
    end
    else if (enps_flag) begin
        if (m1e2 > f1 || m1e2 > IR7_KF ||  m1e2 > IR6_KF ||  m1e2 > IR5_KF ||  m1e2 > rightspeed)begin
            rightspeed <= f1+550-IR7_KF*8-IR6_KF*4-IR5_KF*2+0*rightspeed;
        end
    end
end

//生成分规则3
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m1e2 <= 0;
    end
    else if (enps_flag) begin
        if (m1e1 > f1 ||  m1e1 > m1e2)begin
            m1e2 <= 1+f1+0*m1e1+0*m1e2;
        end
        else m1e2 <= 0;
    end
end

//生成分规则4
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m1e1 <= 1;
    end
    else if (enps_flag) begin
        if (m1e2 > f1 ||  m1e2 > m1e1)begin
            m1e1 <= 1+f1+0*m1e1+0*m1e2;
        end
        else m1e1 <= 0;
    end
end
/**********************膜1********************************/

/**********************膜2********************************/
//生成分规则1
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        f2 <= 0;
        IR0_KF<=0;
    end
    else if (enps_flag) begin
        if (m2e1 > f2 || m2e1 > IR0_last ||  m2e1 > IR0_BUFF ||  m2e1 > Pt_last0 || m2e1>Q0 || m2e1>R0)begin
            IR0_KF <= f2+IR0_last+dout_int1;
        end
    end
end

//生成分规则2
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        IR0_last<=0; 
    end
    else if (enps_flag) begin
        if (m2e1 > f2 || m2e1 > IR0_last ||  m2e1 > IR0_BUFF ||  m2e1 > Pt_last0 || m2e1>Q0 || m2e1>R0)begin
            IR0_last <= f2+IR0_last+dout_int1;
        end
    end
end

//生成分规则3
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        Pt_last0<=0;
    end
    else if (enps_flag) begin
        if (m2e1 > f2 || m2e1 > Pt_last0 || m2e1>Q0 || m2e1>R0)begin
            Pt_last0 <= f2+dout_int2;
        end
    end
end

//生成分规则4
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        Q0<=Q;
    end
    else if (enps_flag) begin
        if (m2e1 > f2 || m2e1 > Q0)begin
            Q0 <= f2+Q+0*Q0;
        end
        else Q0<=Q0;
    end
end

//生成分规则5
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        R0<=R;
    end
    else if (enps_flag) begin
        if (m2e1 > f2 || m2e1 > R0)begin
            R0 <= f2+R+0*R0;
        end
        else R0<=R0;
    end
end

//生成分规则6
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m2e2 <= 0;
    end
    else if (enps_flag) begin
        if (m2e1 > f2 ||  m2e1 > m2e2)begin
            m2e2 <= 1+f2+0*m2e1+0*m2e2;
        end
        else m2e2 <= 0;
    end
end

//生成分规则7
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m2e1 <= 1;
    end
    else if (enps_flag) begin
        if (m2e2 > f2 ||  m2e2 > m2e1)begin
            m2e1 <= 1+f2+0*m2e1+0*m2e2;
        end
        else m2e1 <= 0;
    end
end
/**********************膜2********************************/

/**********************膜3********************************/
//生成分规则1
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        f3 <= 0;
        IR1_KF<=0;
    end
    else if (enps_flag) begin
        if (m3e1 > f3 || m3e1 > IR1_last ||  m3e1 > IR1_BUFF ||  m3e1 > Pt_last1 || m3e1>Q1 || m3e1>R1)begin
            IR1_KF <= f3+IR1_last+dout_int3;
        end
    end
end

//生成分规则2
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        IR1_last<=0;
    end
    else if (enps_flag) begin
        if (m3e1 > f3 || m3e1 > IR1_last ||  m3e1 > IR1_BUFF ||  m3e1 > Pt_last1 || m3e1>Q1 || m3e1>R1)begin
            IR1_last <= f3+IR1_last+dout_int3;
        end
    end
end

//生成分规则3
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        Pt_last1<=0;
    end
    else if (enps_flag) begin
        if (m3e1 > f3 || m3e1 > Pt_last1 || m3e1>Q1 || m3e1>R1)begin
            Pt_last1 <= f3+dout_int4;
        end
    end
end

//生成分规则4
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        Q1<=Q;
    end
    else if (enps_flag) begin
        if (m3e1 > f3 || m3e1 > Q1)begin
            Q1 <= f3+Q+0*Q1;
        end
        else Q1<=Q1;
    end
end

//生成分规则5
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        R1<=R;
    end
    else if (enps_flag) begin
        if (m3e1 > f3 || m3e1 > R1)begin
            R1 <= f3+R+0*R1;
        end
        else R1<=R1;
    end
end

//生成分规则6
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m3e2 <= 0;
    end
    else if (enps_flag) begin
        if (m3e1 > f3 ||  m3e1 > m3e2)begin
            m3e2 <= 1+f3+0*m3e1+0*m3e2;
        end
        else m3e2 <= 0;
    end
end

//生成分规则7
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m3e1 <= 1;
    end
    else if (enps_flag) begin
        if (m3e2 > f3 ||  m3e2 > m3e1)begin
            m3e1 <= 1+f3+0*m3e1+0*m3e2;
        end
        else m3e1 <= 0;
    end
end
/**********************膜3********************************/

/**********************膜4********************************/
//生成分规则1
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        f4 <= 0;
        IR2_KF<=0;
    end
    else if (enps_flag) begin
        if (m4e1 > f4 || m4e1 > IR2_last ||  m4e1 > IR2_BUFF ||  m4e1 > Pt_last2 || m4e1>Q2 || m4e1>R2)begin
            IR2_KF <= f4+IR2_last+dout_int5;
        end
    end
end

//生成分规则2
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        IR2_last<=0;
    end
    else if (enps_flag) begin
        if (m4e1 > f4 || m4e1 > IR2_last ||  m4e1 > IR2_BUFF ||  m4e1 > Pt_last2 || m4e1>Q2 || m4e1>R2)begin
            IR2_last <= f4+IR2_last+dout_int5;
        end
    end
end

//生成分规则3
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        Pt_last2<=0;
    end
    else if (enps_flag) begin
        if (m4e1 > f4 || m4e1 > Pt_last2 || m4e1>Q2 || m4e1>R2)begin
            Pt_last2 <= f4+dout_int6;
        end
    end
end

//生成分规则4
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        Q2<=Q;
    end
    else if (enps_flag) begin
        if (m4e1 > f4 || m4e1 > Q2)begin
            Q2 <= f4+Q+0*Q2;
        end
        else Q2<=Q2;
    end
end

//生成分规则5
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        R2<=R;
    end
    else if (enps_flag) begin
        if (m4e1 > f4 || m4e1 > R2)begin
            R2 <= f4+R+0*R2;
        end
        else R2<=R2;
    end
end

//生成分规则6
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m4e2 <= 0;
    end
    else if (enps_flag) begin
        if (m4e1 > f4 ||  m4e1 > m4e2)begin
            m4e2 <= 1+f4+0*m4e1+0*m4e2;
        end
        else m4e2 <= 0;
    end
end

//生成分规则7
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m4e1 <= 1;
    end
    else if (enps_flag) begin
        if (m4e2 > f4 ||  m4e2 > m4e1)begin
            m4e1 <= 1+f4+0*m4e1+0*m4e2;
        end
        else m4e1 <= 0;
    end
end
/**********************膜4********************************/

/**********************膜5********************************/
//生成分规则1
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        f5 <= 0;
        IR5_KF<=0;
    end
    else if (enps_flag) begin
        if (m5e1 > f5 || m5e1 > IR5_last ||  m5e1 > IR5_BUFF ||  m5e1 > Pt_last5 || m5e1>Q5 || m5e1>R5)begin
            IR5_KF <= f5+IR5_last+dout_int7;
        end
    end
end

//生成分规则2
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        IR5_last<=0;
    end
    else if (enps_flag) begin
        if (m5e1 > f5 || m5e1 > IR5_last ||  m5e1 > IR5_BUFF ||  m5e1 > Pt_last5 || m5e1>Q5 || m5e1>R5)begin
            IR5_last <= f5+IR5_last+dout_int7;
        end
    end
end

//生成分规则3
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        Pt_last5<=0;
    end
    else if (enps_flag) begin
        if (m5e1 > f5 || m5e1 > Pt_last5 || m5e1>Q5 || m5e1>R5)begin
            Pt_last5 <= f5+dout_int8;
        end
    end
end

//生成分规则4
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        Q5<=Q;
    end
    else if (enps_flag) begin
        if (m5e1 > f5 || m5e1 > Q5)begin
            Q5 <= f5+Q+0*Q5;
        end
        else Q5<=Q5;
    end
end

//生成分规则5
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        R5<=R;
    end
    else if (enps_flag) begin
        if (m5e1 > f5 || m5e1 > R5)begin
            R5 <= f5+R+0*R5;
        end
        else R5<=R5;
    end
end

//生成分规则6
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m5e2 <= 0;
    end
    else if (enps_flag) begin
        if (m5e1 > f5 ||  m5e1 > m5e2)begin
            m5e2 <= 1+f5+0*m5e1+0*m5e2;
        end
        else m5e2 <= 0;
    end
end

//生成分规则7
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m5e1 <= 1;
    end
    else if (enps_flag) begin
        if (m5e2 > f5 ||  m5e2 > m5e1)begin
            m5e1 <= 1+f5+0*m5e1+0*m5e2;
        end
        else m5e1 <= 0;
    end
end
/**********************膜5********************************/

/**********************膜6********************************/
//生成分规则1
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        f6 <= 0;
        IR6_KF<=0;
    end
    else if (enps_flag) begin
        if (m6e1 > f6 || m6e1 > IR6_last ||  m6e1 > IR6_BUFF ||  m6e1 > Pt_last6 || m6e1>Q6 || m6e1>R6)begin
            IR6_KF <= f6+IR6_last+dout_int9;
        end
    end
end

//生成分规则2
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        IR6_last<=0;
    end
    else if (enps_flag) begin
        if (m6e1 > f6 || m6e1 > IR6_last ||  m6e1 > IR6_BUFF ||  m6e1 > Pt_last6 || m6e1>Q6 || m6e1>R6)begin
            IR6_last <= f6+IR6_last+dout_int9;
        end
    end
end

//生成分规则3
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        Pt_last6<=0;
    end
    else if (enps_flag) begin
        if (m6e1 > f6 || m6e1 > Pt_last6 || m6e1>Q6 || m6e1>R6)begin
            Pt_last6 <= f6+dout_int10;
        end
    end
end

//生成分规则4
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        Q6<=Q;
    end
    else if (enps_flag) begin
        if (m6e1 > f6 || m6e1 > Q6)begin
            Q6 <= f6+Q+0*Q6;
        end
        else Q6<=Q6;
    end
end

//生成分规则5
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        R6<=R;
    end
    else if (enps_flag) begin
        if (m6e1 > f6 || m6e1 > R6)begin
            R6 <= f6+R+0*R6;
        end
        else R6<=R6;
    end
end

//生成分规则6
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m6e2 <= 0;
    end
    else if (enps_flag) begin
        if (m6e1 > f6 ||  m6e1 > m6e2)begin
            m6e2 <= 1+f6+0*m6e1+0*m6e2;
        end
        else m6e2 <= 0;
    end
end

//生成分规则7
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m6e1 <= 1;
    end
    else if (enps_flag) begin
        if (m6e2 > f6 ||  m6e2 > m6e1)begin
            m6e1 <= 1+f6+0*m6e1+0*m6e2;
        end
        else m6e1 <= 0;
    end
end
/**********************膜6********************************/

/**********************膜7********************************/
//生成分规则1
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        f7 <= 0;
        IR7_KF<=0;
    end
    else if (enps_flag) begin
        if (m7e1 > f7 || m7e1 > IR7_last ||  m7e1 > IR7_BUFF ||  m7e1 > Pt_last7 || m7e1>Q7 || m7e1>R7)begin
            IR7_KF <= f7+IR7_last+dout_int11;
        end
    end
end

//生成分规则2
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        IR7_last<=0;
    end
    else if (enps_flag) begin
        if (m7e1 > f7 || m7e1 > IR7_last ||  m7e1 > IR7_BUFF ||  m7e1 > Pt_last7 || m7e1>Q7 || m7e1>R7)begin
            IR7_last <= f7+IR7_last+dout_int11;
        end
    end
end

//生成分规则3
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        Pt_last7<=0;
    end
    else if (enps_flag) begin
        if (m7e1 > f7 || m7e1 > Pt_last7 || m7e1>Q7 || m7e1>R7)begin
            Pt_last7 <= f7+dout_int12;
        end
    end
end

//生成分规则4
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        Q7<=Q;
    end
    else if (enps_flag) begin
        if (m7e1 > f7 || m7e1 > Q7)begin
            Q7 <= f7+Q+0*Q7;
        end
        else Q7<=Q7;
    end
end

//生成分规则5
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        R7<=R;
    end
    else if (enps_flag) begin
        if (m7e1 > f7 || m7e1 > R7)begin
            R7 <= f7+R+0*R7;
        end
        else R7<=R7;
    end
end

//生成分规则6
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m7e2 <= 0;
    end
    else if (enps_flag) begin
        if (m7e1 > f7 ||  m7e1 > m7e2)begin
            m7e2 <= 1+f7+0*m7e1+0*m7e2;
        end
        else m7e2 <= 0;
    end
end

//生成分规则7
always @(posedge clk) begin
    if(!rst_n||!launch_flag) begin
        m7e1 <= 1;
    end
    else if (enps_flag) begin
        if (m7e2 > f7 ||  m7e2 > m7e1)begin
            m7e1 <= 1+f7+0*m7e1+0*m7e2;
        end
        else m7e1 <= 0;
    end
end
/**********************膜7********************************/



endmodule
