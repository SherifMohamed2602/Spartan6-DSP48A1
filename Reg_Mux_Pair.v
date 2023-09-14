module reg_mux_pair #(
    parameter DATA_WIDTH = 18,
              REG = 1,
              RSTTYPE = "SYNC"
) (
    input [DATA_WIDTH - 1 : 0] data, 
    input rst, CE, clk,
    output [DATA_WIDTH - 1 : 0] mux_out
);

reg [DATA_WIDTH - 1 : 0] Reg;

generate if (RSTTYPE == "ASYNC") begin 

always @(posedge clk or posedge rst) begin
    if(rst) begin
        Reg <= 0;
    end 
    else if (CE) begin 
        Reg <= data;
    end
end

end else if (RSTTYPE == "SYNC") begin 

    always @(posedge clk) begin
    if(rst) begin
        Reg <= 0;
    end 
    else if (CE) begin 
        Reg <= data;
    end
end
end

endgenerate

assign mux_out = (REG)? Reg : data;
    
endmodule

