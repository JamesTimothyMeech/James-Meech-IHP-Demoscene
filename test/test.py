# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
import sys
import cocotb
import struct
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 20
    dut.uio_in.value = 30
    while(True):
        # Wait for one clock cycle to see the output values
        await ClockCycles(dut.clk, 1)
        byte0 = dut.uio_out.value
        byte1 = dut.uo_out.value
        await ClockCycles(dut.clk, 1)
        byte2 = dut.uio_out.value
        byte3 = dut.uo_out.value
        integer = (byte3 << 24) + (byte2 << 16) + (byte1 << 8) +  byte0
        sys.stdout.buffer.write(struct.pack('>I', int(integer)))

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
