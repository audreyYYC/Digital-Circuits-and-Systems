module GCD(
    // Input signals
	clk,
	rst_n,
	in_valid,
    in_data,
    // Output signals
    out_valid,
    out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [3:0] in_data;

output logic out_valid;
output logic [4:0] out_data;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
typedef enum logic [1:0] { 
    IDLE, RECEIVE, GCD, OUTPUT
} state_t;
state_t state, next;
logic [2:0] counter, next_counter;
logic [3:0] x, y, next_x, next_y;
logic [4:0] a, b, c, next_a, next_b, next_c, next_out_data;
logic next_out_valid;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        out_valid <= 0;
        out_data <= 0;
    end
    else begin
        state <= next;
        out_valid <= next_out_valid;
        out_data <= next_out_data;
        counter <= next_counter;
        a <= next_a;
        b <= next_b;
        c <= next_c;
        x <= next_x;
        y <= next_y;
    end
end

always_comb begin
    next = state;
    next_counter = counter + 1;
    next_out_valid = 0;
    next_out_data = 0;
    next_a = a;
    next_b = b;
    next_c = c;
    next_x = 0;
    next_y = 0;

    case(state)
    IDLE: begin
        next_a = 0;
        next_b = 0;
        next_c = 0;
        if(in_valid) begin
            next = RECEIVE;
            next_counter = 0;
            next_x = in_data;
        end
    end

    RECEIVE: begin
        next_x = x;
        next_y = y;
        if (!a) begin
            if(x && (x[0] == in_data[0])) begin
                next_a = x + in_data;
                next_x = 0;
            end
            else if(y && (y[0] == in_data[0])) begin
                next_a = y + in_data;
                next_y = 0;
            end
            else if(!x)
                next_x = in_data;
            else
                next_y = in_data;
        end
        else if (!b) begin
            if(x && (x[0] == in_data[0])) begin
                next_b = x + in_data;
                next_x = 0;
            end
            else if(y && (y[0] == in_data[0])) begin
                next_b = y + in_data;
                next_y = 0;
            end
            else if(!x)
                next_x = in_data;
            else
                next_y = in_data;
        end
        else if (!c) begin
            if(x && (x[0] == in_data[0])) begin
                next_c = x + in_data;
                next_x = 0;
            end
            else if(y && (y[0] == in_data[0])) begin
                next_c = y + in_data;
                next_y = 0;
            end
            else if(!x)
                next_x = in_data;
            else
                next_y = in_data;
        end

        if(counter == 3'd5)begin
            if((next_c == a) && (b == a))
                next_counter = 0;
            if (next_c < a) begin
                next_a = next_c;
                next_c = a;
            end
            if(b < next_a) begin
                next_b = next_a;
                next_a = b;
            end
            next = GCD;
        end
    end

    GCD: begin
        if(counter) begin
            next_a = 5'd2;
            case (a)
            5'd4: begin
                if(!b[1] && !c[1])
                    next_a = 5'd4;
            end
            5'd6, 5'd18, 5'd24: begin
                if(!(b % 6) && !(c % 6))
                    next_a = 5'd6;
            end
            5'd8: begin
                if(!b[1] && !c[1])
                    next_a = (!b[2] && !c[2]) ? 5'd8 : 5'd4;
            end
            5'd10: begin
                if(!(b % 10) && !(c % 10))
                    next_a = 5'd10;
            end
            5'd12: begin //2 2 3
                if(!b[1] && !c[1]) // 2 2
                    next_a = !(b % 3) && !(c % 3) ? 5'd12 : 5'd4;
                else if(!(b % 3) && !(c % 3))
                    next_a = 5'd6;
            end
            5'd14: begin
                if((b == 5'd14 || b == 5'd28) && c == 5'd28)
                    next_a = 5'd14;
            end
            5'd16: begin //2 2 2 2
                if(!b[1] && !c[1]) // 2 2
                    next_a = (!b[2] && !c[2]) ? 5'd8 : 5'd4;
            end
            5'd20: begin // 2 2 5
                if((b == 5'd20 || b == 5'd30) && c == 5'd30)
                    next_a = 5'd10;
                else if (!b[1] && !c[1])
                    next_a = 5'd4;
            end
            5'd24: begin // 2 2 2 3 //4 6
                if(!b[1] && !c[1])
                    next_a = 5'd4;
            end
            endcase
        end
        next = OUTPUT;
        next_out_valid = 1;
        next_out_data = a;
        next_counter = 7;
    end

    OUTPUT: begin
        next_out_valid = 1;
        case (counter)
            7:  next_out_data = b;
            0:  next_out_data = c;
            1: begin
                next_out_data = a;
                next = IDLE;
            end
        endcase
    end
    endcase
end
endmodule