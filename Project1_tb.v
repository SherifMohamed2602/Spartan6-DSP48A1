`timescale 1ns/1ns
module DSP48A1_tb ();

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
          RSTTYPE = "SYNC";

parameter CLK_PERIOD = 10;

reg [17:0] A, B, D, BCIN;
reg [47:0] C, PCIN;
reg [7:0] OPMODE;
reg clk, CARRYIN;
reg RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE;
reg CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE;
wire [17:0] BCOUT, BCOUT_GOLD;
wire [47:0] PCOUT, P, PCOUT_GOLD, P_GOLD;
wire [35:0] M, M_GOLD;
wire CARRYOUT, CARRYOUTF, CARRYOUT_GOLD, CARRYOUTF_GOLD;
DSP48A1 #(A0REG, A1REG, B0REG, B1REG, CREG, DREG, MREG, PREG, CARRYINREG, CARRYOUTREG, OPMODEREG, CARRYINSEL, B_INPUT, RSTTYPE) dut(A, B, D, BCIN, C, PCIN, OPMODE, clk, CARRYIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE, CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE, BCOUT, PCOUT, P, M, CARRYOUT, CARRYOUTF);
DSP48A1_GOLD #(A0REG, A1REG, B0REG, B1REG, CREG, DREG, MREG, PREG, CARRYINREG, CARRYOUTREG, OPMODEREG, CARRYINSEL, B_INPUT, RSTTYPE) GOLD(A, B, D, BCIN, C, PCIN, OPMODE, clk, CARRYIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE, CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE, BCOUT_GOLD, PCOUT_GOLD, P_GOLD, M_GOLD, CARRYOUT_GOLD, CARRYOUTF_GOLD);


always #(CLK_PERIOD/2) clk = ~clk;

reg [47:0] P_old;
reg [47:0] M_extend;


initial begin
    clk = 0;
    {RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE} = 8'b1111_1111;
    {A, B, D, BCIN, C, PCIN, OPMODE, CARRYIN} = 0;
    {CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE} = 0;

    #(CLK_PERIOD);
    {RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE} = 0;
    {CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE} = 8'b1111_1111;

$display ("TEST CASE 1 : normal adder, multiplier, adder operation ");

    OPMODE = 8'b0_0_1_1_11_01;
    repeat (10) begin
        A = $urandom_range(0, 100);
        B = $urandom_range(0, 100);
        D = $urandom_range(0, 100);
        C = $urandom_range(0, 100);
        BCIN = $urandom_range(0, 100);
        PCIN = $urandom_range(0, 100);
        #(CLK_PERIOD*2)
        if (BCOUT == BCOUT_GOLD && BCOUT == (D + B))
            $display ("no error");
        else 
            $display ("error occured");
        #(CLK_PERIOD)
        if (M == M_GOLD && M == (BCOUT * A))
            $display ("no error");
        else 
            $display ("error occured");
        #(CLK_PERIOD)
        if (P == P_GOLD && PCOUT == PCOUT_GOLD && P == (M + C + OPMODE[5]))
            $display ("no error");
        else 
            $display ("error occured");    
    end

$display ("TEST CASE 2 : normal adder, multiplier, adder operation with random range and cout check ");

    OPMODE = 8'b0_0_1_1_11_01;
    repeat (10) begin
        A = $random;
        B = $random;
        D = $random;
        C = $random;
        BCIN = $random;
        PCIN = $random;
        #(CLK_PERIOD*2)
        if (BCOUT == BCOUT_GOLD && BCOUT == (D + B))
            $display ("no error");
        else 
            $display ("error occured");
        #(CLK_PERIOD)
        if (M == M_GOLD && M == (BCOUT * A))
            $display ("no error");
        else 
            $display ("error occured");
        M_extend =  {{12{M[35]}}, M};
        #(CLK_PERIOD)
        if (P == P_GOLD && PCOUT == PCOUT_GOLD && CARRYOUT == CARRYOUT_GOLD && CARRYOUTF == CARRYOUTF_GOLD && {CARRYOUT, P} == (M_extend + C + OPMODE[5]))
            $display ("no error");
        else 
            $display ("error occured, (M + C + OPMODE[5]) = %d" ,(M_extend + C + OPMODE[5]));    
    end



$display ("TEST CASE 3 : normal sub, multiplier, sub operation ");

    OPMODE = 8'b1_1_1_1_11_01;
    repeat (10) begin
        A = $urandom_range(0, 100);
        B = $urandom_range(0, 100);
        D = $urandom_range(0, 100);
        C = $urandom_range(0, 100);
        BCIN = $urandom_range(0, 100);
        PCIN = $urandom_range(0, 100);
        #(CLK_PERIOD*2)
        if (BCOUT == BCOUT_GOLD && BCOUT == (D - B))
            $display ("no error");
        else 
            $display ("error occured");
        #(CLK_PERIOD)
        if (M == M_GOLD && M == (BCOUT * A))
            $display ("no error");
        else 
            $display ("error occured");
        #(CLK_PERIOD)
        if (P == P_GOLD && PCOUT == PCOUT_GOLD && P == (C - (M + OPMODE[5])))
            $display ("no error");
        else 
            $display ("error occured");    
    end

$display ("TEST CASE 4 : bypass, multiplier, add operation ");

    OPMODE = 8'b0_0_1_0_11_01;
    repeat (10) begin
        A = $urandom_range(0, 100);
        B = $urandom_range(0, 100);
        D = $urandom_range(0, 100);
        C = $urandom_range(0, 100);
        BCIN = $urandom_range(0, 100);
        PCIN = $urandom_range(0, 100);
        #(CLK_PERIOD*2)
        if (BCOUT == BCOUT_GOLD && BCOUT == (B))
            $display ("no error");
        else 
            $display ("error occured");
        #(CLK_PERIOD)
        if (M == M_GOLD && M == (B * A))
            $display ("no error");
        else 
            $display ("error occured");
        #(CLK_PERIOD)
        if (P == P_GOLD && PCOUT == PCOUT_GOLD && P == (C + (M + OPMODE[5])))
            $display ("no error");
        else 
            $display ("error occured");    
    end

$display ("TEST CASE 5: Concatenated addition with C operation ");

    OPMODE = 8'b0_0_1_0_11_11;
    repeat (10) begin
        A = $urandom_range(0, 100);
        B = $urandom_range(0, 100);
        D = $urandom_range(0, 100);
        C = $urandom_range(0, 100);
        BCIN = $urandom_range(0, 100);
        PCIN = $urandom_range(0, 100);
        #(CLK_PERIOD*4)
        if (P == P_GOLD && PCOUT == PCOUT_GOLD && P == (C + {D[11:0], A[17:0], B[17:0]} + OPMODE[5]))
            $display ("no error");
        else 
            $display ("error occured");    
    end

$display ("TEST CASE 6: Accumulator addition with PCIN operation ");

    OPMODE = 8'b0_0_1_0_01_10;
    repeat (10) begin
        A = $urandom_range(0, 100);
        B = $urandom_range(0, 100);
        D = $urandom_range(0, 100);
        C = $urandom_range(0, 100);
        BCIN = $urandom_range(0, 100);
        PCIN = $urandom_range(0, 100);
        #(CLK_PERIOD)
        P_old = P;
        #(CLK_PERIOD)
        if (P == P_GOLD && PCOUT == PCOUT_GOLD && P == (PCIN + P_old + OPMODE[5]))
            $display ("no error");
        else 
            $display ("error occured");    
    end

$display ("TEST CASE 7: random operations with golden model");


    repeat (10) begin
        A = $urandom_range(0, 100);
        B = $urandom_range(0, 100);
        D = $urandom_range(0, 100);
        C = $urandom_range(0, 100);
        BCIN = $urandom_range(0, 100);
        PCIN = $urandom_range(0, 100);
        OPMODE = $random;
        #(CLK_PERIOD*2)
        if (BCOUT == BCOUT_GOLD )
            $display ("no error");
        else 
            $display ("error occured");
        #(CLK_PERIOD)
        if (M == M_GOLD)
            $display ("no error");
        else 
            $display ("error occured");
        #(CLK_PERIOD)
        if (P == P_GOLD && PCOUT == PCOUT_GOLD)
            $display ("no error");
        else 
            $display ("error occured");    
    end
$stop;


end

initial
     $monitor("A = %d, B = %d, C = %d, D = %d, opmode = %b, BCIN = %d, PCIN = %d, M = %d, P = %d ", A, B, C, D, OPMODE, BCIN, PCIN, M, P );
    
endmodule