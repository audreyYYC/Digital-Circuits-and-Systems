module SPMV(
    clk, 
	rst_n, 
	// input 
	in_valid, 
	weight_valid, 
	in_row, 
	in_col, 
	in_data, 
	// output
	out_valid, 
	out_row, 
	out_data, 
	out_finish
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n; 
// input
input in_valid, weight_valid; 
input [4:0] in_row, in_col; 
input [7:0] in_data; 
// output 
output logic out_valid; 
output logic [4:0] out_row; 
output logic [20:0] out_data; 
output logic out_finish; 

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
typedef enum logic { IDLE = 0, PROCESS = 1 } state_t;
state_t state, next_state;
logic next_out_finish, next_out_valid;
logic [4:0] next_out_row;
logic [20:0] next_out_data;
logic [31:0] [7:0] invector, next_invector;
logic [31:0] [20:0] outvector, next_outvector;
logic [5:0] count, next_count;
logic [15:0] product, next_product;
logic [4:0] product_row, next_product_row;
logic flag, next_flag;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
		out_valid <= 0;
		out_row <= 0;
		out_data <= 0;
		out_finish <= 0;
	end
	else begin
		state <= next_state;
		out_valid <= next_out_valid;
		out_row <= next_out_row;
		out_data <= next_out_data;
		out_finish <= next_out_finish;
		count <= next_count;
		outvector <= next_outvector;
		invector <= next_invector;
		product <= next_product;
		product_row <= next_product_row;
		flag <= next_flag;
		if(in_valid)
			invector[in_row] <= in_data;	
		if(weight_valid && invector[in_col] != 0 && in_data != 0) 
			product <= invector[in_col] * in_data;
		if(flag)
			outvector[product_row] <= outvector[product_row] + product;
	end
end

always_comb begin
	next_state = state;
	next_out_valid = 0;
	next_out_row = 0;
	next_out_data = 0;
	next_out_finish = 0;
	next_count = count;
	next_outvector = outvector;
	next_invector = invector;
	next_product = 0;
	next_product_row = 0;
	next_flag = 0;

	case (state)
	IDLE: begin
		next_outvector = 0;
		next_invector = 0;
		next_count = 0;
		if(in_valid) 
			next_state = PROCESS;
	end

	PROCESS: begin
		if (in_valid) begin end

		else if(weight_valid) begin
			if(invector[in_col] != 0 && in_data != 0) begin
				if(outvector[in_row] == 0 && !(product_row == in_row && flag))
					next_count = count + 1;
				next_product_row = in_row;
				next_flag = 1;
			end
		end
		else if(count == 0) begin
			next_out_valid = 1;
			next_out_finish = 1;
			next_state = IDLE;
		end
		else if (count == 1) begin
			next_out_valid = 1;
			next_out_finish = 1;
			next_state = IDLE;
			for(int i = 0; i < 32; i++) begin
				if (outvector[i] != 0) begin
					next_out_row = i;
					next_out_data = outvector[i];
					break;
				end
			end
		end
		else begin
			next_out_valid = 1;
			next_count = count - 1;
			for(int i = 0; i < 32; i++) begin
				if (outvector[i] != 0) begin
					next_out_row = i;
					next_out_data = outvector[i];
					next_outvector[i] = 0;
					break;
				end
			end
		end
	end
	endcase
end

endmodule