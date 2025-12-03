module Counter(
    // Input signals
	clk, 
	rst_n, 
	in_valid,  
	in_num,  
    // Output signals
	out_num
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n;
input in_valid; 
input [4:0] in_num;
output logic [4:0] out_num;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [4:0] next1, next2, in_reg;

//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------
always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		in_reg <= '0;
	else
		in_reg <= next1;
end

always@(*) begin
	if(in_valid)
		next1 = in_num;
	else
		next1 = in_reg;
end

always@(*) begin
	if(in_valid)
		next2 = '0;
	else if(in_reg > out_num)
		next2 = out_num + 1;
	else next2 = out_num;
end

always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		out_num <= '0;
	else
		out_num <= next2;
end

endmodule