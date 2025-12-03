module FSM(
	// Input signals
	clk,
	rst_n,
	in_valid,
	op,
    A,
    B,
	// Output signals
    pred_taken,
    state
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [1:0] op;
input [3:0] A, B;
output logic pred_taken;
output logic [1:0] state;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------
logic branch_taken;
logic [1:0] next_state;
logic next_pred_taken;
//---------------------------------------------------------------------
//   YOUR DESIGN                        
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= 0;
        pred_taken <= 0;
    end
    else begin
        if (in_valid) begin
            state <= next_state;
            pred_taken <= next_pred_taken;
        end
    end
end

always_comb begin
    branch_taken = 1'b0;
    case(op)
        2'b00: branch_taken = (A == B); // BEQ
        2'b01: branch_taken = (A != B); // BNE 
        2'b10: branch_taken = (A < B); // BLT
        2'b11: branch_taken = (A >= B); // BGE
    endcase
end

always_comb begin
    next_state = state;
    next_pred_taken = pred_taken;
    
    if (in_valid) begin
        case(state)
            2'b00: begin              
                if (branch_taken) begin
                    next_state = 2'b01;
					next_pred_taken = 0;
				end
				else begin
					next_state = 0;
					next_pred_taken = 0;
				end
            end
            
            2'b01: begin
                if (branch_taken) begin
                    next_state = 2'b11;
					next_pred_taken = 1;
				end
				else begin
					next_state = 2'b00;
					next_pred_taken = 0;
				end
            end
            
            2'b10: begin
                if (branch_taken) begin
                    next_state = 2'b11;
					next_pred_taken = 1;
				end
				else begin
					next_state = 0;
					next_pred_taken = 0;
				end
            end
            
            2'b11: begin
                if (branch_taken) begin
                    next_state = 2'b11;
					next_pred_taken = 1;
				end
				else begin
					next_state = 2'b10;
					next_pred_taken = 1;
				end
			end
        endcase
    end
end



endmodule
