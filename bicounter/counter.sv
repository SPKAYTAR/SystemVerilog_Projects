module Counter(input logic clk, input logic direction, input logic enable, output logic [4:0]count);


initial begin
    count = 0;
end

always_ff @(posedge clk) begin
    if (enable)
        if(direction)
            count <= count + 1;
        else 
            count <= count - 1;
end


endmodule