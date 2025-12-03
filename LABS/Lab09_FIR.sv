module FIR(
    // Input signals
    clk,
    rst_n,
    in_valid,
    weight_valid,
    x,
    b0,
    b1,
    b2,
    b3,
    // Output signals
    out_valid,
    y
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid, weight_valid;
input [15:0] x, b0, b1, b2, b3;

output logic out_valid;
output logic [33:0] y;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
typedef enum logic [2:0] { 
    IDLE, IN0, IN1, IN2, IN3, IN4
} state_t;
state_t state, next_state;

logic next_out_valid;
logic [33:0] next_y;
logic [15:0] in, b_0, b_1, b_2, b_3;
logic [33:0] y_0, y_1, y_2, next_y_0, next_y_1, next_y_2;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
        y <= 0;
        state <= IDLE;
        y_0 <= 0;
        y_1 <= 0;
        y_2 <= 0;
    end
    else begin
        out_valid <= next_out_valid;
        y <= next_y;
        state <= next_state;
        if (weight_valid) begin
            b_0 <= b0;
            b_1 <= b1;
            b_2 <= b2;
            b_3 <= b3;
        end
        if(in_valid) 
            in <= x;
        y_0 <= next_y_0;
        y_1 <= next_y_1;
        y_2 <= next_y_2;
    end
end

always_comb begin
    next_state = state;
    next_y_0 = y_0;
    next_y_1 = y_1;
    next_y_2 = y_2;
    next_out_valid = 0;
    next_y = 0;
    case (state)
        IDLE: begin
            if (weight_valid) begin
                next_state = IN0;
            end
        end

        IN0: begin
            next_y_0 = in * b_3;
            next_state = IN1;
        end

        IN1 : begin
            next_y_0 = in * b_3;
            next_y_1 = y_0 + in * b_2;
            next_state = IN2;
        end

        IN2: begin
            next_y_0 = in * b_3;
            next_y_1 = y_0 + in * b_2;
            next_y_2 = y_1 + in * b_1;
            next_state = IN3;
        end

        IN3: begin
            next_y_0 = in * b_3;
            next_y_1 = y_0 + in * b_2;
            next_y_2 = y_1 + in * b_1;
            next_y = y_2 + in * b_0;
            //next_out_valid = 1;
            next_state = IN4;
        end

        IN4: begin
            next_y_0 = in * b_3;
            next_y_1 = y_0 + in * b_2;
            next_y_2 = y_1 + in * b_1;
            next_y = y_2 + in * b_0;
            next_out_valid = 1;
        end
    endcase
end

endmodule