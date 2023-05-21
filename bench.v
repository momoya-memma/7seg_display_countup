`timescale 1ns/1ps

module sim_result;/*このモジュール名がsim実行結果のファイル名になる。*/
  reg clk ;/*テストベンチ内で使用するレジスタを宣言する*/
  reg ck_rst;
  wire [3:0] ja;
  wire [3:0] jb;

  parameter STEP = 100;/*period 1000ns=1usec*/
  //parameter ONE_SEC = 1000000000;/*1sec*/
  parameter CYC = 10;/*10ns = 100MHz*/
  parameter ONE_SEC = CYC*1000;/*1sec*/

  always #(CYC/2) clk=~clk;

  top_module test_module ( /*sim対象のモジュールをdutという名前でインスタンス化*/
    .CLK100MHZ (clk)/*モジュールのポートCLK100MHZに（）の中身の値を対応づける*/
    , .ck_rst (ck_rst)
    , .ja (ja)
    , .jb (jb)
  );

  initial begin
    $dumpfile("sim_result.vcd"); // vcd file name
    $dumpvars(0,sim_result);     // dump targetは「全部」

    // Initilai value
    #(CYC* 0)   clk=0;ck_rst=0;

    // Set seed
    #(ONE_SEC*1)   ck_rst=1'b1;   //



    // Stop simulation
    #(ONE_SEC*180)   $finish;
  end
  
endmodule
