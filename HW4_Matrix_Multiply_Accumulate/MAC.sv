module MAC(
	// Input signals
	clk,
	rst_n,
	in_valid,
	in_mode,
	in_act,
	in_wgt,
	// Output signals
	out_act_idx,
	out_wgt_idx,
	out_idx,
    out_valid,
	out_data,
	out_finish
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid, in_mode;
input [0:7][3:0] in_act;
input [0:8][3:0] in_wgt;
output logic [3:0] out_act_idx, out_wgt_idx, out_idx;
output logic out_valid, out_finish;
output logic [0:7][11:0] out_data;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------
typedef enum logic [2:0] { 
	IDLE, WINDOW, ACT_1, ACT_2, PROCESS_ROW, OUTPUT_ROW
} state_t;
state_t state;

logic operation_mode;
logic [2:0] curr_row, counter;
logic [0:7][3:0] act_window_buffer[0:2];
logic [0:2][0:2][3:0] conv_wgt;      // 3x3 conv weights
logic [11:0] sum;
//---------------------------------------------------------------------
//   YOUR DESIGN                        
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_valid <= 0;
		out_finish <= 0;
		out_idx <= 0;
	end
	else begin
		if (state == OUTPUT_ROW) begin
			out_valid <= 1;
			out_idx <= {1'b0, curr_row};
			out_finish <= (curr_row == 7);
		end
		else begin
			out_valid <= 0;
			out_finish <= 0;
			out_idx <= 0;
		end
	end
end
    
always_comb begin
	out_act_idx = 0;
	out_wgt_idx = 0;
	if (operation_mode == 0) begin
		out_act_idx = {1'b0, curr_row};
		out_wgt_idx = {1'b1, counter};
	end
	else if (state == WINDOW) 
		out_act_idx = {1'b0, curr_row};
	else
		out_act_idx = {1'b0, curr_row + 1};
end

// Main state machine
always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		state <= IDLE;
		curr_row <= 0;
		counter <= 0;
		operation_mode <= 0;
		out_data <= 0;
	end
	else begin
		case (state)
		IDLE: begin
			if (in_valid) begin
				if(in_mode == 0)
					state <= PROCESS_ROW;
				else
					state <= WINDOW;
				operation_mode <= in_mode;
				counter <= 0;
				curr_row <= 0;
			end
		end
		
		WINDOW: begin  // Convolution
            act_window_buffer[1] <= in_act;
            conv_wgt[0][0] <= in_wgt[0];
            conv_wgt[0][1] <= in_wgt[1];
            conv_wgt[0][2] <= in_wgt[2];
            conv_wgt[1][0] <= in_wgt[3];
            conv_wgt[1][1] <= in_wgt[4];
            conv_wgt[1][2] <= in_wgt[5];
            conv_wgt[2][0] <= in_wgt[6];
            conv_wgt[2][1] <= in_wgt[7];
            conv_wgt[2][2] <= in_wgt[8];
            state <= ACT_1;
        end

        ACT_1: begin
            act_window_buffer[0] <= 0;
            act_window_buffer[2] <= in_act;
            state <= PROCESS_ROW;
        end

        ACT_2: begin
			if (curr_row == 7) begin
				act_window_buffer[0] <= act_window_buffer[1];
				act_window_buffer[1] <= act_window_buffer[2];
				act_window_buffer[2] <= 0;
				state <= PROCESS_ROW;
			end
			else begin
				act_window_buffer[0] <= act_window_buffer[1];
				act_window_buffer[1] <= act_window_buffer[2];
				act_window_buffer[2] <= in_act;
				state <= PROCESS_ROW;
			end
        end

		
		PROCESS_ROW: begin
			if (operation_mode == 0) begin  // Matrix multiplication
				sum = 0;
				for (int k = 0; k < 8; k++) 
					sum = sum + in_act[k] * in_wgt[k];
				out_data[counter] <= sum;
				if (counter == 7) begin
					counter <= 0;
					state <= OUTPUT_ROW;
				end 
				else 
					counter <= counter + 1;
			end
			else begin
				sum = 0;
				for (int m = 0; m < 3; m++) begin
					for (int n = 0; n < 3; n++) begin
						logic [3:0] act_val;
						int col_idx;
						col_idx = counter + n - 1;
						if (col_idx < 0 || col_idx > 7) 
							act_val = 0;
						else 
							act_val = act_window_buffer[m][col_idx];
						sum = sum + act_val * conv_wgt[m][n];
					end
				end
				out_data[counter] <= sum;
				if (counter == 7) begin
					counter <= 0;
					state <= OUTPUT_ROW;
				end 
				else 
					counter <= counter + 1;
			end
		end
		
		OUTPUT_ROW: begin
			if (curr_row == 7) 
				state <= IDLE;
			else if (operation_mode == 0) begin
				curr_row <= curr_row + 1;
				state <= PROCESS_ROW;
			end
			else begin
				curr_row <= curr_row + 1;
				state <= ACT_2;
			end
		end
		endcase
	end
end
endmodule