
module shift_reg_4(
    input logic clk,
    input logic enable,
    input logic serial_in,
    input logic reset,
    output logic [3:0] q
);

always_ff @(posedge clk ) begin  // takes tadat fro mthe elft
    if(reset)
        q <= 4'b0000;
    else if(enable)
        q<={serial_in, q[3:1]};
end


endmodule