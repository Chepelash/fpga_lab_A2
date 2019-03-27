module serializer_tb;

parameter int CLK_T = 1000;
parameter int WIDTH = 16;

logic                     clk;
logic                     rst;

logic [WIDTH-1:0]         data_i;
logic [$clog2(WIDTH)-1:0] data_mod_i;
logic                     data_val_i;

logic                     ser_data_o;
logic                     ser_data_val_o;
logic                     busy_o;


bit   [WIDTH-1:0]         input_values[$];    
bit   [WIDTH-1:0]         output_values[$];
int                       cntr;

task automatic clk_gen;

  forever
    begin
      # ( CLK_T / 2 );
      clk <= ~clk;
    end
  
endtask


task automatic apply_rst;
  
  rst <= 1'b1;
  @( posedge clk );
  rst <= 1'b0;
  @( posedge clk );

endtask


task automatic apply_valid_input;

  data_val_i <= 1'b1;
  @( posedge clk );
  data_val_i <= 1'b0;
  @( posedge clk );

endtask



task automatic wait_for_data;
  @( negedge busy_o );
  
endtask


task automatic init_queue_values;

  for( int i = 3; i < WIDTH; i++ )
    begin
      for( bit [WIDTH-1:0] j = 0; j < 2**i; j++ )
        begin
          input_values.push_back({<<{j}});
        end
    end
  output_values = input_values;
endtask


task automatic checking_output;
  int cntr;
  bit [WIDTH-1:0] cur_value;

  for( int i = 3; i < WIDTH; i++ )
    begin
      for( int j = 0; i < 2**i; j++ )
        begin
          @( posedge ser_data_val_o );
          
          cur_value = output_values.pop_front();          
          for( int k = ( WIDTH - 1 ); k > ( WIDTH - 1 - i ); k-- )
            begin              
              @( negedge clk );
              if( cur_value[k] == ser_data_o )
                begin    
                  if( !(cntr++ % 100) )
                    $write(" . ");
                end
              else
                begin
                  $display("Fail! Cur_value = %16b", cur_value);
                  $stop();
                end
            end
        end        
    end 


endtask


task automatic send_values;

  bit [WIDTH-1:0] cur_value;
  for( int i = 3; i < WIDTH; i++ )
    begin
      for( int j = 0; j < 2**i; j++ )
        begin
          cur_value   = input_values.pop_front();          
          data_i     <= cur_value;
          data_mod_i <= i;
          apply_valid_input();
          data_i     <= '0;
          data_mod_i <= '0;
          @( negedge busy_o );
          @( posedge clk );
        end
    end

endtask



serializer       #(
  .WIDTH          ( WIDTH          )
) serializer_1    (
  .clk_i          ( clk            ),
  .srst_i         ( rst            ),
  
  .data_i         ( data_i         ),
  .data_mod_i     ( data_mod_i     ),
  .data_val_i     ( data_val_i     ),
  
  .ser_data_o     ( ser_data_o     ),
  .ser_data_val_o ( ser_data_val_o ),
  .busy_o         ( busy_o         )
);



initial
  begin
    init_queue_values();
    
    clk <= 0;
    rst <= 0;
    
    fork
      clk_gen();
    join_none
    
    $display("Starting!\n");
    
    apply_rst();
    $display("Testing inputs and outputs!");
    $display("--------------------------------");
    
    fork 
      checking_output();
    join_none
    
    fork      
      send_values();  
    join 

    $display("\n--------------------------------");
    $display("\nEveryting is fine!");
    $stop();
    
  end


endmodule
