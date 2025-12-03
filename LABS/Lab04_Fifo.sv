module Fifo(
    // Input signals
	clk, 
	rst_n, 
	write_valid, 
	write_data, 
	read_valid, 
    // Output signals
	write_full, 
	write_success, 
	read_empty, 	
	read_success, 
	read_data
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n;
input write_valid, read_valid; 
input [7:0] write_data;
output logic write_full, write_success, read_empty, read_success;
output logic [7:0] read_data;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [7:0] memory [0:9];
logic [3:0] write_ptr;
logic [3:0] read_ptr;
logic [4:0] count;
logic empty, full;

//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------

    logic [3:0] next_write_ptr;
    logic [3:0] next_read_ptr;
    logic [4:0] next_count;
    logic [7:0] next_read_data;
    logic next_read_success;
    logic next_read_empty;
    logic next_write_success;
    logic next_write_full;
    logic write_enable;
    
    // Combinational logic for next state calculation
    always_comb begin
        // Default next state is current state
        next_write_ptr = write_ptr;
        next_read_ptr = read_ptr;
        next_count = count;
        
        // Calculate empty and full status
        empty = (count == 0);
        full = (count == 10);
        
        // Default output values
        next_read_data = 8'h00;
        next_read_success = 1'b0;
        next_read_empty = 1'b0;
        next_write_success = 1'b0;
        next_write_full = 1'b0;
        write_enable = 1'b0;
        
        // Read logic
        if (read_valid) begin
            if (empty) begin
                // Reading from empty FIFO
                next_read_data = 8'h00;
                next_read_success = 1'b0;
                next_read_empty = 1'b1;
            end
			else begin
                // Successful read
                next_read_data = memory[read_ptr];
                next_read_success = 1'b1;
                next_read_empty = 1'b0;
                
                // Update read pointer
                next_read_ptr = (read_ptr == 9) ? 4'b0000 : read_ptr + 1;
            end
        end
        
        // Write logic
        if (write_valid) begin
            if (full && !(read_valid&&write_valid)) begin
                // Writing to full FIFO
                next_write_success = 1'b0;
                next_write_full = 1'b1;
            end else begin
                // Successful write
                next_write_success = 1'b1;
                next_write_full = 1'b0;
                write_enable = 1'b1;
                
                // Update write pointer
                next_write_ptr = (write_ptr == 9) ? 4'b0000 : write_ptr + 1;
            end
        end
        
        // Update count based on both operations
        if (read_valid && write_valid) begin
            if (!empty && !full) begin
                // Both operations succeed, count stays the same
                next_count = count;
            end else if ((!empty && full) && !(read_valid&&write_valid) ) begin
                // Only read succeeds
                next_count = count - 1;
            end else if (empty && !full) begin
                // Only write succeeds
                next_count = count + 1;
            end
        end 
		else if (read_valid && !empty) begin
            // Only read and it succeeds
            next_count = count - 1;
        end else if (write_valid && !full) begin
            // Only write and it succeeds
            next_count = count + 1;
        end
    end
    
    // Memory write - sequential
    always_ff @(posedge clk) begin
        if (write_enable) begin
            memory[write_ptr] <= write_data;
        end
    end
    
    // Sequential logic for registers
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            write_ptr <= 4'b0000;
            read_ptr <= 4'b0000;
            count <= 5'b00000;
            
            // Reset all outputs
            read_data <= 8'h00;
            read_success <= 1'b0;
            read_empty <= 1'b0;
            write_success <= 1'b0;
            write_full <= 1'b0;
        end else begin
            // Update state registers
            write_ptr <= next_write_ptr;
            read_ptr <= next_read_ptr;
            count <= next_count;
            
            // Update outputs
            read_data <= next_read_data;
            read_success <= next_read_success;
            read_empty <= next_read_empty;
            write_success <= next_write_success;
            write_full <= next_write_full;
        end
    end

endmodule