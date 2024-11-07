function MCP47FEB01_Set_DAC_Volatile_Value(mcp::MCP2221Interface, code::Int)
    
    if(code < 0 || code > 255)
		error("DAC Value must be 8 bit (0-255).")
	end

    cmd = UInt8[0x00,0x90, 0x04, 0x00, 0xC0, 0x00, 0x00, code]
    res = HidApi.hid_write(mcp.device, cmd, 65)
    if res < 0
        error("Failed to hid write command (error #01)")
    end
    
    response = Vector{UInt8}(undef, 64)
    res2 = HidApi.hid_read_timeout(mcp.device, response, 65, 1000)  # Read with a timeout of 1000 ms
    
    if res2 < 0
        error("Failed to hid read timeout command (error #02)")
    end
    
    if (response[1] != 0x90 || response[2] != 0x00)
		error("I2C Write communication error between MCP2221 and MCP47FEB01 (err #03).")
	end

    #@printf "code: %d, response[1] = %x\n" code response[1]
    #@printf "code: %d, response[2] = %x\n" code response[2]
end

function MCP47FEB01_Get_DAC_Volatile_Value(mcp::MCP2221Interface)
    
	# Write (x90) 2 bytes to C0 address
    cmd = UInt8[0x00,0x90, 0x02, 0x00, 0xC0,0x06,0xC1]
	res = HidApi.hid_write(mcp.device, cmd, 65)
	if res < 0
		error("Failed to hid write command (error #01)")
	end

	response = Vector{UInt8}(undef, 64)
	res2 = HidApi.hid_read_timeout(mcp.device, response, 65, 5000)  # Read with a timeout of 1000 ms

	if res2 < 0
		error("Failed to hid read timeout command (error #02)")
	end
	
	#=
	for (index, value) in pairs(response)
		@printf "response[%d] = %x\n" index value
	end
	=#

	if (response[1] != 0x90 || response[2] != 0x00)
		error("I2c Write communication error between MCP2221 and MCP47FEB01 (err #03).")
	end


	#read (0x91) 2 bytes from C1 address
	cmd2 = UInt8[0x00,0x91, 0x02, 0x00, 0xC1]
	res3 = HidApi.hid_write(mcp.device, cmd2, 65)
	if res3 < 0
		error("Failed to hid write command (error #01)")
	end

	response2 = Vector{UInt8}(undef, 64)
	res4 = HidApi.hid_read_timeout(mcp.device, response2, 65, 5000)  # Read with a timeout of 1000 ms

	if res4 < 0
		error("Failed to hid read timeout command (error #02)")
	end
	#=
	for (index, value) in pairs(response)
		@printf "response[%d] = %x\n" index value
	end
	=#

	if (response2[1] != 0x91 || response2[2] != 0x00)
		error("I2C Read communication error between MCP2221 and MCP47FEB01 (err #04).")
	end

	# Read the response from slave
	cmd3 = UInt8[0x00,0x40]
	res5 = HidApi.hid_write(mcp.device, cmd3, 64)
	if res5 < 0
		error("Failed to hid write command (error #01)")
	end

	response3 = Vector{UInt8}(undef, 64)
	res6 = HidApi.hid_read_timeout(mcp.device, response3, 65, 1000)  # Read with a timeout of 1000 ms

	if res6 < 0
		error("Failed to hid read timeout command (error #02)")
	end

	lower_byte = UInt8(response3[6])

	#@printf "DAC Value = %d (0x%X)\n\n" lower_byte lower_byte

	
	#=
	for (index, value) in pairs(response)
		@printf "response[%d] = %x\n" index value
	end
	=#

	if (response3[1] != 0x40 || response3[2] != 0x00)
		error("I2C Slave read communication error between MCP2221 and MCP47FEB01 (err #05).")
	end

	return lower_byte

end