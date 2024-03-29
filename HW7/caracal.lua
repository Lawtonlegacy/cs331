#!/usr/bin/env lua
-- caracal.lua
-- Glenn G. Chappell
-- 2021-03-31
--
-- For CS F331 / CSCE A331 Spring 2021
-- REPL/Shell for Caracal Programming Language
-- Requires lexit.lua, parseit.lua, interpit.lua


parseit = require "parseit"
interpit = require "interpit"


-- *********************************************************************
-- Variables
-- *********************************************************************


local caracalstate  -- Caracal variable values


-- *********************************************************************
-- Callback Functions for Interpreter
-- *********************************************************************


-- We define these functions so we can pass them to the interpreter.


-- inputLine
-- Input a line of text from standard input and return it in string
-- form, with no trailing newline.
function inputLine()
    io.flush()  -- Ensure previous output is done before input
    local line = io.read("*l")
    if type(line) == "string" then
        return line
    else
        return ""
    end
end


-- outputString
-- Output the given string to standard output, with no added newline.
function outputString(s)
    io.write(s)
end


-- *********************************************************************
-- Functions for Caracal REPL
-- *********************************************************************


-- printHelp
-- Print help for REPL.
local function printHelp()
    io.write("Type Caracal code to execute it.\n")
    io.write("Commands (these may be abbreviated;")
    io.write(" for example, \":e\" for \":exit\")\n")
    io.write("  :exit          - Exit.\n")
    io.write("  :run FILENAME  - Execute Caracal source file.\n")
    io.write("  :clear         - Clear Caracal state.\n")
    io.write("  :help          - Print help.\n")
end


-- elimSpace
-- Given a string, remove all leading & trailing whitespace, and return
-- result. If given nil, returns nil.
local function elimSpace(s)
    if s == nil then
        return nil
    end

    assert(type(s) == "string")

    local ss = s:gsub("^%s+", "")
    ss = ss:gsub("%s+$", "")
    return ss
end


-- elimLeadingNonspace
-- Given a string, remove leading non-whitespace, and return result.
local function elimLeadingNonspace(s)
    assert(type(s) == "string")

    local ss = s:gsub("^%S+", "")
    return ss
end


-- errMsg
-- Given an error message, prints it in flagged-error form, with a
-- newline appended.
local function errMsg(msg)
    assert(type(msg) == "string")

    io.write("*** ERROR - "..msg.."\n")
end


-- clearState
-- Clear Caracal state: functions, simple variables, arrays.
local function clearState()
    caracalstate = { f={}, v={}, a={} }
end


-- runCaracal
-- Given a string, attempt to treat it as source code for a Caracal
-- program, and execute it. I/O uses standard input & output.
--
-- Parameters:
--   program  - Caracal source code
--   state    - Values of Caracal variables as in interpit.interp.
--   execmsg  - Optional string. If code parses, then, before it is
--              executed, this string is printed, followed by a newline.
--
-- Returns three values:
--   good     - true if initial portion of program parsed successfully;
--              false otherwise.
--   done     - true if parse reached end of program; false otherwise.
--   newstate - If good, done are both true, then new value of state,
--              updated with revised values of variables. Otherwise,
--              same as passed value of state.
--
-- If good and done are both true, then the code was executed.
function runCaracal(program, state, execmsg)
    local good, done, ast = parseit.parse(program)
    local newstate
    if good and done then
        if execmsg ~= nil then
            io.write(execmsg.."\n")
        end
        newstate = interpit.interp(ast, state, inputLine, outputString)
    else
        newstate = state
    end
    return good, done, newstate
end


-- runFile
-- Given filename, attempt to read source for a Caracal program from it,
-- and execute the program. If prinntmsg is true and the program parses
-- correctly, then print a message before executing the file.
function runFile(fname, printmsg)
    function readable(fname)
        local f = io.open(fname, "r")
        if f ~= nil then
            f:close()
            return true
        else
            return false
        end
    end

    local good, done

    if not readable(fname) then
        errMsg("Caracal source file not readable: '"..fname.."'")
        return
    end
    local source = ""
    for line in io.lines(fname) do
        source = source .. line .. "\n"
    end
    local execmsg
    if printmsg then
        execmsg = "EXECUTING FILE: '"..fname.."'"
    else
        execmsg = nil
    end
    good, done, caracalstate = runCaracal(source, caracalstate, execmsg)
    if not (good and done) then
        errMsg("Syntax error in Caracal source file: '"..fname.."'")
    end
end


-- doReplCommand
-- Given input line beginning with ":", execute as REPL command. Return
-- true if execution of REPL should continue; false if it should end.
function doReplCommand(line)
    assert(line:sub(1,1) == ":")
    if line:sub(1,2) == ":e" then
        return false
    elseif line:sub(1,2) == ":h" then
        printHelp()
        return true
    elseif line:sub(1,2) == ":c" then
        clearState()
        io.write("Caracal state cleared\n")
        return true
    elseif line:sub(1,2) == ":r" then
        fname = elimLeadingNonspace(line:sub(3))
        fname = elimSpace(fname)
        if (fname == "") then
            errMsg("No filename given")
        else
            runFile(fname, true)  -- true: Print execution message
        end
        return true
    else
        errMsg("Unknown command")
        return true
    end
end


-- repl
-- Caracal REPL. Prompt & get a line. If it is blank, then exit. If it
-- looks like the filename of a Caracal source file, then get Caracal
-- source from it, execute, and exit. Otherwise, treat line as Caracal
-- program, and attempt to execute it. If it looks like an incomplete
-- Caracal program, then keep inputting, and continue to attempt to
-- execute. REPEAT.
function repl()
    local line, good, done, continueflag, prompt
    local source = ""

    printHelp()
    while true do
        -- Prompt
        if source == "" then
            io.write("\n")
            prompt = ">>> "
        else
            prompt = "... "
        end

        -- Input a line + error check
        repeat
            io.write(prompt)
            io.flush()  -- Ensure previous output is done before input
            line = io.read("*l")  -- Read a line
            line = elimSpace(line)
        until line ~= ""

        if line == nil then             -- Read error (EOF?)
            io.write("\n")
            break
        end

        -- Handle input, as approprite
        if line:sub(1,1) == ":" then    -- Command
            source = ""
            continueflag = doReplCommand(line)
            if not continueflag then
                break
            end
        else                            -- Caracal code
            source = source .. line
            good, done, caracalstate = runCaracal(source, caracalstate)
            if (not good) and done then
                source = source .. "\n" -- Continue inputting source
            else
                source = ""             -- Start over
            end
            if not done then
                errMsg("Syntax error")
            end
        end
    end
end


-- *********************************************************************
-- Main Program
-- *********************************************************************


-- Initialize Caracal state
clearState()

-- Command-line argument? If so treat as Caracal source filename, read
-- source, and execute.
if arg[1] ~= nil then
    runFile(arg[1], false)  -- false: Do not print execution message
    io.write("\n")
    io.write("Press ENTER to quit ")
    io.flush()  -- Ensure previous output is done before input
    io.read("*l")
-- Otherwise, fire up the Caracal REPL.
else
    repl()
end