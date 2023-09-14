module DSP48A1 #(
    parameter A0REG = 0,
              A1REG = 1, 
              B0REG = 0,
              B1REG = 1,
              CREG = 1, 
              DREG = 1, 
              MREG = 1,
              PREG = 1, 
              CARRYINREG = 1, 
              CARRYOUTREG = 1, 
              OPMODEREG = 1,
              CARRYINSEL = "OPMODE5",
              B_INPUT = "DIRECT",
              RSTTYPE = "SYNC"

) (
    input [17:0] A, B, D, BCIN,
    input [47:0] C, PCIN,
    input [7:0] OPMODE,
    input clk, CARRYIN,
    input RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE,
    input CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE,
    output [17:0] BCOUT,
    output [47:0] PCOUT, P,
    output [35:0] M,
    output CARRYOUT, CARRYOUTF
);
    
//Multiplexers outputs
wire [17:0] A0_mux, A1_mux, B0_mux, B1_mux, D_mux, B_IN, Pre_adder_mux;
wire [35:0] M_mux;
wire [47:0] C_mux;
wire [7:0] opmode_mux;
wire CYI_mux, Carry_in_Cascade;
reg [47:0] x_mux, z_mux;

//Arithmetic Outputs
wire [17:0] Pre_adder_out;
wire [35:0] mult_out;
wire [47:0] Post_adder_out;
wire CYO;

//Instantiation of Register_multeplexer pairs 
reg_mux_pair #(18, A0REG, RSTTYPE)      A0reg (A, RSTA, CEA, clk, A0_mux);
reg_mux_pair #(18, A1REG, RSTTYPE)      A1reg (A0_mux, RSTA, CEA, clk, A1_mux);
reg_mux_pair #(18, B0REG, RSTTYPE)      B0reg (B_IN, RSTB, CEB, clk, B0_mux);
reg_mux_pair #(18, B1REG, RSTTYPE)      B1reg (Pre_adder_mux, RSTB, CEB, clk, B1_mux);
reg_mux_pair #(48, CREG, RSTTYPE)       Creg (C, RSTC, CEC, clk, C_mux);
reg_mux_pair #(18, DREG, RSTTYPE)       Dreg (D, RSTD, CED, clk, D_mux);
reg_mux_pair #(8, OPMODEREG, RSTTYPE)   OPMODEreg (OPMODE, RSTOPMODE, CEOPMODE, clk, opmode_mux);
reg_mux_pair #(36, MREG, RSTTYPE)       Mreg (mult_out, RSTM, CEM, clk, M_mux);
reg_mux_pair #(48, PREG, RSTTYPE)       Preg (Post_adder_out, RSTP, CEP, clk, P);
reg_mux_pair #(1, CARRYINREG, RSTTYPE)  CYOreg (Carry_in_Cascade, RSTCARRYIN, CECARRYIN, clk, CYI_mux);
reg_mux_pair #(1, CARRYOUTREG, RSTTYPE) CYIreg (CYO, RSTCARRYIN, CECARRYIN, clk, CARRYOUT);


// flow in input B
assign B_IN = (B_INPUT == "DIRECT")? B : (B_INPUT == "CASCADE")? BCIN : 0 ;
assign Pre_adder_mux = (opmode_mux[4])? Pre_adder_out : B0_mux;
assign BCOUT = B1_mux;

//buffering output M
assign M = M_mux;

//buffering output PCOUT
assign PCOUT = P;

//flow of carry in
assign Carry_in_Cascade = (CARRYINSEL == "OPMODE5")? opmode_mux[5] : (CARRYINSEL == "CARRYIN")? CARRYIN : 0 ;

//buffering output CARRYOUTF
assign CARRYOUTF = CARRYOUT;

//Arithmetic Operations
assign Pre_adder_out = (opmode_mux[6])? (D_mux - B0_mux) : (D_mux + B0_mux) ;
assign mult_out = A1_mux * B1_mux;
assign {CYO, Post_adder_out} = (opmode_mux[7])? (z_mux - (x_mux + CYI_mux)) : (z_mux + x_mux + CYI_mux) ;

//X & Z multiplexers 
always @(*) begin

    case (opmode_mux[1:0])
      2'b00 : x_mux = 0;
      2'b01 : x_mux = {{12{M_mux[35]}}, M_mux} ;
      2'b10 : x_mux = P;   //may cause compinational loop
      2'b11 : x_mux = {D_mux[11:0], A1_mux[17:0], B1_mux[17:0]};
    endcase
    

    case (opmode_mux[3:2])
       2'b00 : z_mux = 0;
       2'b01 : z_mux = PCIN;
       2'b10 : z_mux = P;   //may cause compinational loop
       2'b11 : z_mux = C_mux;
    endcase
end


endmodule
