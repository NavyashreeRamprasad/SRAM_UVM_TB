# UVM Verification Environment for a Simple Synchronous Memory

A SystemVerilog/UVM 1.2 testbench that verifies a 256 x 32-bit synchronous memory (`memory.v`). It includes a driver, monitor, scoreboard, functional coverage, SVA protocol assertions, a sequence library and a set of directed tests. The project is set up to run in **Questa/ModelSim** with code and assertion coverage enabled.

---

## 1. Design Under Test

**`memory.v`** is a single-port memory with a valid/ready-style handshake.

| Parameter    | Default | Description        |
|--------------|---------|--------------------|
| `WIDTH`      | 32      | Data width         |
| `DEPTH`      | 256     | Number of words    |
| `ADDR_WIDTH` | 8       | Address width      |

| Port       | Dir    | Description                                  |
|------------|--------|----------------------------------------------|
| `clk_i`    | in     | Clock                                        |
| `rst_i`    | in     | Synchronous reset, active high               |
| `addr_i`   | in     | Address                                      |
| `wdata_i`  | in     | Write data                                   |
| `wr_rd_i`  | in     | `1` = write, `0` = read                      |
| `valid_i`  | in     | Request valid                                |
| `rdata_o`  | out    | Read data                                    |
| `ready_o`  | out    | Asserted when the request is accepted        |

**Behaviour** (evaluated on each `posedge clk_i`):
- `rst_i = 1`: clears `rdata_o`, `ready_o` and the whole memory array to 0.
- `valid_i = 1`: `ready_o` goes to 1. If `wr_rd_i = 1`, `mem[addr_i]` is written with `wdata_i`. Otherwise `rdata_o` is loaded from `mem[addr_i]`.
- `valid_i = 0`: `ready_o` goes to 0.

---

## 2. File Overview

| File             | Purpose |
|------------------|---------|
| `memory.v`       | DUT (Verilog) |
| `mem_intf.sv`    | Interface: signals, `bfm_cb` (driver) and `mon_cb` (monitor) clocking blocks, and 5 SVA assertions. Also defines `WIDTH`, `DEPTH` and `ADDR_WIDTH` macros |
| `mem_tx.sv`      | `mem_tx` sequence item (`addr`, `wdata`, `wr_rd` randomized; `rdata` captured) |
| `mem_drv.sv`     | `mem_drv` driver: drives a transaction and waits for `ready_o` |
| `mem_sqr.sv`     | `mem_sqr` sequencer |
| `mem_mon.sv`     | `mem_mon` monitor: samples a transaction when `valid_i && ready_o` and publishes it on `ap_port` |
| `mem_cov.sv`     | `mem_cov` functional coverage subscriber |
| `mem_agent.sv`   | `mem_agent` containing driver, sequencer, monitor and coverage |
| `mem_scb.sv`     | `mem_scb` scoreboard with an associative-array reference model |
| `mem_env.sv`     | `mem_env` containing the agent and scoreboard |
| `mem_seq_lib.sv` | Base sequence and 5 directed sequences |
| `test_lib.sv`    | Base test and 5 tests, one per sequence |
| `common.sv`      | `common` class holding global settings (`N`) and match/mismatch counters |
| `top.sv`         | Top module: clock/reset generation, DUT instance, `vif` config_db setup, `run_test()` |
| `list.svh`       | Master include file with the compile order |
| `run.do`         | Questa simulation script |
| `coverage.ucdb`  | Coverage database saved from a previous run |

---

## 3. Testbench Architecture

```
                         +--------------------------- mem_env ---------------------------+
                         |                                                               |
   test --> sequence --> |  +----------- mem_agent -----------+      +-- mem_scb --+      |
                         |  | mem_sqr --> mem_drv ---+         |      |             |      |
                         |  |                        |         |      |  assoc-array|      |
                         |  | mem_mon ---ap_port-----+---> mem_cov   |  ref model  |      |
                         |  |    |                   |         |      |             |      |
                         |  +----|-------------------|---------+      +------^------+      |
                         |       +--------------------------------------------+            |
                         +------------------|--------------------------------------------+
                                            v
                              mem_intf (pif)  <---->  memory (DUT)
```

- **Driver**: gets items from the sequencer and drives `addr_i`, `wr_rd_i`, `wdata_i` and `valid_i` through `bfm_cb`. It waits for `ready_o`, captures `rdata_o` on reads, then returns all signals to 0.
- **Monitor**: on every clock where `valid_i && ready_o` is seen, it builds a `mem_tx` and writes it to `ap_port`. The monitor feeds both the coverage subscriber (inside the agent) and the scoreboard (inside the env).
- **Scoreboard**: on a write it stores `asso[addr] = wdata`. On a read it compares `rdata` against `asso[addr]` and increments `common::matching` or `common::mismatching`. `report_phase` prints `testcase passed` or `testcase failed`.
- **Coverage**: `mem_cg` covers `addr` (auto bins, max 4), `wr_rd` (`WRITE`/`READ`) and the cross of the two.

### Assertions (in `mem_intf.sv`)

| Label            | Checks |
|------------------|--------|
| `RD_VA_WR_RD_A`  | When `valid_i` is high, `ready_o` follows and `wr_rd_i` is not X/Z |
| `WRITE_ADDR_A`   | `addr_i` is not X/Z on a write |
| `WRITE_DATA_A`   | `wdata_i` is not X/Z on a write |
| `READ_ADDR_A`    | `addr_i` is not X/Z on a read |
| `READ_DATA_A`    | After a read request, `ready_o` is high and `rdata_o` is not X/Z one cycle later |

All assertions are disabled while `rst_i` is high.

---

## 4. Sequences and Tests

| Test class (`+UVM_TESTNAME`) | Sequence          | Stimulus |
|------------------------------|-------------------|----------|
| `test_1_wr_test`             | `test_1_wr`       | 1 random write |
| `test_5_wr_test`             | `test_5_wr`       | 5 random writes |
| `test_1_wr_1_rd_test`        | `test_1_wr_1_rd`  | 1 write, then a read of the same address |
| `test_5wr_5rd_test`          | `test_5wr_5rd`    | 5 writes, then 5 reads of the written addresses (in order) |
| `test_nwr_nrd_test`          | `test_nwr_nrd`    | `common::N` writes (default 10), then `N` reads of the written addresses |

All sequences extend `mem_base_seq`, which raises and drops an objection in `pre_body`/`post_body` (with a drain time of 100). Each test extends `mem_base_test`, which builds the environment and prints the factory and topology at `end_of_elaboration`.

To change the number of transactions in `test_nwr_nrd`, edit `static int N` in `common.sv`.

---

## 5. Running the Simulation

### Prerequisites
- Questa/ModelSim (the script was written for QuestaSim 10.7c)
- UVM 1.2 source and DPI library

### Configure paths
`run.do` currently contains hard-coded Windows paths. Edit them for your machine:

```
+incdir+C:/Navya/VLSIGURU/UVM/uvm-1.2/src
-sv_lib C:/questasim64_10.7c/uvm-1.2/win64/uvm_dpi
```

### Run
From the project directory in the Questa console:

```
do run.do
```

`run.do` performs these steps:

1. Compiles everything via `list.svh` with `-cover bcesft -assertdebug` (branch, condition, expression, statement, FSM and toggle coverage).
2. Simulates `top` with `+UVM_TESTNAME=test_nwr_nrd_test`.
3. Runs to completion with `run -all`.
4. Saves coverage to `coverage.ucdb`.
5. Prints an assertion coverage report.

### Selecting a different test
Change the `+UVM_TESTNAME` argument in `run.do`, for example:

```
vsim -coverage -assertdebug -novopt -suppress 12110 top +UVM_TESTNAME=test_5wr_5rd_test -sv_lib <path>/uvm_dpi
```

### Viewing coverage
```
vsim -viewcov coverage.ucdb
```
or generate a report with `coverage report -detail`. To see assertions in the waveform, uncomment the `add wave -assertion ...` lines in `run.do`.

---

## 6. Expected Output

A passing run prints:

```
------------testcase passed -----------------
```

The scoreboard reports a pass only when at least one read comparison happened and none mismatched. As a result, **write-only tests (`test_1_wr_test`, `test_5_wr_test`) will print "testcase failed"** because no reads are compared. Use the read tests for pass/fail checking.

---

## 7. Notes and Known Limitations

- **Reset timing**: `top.sv` pulses reset at the start, releases it, then asserts it again for 2 cycles before final release. Stimulus issued during reset will be cleared by the DUT.
- **Coverage binning**: the address coverpoint uses `auto_bin_max = 4`, so the 256-entry address space is split into 4 ranges.
- **Reads of unwritten addresses**: the scoreboard's associative array returns 0 for addresses never written, which matches the DUT's reset value. Reads before a write will therefore pass.
- **Agent phases**: `mem_agent` uses the legacy `build()`/`connect()` function names rather than `build_phase()`/`connect_phase()`. UVM 1.2 maps these, but the newer names are recommended.
- **Agent mode**: the agent has no `is_active` handling, so it is always active.
- **Include of `.v` file**: `list.svh` includes `memory.v` directly, which is fine for this single-tool flow but unusual for larger projects.
- **Global counters**: `common::matching` and `common::mismatching` are static, so they are shared across the entire simulation.

---

## 8. Possible Extensions

- Add a random mixed read/write sequence with address constraints
- Add back-to-back and idle-gap stimulus to exercise the handshake
- Add reset-in-the-middle-of-traffic tests
- Add explicit address-boundary bins (0x00, 0xFF) to coverage
- Add a regression script that runs all five tests and merges the UCDB files
