`timescale  1ns / 1ns

module kfenps_tb;

// enps Parameters
parameter PERIOD = 10 ;
parameter Q  = 50;
parameter R  = 10 ;

// enps Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   enps_en                              = 0 ;
reg   [15:0]  IR0                          = 0 ;
reg   [15:0]  IR1                          = 0 ;
reg   [15:0]  IR2                          = 0 ;
reg   [15:0]  IR5                          = 0 ;
reg   [15:0]  IR6                          = 0 ;
reg   [15:0]  IR7                          = 0 ;
reg   launch_flag                          = 0 ;

// enps Outputs
wire  [15:0]  leftspeed                    ;
wire  [15:0]  rightspeed                   ;
wire  enps_done                            ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

kfenps #(
    .Q ( Q ),
    .R ( R ))
 u_kfenps (
    .clk                     ( clk                 ),
    .rst_n                   ( rst_n               ),
    .enps_en                 ( enps_en             ),
    .IR0                     ( IR0          [15:0] ),
    .IR1                     ( IR1          [15:0] ),
    .IR2                     ( IR2          [15:0] ),
    .IR5                     ( IR5          [15:0] ),
    .IR6                     ( IR6          [15:0] ),
    .IR7                     ( IR7          [15:0] ),
    .launch_flag             ( launch_flag         ),

    .leftspeed               ( leftspeed    [15:0] ),
    .rightspeed              ( rightspeed   [15:0] ),
    .enps_done               ( enps_done           )
);

initial
begin
    #(PERIOD*10)
        launch_flag=1;
    #(PERIOD*10) enps_en=1;
		IR0 = 16'd12;
		IR1 = 16'd100;
		IR2 = 16'd7;
		IR5 = 16'd8;
		IR6 = 16'd5;
		IR7 = 16'd6;
	#(PERIOD*1)enps_en=0;
		IR0 = 16'd0;
		IR1 = 16'd0;
		IR2 = 16'd0;
		IR5 = 16'd0;
		IR6 = 16'd0;
		IR7 = 16'd0;
		
        #(PERIOD*50) enps_en=1;
		IR0 = 16'd35;
		IR1 = 16'd150;
		IR2 = 16'd20;
		IR5 = 16'd5;
		IR6 = 16'd6;
		IR7 = 16'd4;
	#(PERIOD*1)enps_en=0;
		IR0 = 16'd0;
		IR1 = 16'd0;
		IR2 = 16'd0;
		IR5 = 16'd0;
		IR6 = 16'd0;
		IR7 = 16'd0;
		
//		  #(PERIOD*5) enps_en=1;
//		IR0 = 16'd10;
//		IR1 = 16'd50;
//		IR2 = 16'd20;
//		IR5 = 16'd50;
//		IR6 = 16'd60;
//		IR7 = 16'd70;
//	#(PERIOD*1)enps_en=0;
//		IR0 = 16'd0;
//		IR1 = 16'd0;
//		IR2 = 16'd0;
//		IR5 = 16'd0;
//		IR6 = 16'd0;
//		IR7 = 16'd0;
    $stop;
end

endmodule
