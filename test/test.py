# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.binary import BinaryValue


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
    await ClockCycles(dut.clk, 10)

    dut._log.info("Test project behavior")

    # Check bit zero of input can go high on its own
    assert dut.uo_out.value == 0
    dut.ui_in[0].value = 1
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == BinaryValue("00000001")
    dut.ui_in[0].value = 0
    await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value == 0
    dut.ui_in[1].value = 1
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == BinaryValue("00000010")
    dut.ui_in[1].value = 0
    await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value == 0
    dut.ui_in[2].value = 1
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == BinaryValue("00000100")
    dut.ui_in[2].value = 0
    await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value == 0
    dut.ui_in[3].value = 1
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == BinaryValue("00001000")
    dut.ui_in[3].value = 0
    await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value == 0
    dut.ui_in[4].value = 1
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == BinaryValue("00010000")
    dut.ui_in[4].value = 0
    await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value == 0
    dut.ui_in[5].value = 1
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == BinaryValue("00100000")
    dut.ui_in[5].value = 0
    await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value == 0
    dut.ui_in[6].value = 1
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == BinaryValue("01000000")
    dut.ui_in[6].value = 0
    await ClockCycles(dut.clk, 1)

    assert dut.uo_out.value == 0
    dut.ui_in[7].value = 1
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == BinaryValue("10000000")
    dut.ui_in[7].value = 0
    await ClockCycles(dut.clk, 1)
