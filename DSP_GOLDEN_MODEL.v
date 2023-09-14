module DSP48A1_GOLD #(
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

//Regesters for Pipelining    
reg [17:0] A0_reg, A1_reg, B0_reg, B1_reg, D_reg;
reg [35:0] M_reg;
reg [47:0] C_reg, P_reg;
reg [7:0] opmode_reg;
reg CYO_reg, CYI_reg;

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

//Sequential Part for Regesters
generate if (RSTTYPE == "ASYNC") begin 

//With Asynchronous Reset 
always @(posedge clk or posedge RSTA) begin
    if(RSTA) begin
        A0_reg <= 0;
        A1_reg <= 0;
    end 
    else if (CEA) begin 
        A0_reg <= A;
        A1_reg <= A0_mux;
    end
end

always @(posedge clk or posedge RSTB) begin
    if(RSTB) begin
        B0_reg <= 0;
        B1_reg <= 0;
    end 
    else if (CEB) begin 
        B0_reg <= B_IN; 
        B1_reg <= Pre_adder_mux; 
    end
end

always @(posedge clk or posedge RSTC) begin
    if(RSTC) 
        C_reg <= 0; 
    else if (CEC) 
        C_reg <= C;
end

always @(posedge clk or posedge RSTD) begin
    if(RSTC) 
        D_reg <= 0; 
    else if (CED)
        D_reg <= D;
end

always @(posedge clk or posedge RSTOPMODE) begin
    if(RSTOPMODE) 
        opmode_reg <= 0; 
    else if (CEOPMODE)
        opmode_reg <= OPMODE;
end

always @(posedge clk or posedge RSTM) begin
    if(RSTM) 
        M_reg <= 0; 
    else if (CEM)
        M_reg <= mult_out;
end

always @(posedge clk or posedge RSTP) begin
    if(RSTP) 
        P_reg <= 0; 
    else if (CEP)
        P_reg <= Post_adder_out;
end

always @(posedge clk or posedge RSTCARRYIN) begin
    if(RSTCARRYIN) begin
        CYI_reg <= 0;
        CYO_reg <= 0; 
    end 
    else if (CECARRYIN) begin
        CYI_reg <= Carry_in_Cascade; 
        CYO_reg <= CYO;     
        end
end
end 

else if (RSTTYPE == "SYNC") begin 

//With Synchronous Reset
always @(posedge clk) begin
    if(RSTA) begin
        A0_reg <= 0;
        A1_reg <= 0;
    end 
    else if (CEA) begin 
        A0_reg <= A;
        A1_reg <= A0_mux;
    end
end

always @(posedge clk) begin
    if(RSTB) begin
        B0_reg <= 0;
        B1_reg <= 0;
    end 
    else if (CEB) begin 
        B0_reg <= B_IN; 
        B1_reg <= Pre_adder_mux; 
    end
end

always @(posedge clk) begin
    if(RSTC) 
        C_reg <= 0; 
    else if (CEC) 
        C_reg <= C;
end

always @(posedge clk) begin
    if(RSTD) 
        D_reg <= 0; 
    else if (CED)
        D_reg <= D;
end

always @(posedge clk) begin
    if(RSTOPMODE) 
        opmode_reg <= 0; 
    else if (CEOPMODE)
        opmode_reg <= OPMODE;
end

always @(posedge clk) begin
    if(RSTM) 
        M_reg <= 0; 
    else if (CEM)
        M_reg <= mult_out;
end

always @(posedge clk) begin
    if(RSTP) 
        P_reg <= 0; 
    else if (CEP)
        P_reg <= Post_adder_out;
end

always @(posedge clk) begin
    if(RSTCARRYIN) begin
        CYI_reg <= 0;
        CYO_reg <= 0; 
    end 
    else if (CEOPMODE) begin
        CYI_reg <= Carry_in_Cascade; 
        CYO_reg <= CYO;     
        end
end
end 

endgenerate

//flow of input A
assign A0_mux = (A0REG)? A0_reg : A;
assign A1_mux = (A1REG)? A1_reg : A0_mux;

//flow of input B
assign B_IN = (B_INPUT == "DIRECT")? B : (B_INPUT == "CASCADE")? BCIN : 0 ;
assign B0_mux = (B0REG)? B0_reg : B_IN;
assign Pre_adder_mux = (opmode_mux[4])? Pre_adder_out : B0_mux;
assign B1_mux = (B1REG)? B1_reg : Pre_adder_mux;
assign BCOUT = B1_mux;

//flow of input D
assign D_mux = (DREG)? D_reg : D;

//flow of input C
assign C_mux = (CREG)? C_reg : C;

//flow of input OPMODE
assign opmode_mux = (OPMODEREG)? opmode_reg : OPMODE;

//flow of output M
assign M_mux = (MREG)? M_reg : mult_out;
assign M = M_mux;

//flow of output P
assign P = (PREG)? P_reg : Post_adder_out;
assign PCOUT = P;

//flow of Carry in
assign Carry_in_Cascade = (CARRYINSEL == "OPMODE5")? opmode_mux[5] : (CARRYINSEL == "CARRYIN")? CARRYIN : 0 ;
assign CYI_mux = (CARRYINREG)? CYI_reg : Carry_in_Cascade;

//flow of carry out
assign CARRYOUT = (CARRYOUTREG)? CYO_reg :CYO;
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
