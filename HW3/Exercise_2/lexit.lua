-- lexit.lua
-- Robert Lawton
-- 11 February 2021
-- lexit module for CS 331: HW3 Exercise 2
-- Heavily based off lexer.lua by Glenn Chappell

-- *********************************************************************
-- Module Table Initialization
-- *********************************************************************


local lexit = {}  -- Our module; members are added below


-- *********************************************************************
-- Public Constants
-- *********************************************************************


-- Numeric constants representing lexeme categories
lexit.KEY    = 1
lexit.ID     = 2
lexit.NUMLIT = 3
lexit.STRLIT = 4
lexit.OP     = 5
lexit.PUNCT  = 6
lexit.MAL    = 7


-- catnames
-- Array of names of lexeme categories.
-- Human-readable strings. Indices are above numeric constants.
lexit.catnames = {
    "Keyword",
    "Identifier",
    "NumericLiteral",
    "StringLiteral",
    "Operator",
    "Punctuation",
    "Malformed"
}


-- *********************************************************************
-- Kind-of-Character Functions
-- *********************************************************************

-- All functions return false when given a string whose length is not
-- exactly 1.


-- isLetter
-- Returns true if string c is a letter character, false otherwise.
local function isLetter(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "A" and c <= "Z" then
        return true
    elseif c >= "a" and c <= "z" then
        return true
    else
        return false
    end
end


-- isDigit
-- Returns true if string c is a digit character, false otherwise.
local function isDigit(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "0" and c <= "9" then
        return true
    else
        return false
    end
end


-- isWhitespace
-- Returns true if string c is a whitespace character, false otherwise.
local function isWhitespace(c)
    if c:len() ~= 1 then
        return false
    elseif c == " " or c == "\t" or c == "\n" or c == "\r"
      or c == "\f" then
        return true
    else
        return false
    end
end


-- isPrintableASCII
-- Returns true if string c is a printable ASCII character (codes 32 " "
-- through 126 "~"), false otherwise.
local function isPrintableASCII(c)
    if c:len() ~= 1 then
        return false
    elseif c >= " " and c <= "~" then
        return true
    else
        return false
    end
end


-- isIllegal
-- Returns true if string c is an illegal character, false otherwise.
local function isIllegal(c)
    if c:len() ~= 1 then
        return false
    elseif isWhitespace(c) then
        return false
    elseif isPrintableASCII(c) then
        return false
    else
        return true
    end
end


-- *********************************************************************
-- The Lexer
-- *********************************************************************


-- lex
-- Our lexit
-- Intended for use in a for-in loop:
--     for lexstr, cat in lexit.lex(program) do
-- Here, lexstr is the string form of a lexeme, and cat is a number
-- representing a lexeme category. (See Public Constants.)
function lexit.lex(program)
    -- ***** Variables (like class data members) *****

    local pos       -- Index of next character in program
                    -- INVARIANT: when getLexeme is called, pos is
                    --  EITHER the index of the first character of the
                    --  next lexeme OR program:len()+1
    local state     -- Current state for our state machine
    local ch        -- Current character
    local lexstr    -- The lexeme, so far
    local category  -- Category of lexeme, set when state set to DONE
    local handlers  -- Dispatch table; value created later

    -- ***** States *****

    local DONE   = 0
    local START  = 1
    local LETTER = 2
    local DIGIT  = 3
    local EXP    = 4
    local DIGDOT = 5
    local DOT    = 6
    local PLUS   = 7
    local MINUS  = 8
    local STAR   = 9
    local STRING = 10
    local OPERATOR = 11

    -- ***** Character-Related Utility Functions *****

    -- currChar
    -- Return the current character, at index pos in program. Return
    -- value is a single-character string, or the empty string if pos is
    -- past the end.
    local function currChar()
        return program:sub(pos, pos)
    end

    -- nextChar
    -- Return the next character, at index pos+1 in program. Return
    -- value is a single-character string, or the empty string if pos+1
    -- is past the end.
    local function nextChar()
        return program:sub(pos+1, pos+1)
    end

    -- afterNextChar
    -- Return the character after the next, at index pos+2 in program. Return
    -- value is a single-character string, or the empty string if pos+2
    -- is past the end.
    local function afterNextChar()
        return program:sub(pos+2, pos+2)
    end

    --prevChar
    -- Return the previous character, at index pos-1 in program. Return
    -- value is a single-character string, or the empty string if pos-1
    -- is past the start.
    local function prevChar()
        return program:sub(pos-1, pos-1)
    end
    
    -- drop1
    -- Move pos to the next character.
    local function drop1()
        pos = pos+1
    end

    -- add1
    -- Add the current character to the lexeme, moving pos to the next
    -- character.
    local function add1()
        lexstr = lexstr .. currChar()
        drop1()
    end

    -- skipWhitespace
    -- Skip whitespace and comments, moving pos to the beginning of
    -- the next lexeme, or to program:len()+1.
    local function skipWhitespace()
        while true do
            -- Skip whitespace characters
            while isWhitespace(currChar()) do
                drop1()
            end

            -- Done if no comment
            if currChar() ~= "#" then
                break
            end

            -- Skip comment
            drop1()  -- Drop leading "#"
            while true do
                if currChar() == "\n" then
                    drop1()  -- Drop trailing "\n"
                    break
                elseif currChar() == "" then  -- End of input?
                   return
                end
                drop1()  -- Drop character inside comment
            end
        end
    end

    -- ***** State-Handler Functions *****

    -- A function with a name like handle_XYZ is the handler function
    -- for state XYZ

    -- State DONE: lexeme is done; this handler should not be called.
    local function handle_DONE()
        error("'DONE' state should not be handled\n")
    end

    -- State START: no character read yet.
    local function handle_START()
        if isIllegal(ch) then
            add1()
            state = DONE
            category = lexit.MAL
        elseif isLetter(ch) or ch == "_" then
            add1()
            state = LETTER
        elseif isDigit(ch) then
            add1()
            state = DIGIT
        elseif ch == "." then
            add1()
            state = DONE
            category = lexit.PUNCT
        elseif ch == "+" then
            add1()
            state = DONE
            category = lexit.OP
        elseif ch == "-" then
            add1()
            state = DONE
            category = lexit.OP
        elseif ch == "*" or ch == "/" or ch == "=" then
            add1()
            state = STAR
        elseif ch == "!" or ch == "<" or ch == ">" 
        or ch == "%" or ch == "[" or ch == "]" then
            add1()
            state = OPERATOR
        elseif ch == '"' then 
            add1()
            state = STRING
        else
            add1()
            state = DONE
            category = lexit.PUNCT
        end
    end

    -- State LETTER: we are in an ID.
    local function handle_LETTER()
        if isLetter(ch) or ch == "_" or isDigit(ch) then
            add1()
        else
            state = DONE
            if lexstr == "and" 
            or lexstr == "char"
            or lexstr == "cr"
            or lexstr == "def"
            or lexstr == "dq"
            or lexstr == "elseif"
            or lexstr == "else"
            or lexstr == "false"
            or lexstr == "for"
            or lexstr == "if"
            or lexstr == "not"
            or lexstr == "or"
            or lexstr == "readnum"
            or lexstr == "return"
            or lexstr == "true"
            or lexstr == "write" then
                category = lexit.KEY
            else
                category = lexit.ID
            end
        end
    end

    -- State DIGIT: we are in a NUMLIT, and we have NOT seen ".".
    local function handle_DIGIT()
        if isDigit(ch) then
            add1()
        elseif ch == "e" or ch == "E" then     
            if isDigit(nextChar()) then
                add1()
                state = EXP
            elseif nextChar() == "+" and isDigit(afterNextChar()) then
                add1()
                add1()
                state = EXP
            end
            state = EXP
        elseif ch == "." then
           state = DIGDOT
        else
            state = DONE
            category = lexit.NUMLIT
        end
    end

    -- State EXP: we are in a NUMLIT, and we have seen "e" or "E".
    local function handle_EXP()
        if isDigit(ch) then
            add1()
        else
            state = DONE
            category = lexit.NUMLIT
        end
    end

    -- State DIGDOT: we are in a NUMLIT, and we have seen ".".
    local function handle_DIGDOT()
        if isDigit(ch) then
            add1()
        else
            state = DONE
            category = lexit.NUMLIT
        end
    end

    -- State DOT: we have seen a dot (".") and nothing else.
    local function handle_DOT()
        if isDigit(ch) then
            add1()
            state = DIGDOT
        else
            state = DONE
            category = lexit.PUNCT
        end
    end

    -- State PLUS: we have seen a plus ("+") and nothing else.
    local function handle_PLUS()
        if isDigit(ch) then
            add1()
            state = DIGIT
        elseif ch == "." then
            if isDigit(nextChar()) then  -- lookahead
                add1()  -- add dot to lexeme
                state = DIGDOT
            else        -- lexeme is just "+"; do not add dot to lexeme
                state = DONE
                category = lexit.OP
            end
        elseif ch == "+" or ch == "=" then
            add1()
            state = DONE
            category = lexit.OP
        else
            state = DONE
            category = lexit.OP
        end
    end

    -- State MINUS: we have seen a minus ("-") and nothing else.
    local function handle_MINUS()
        if isDigit(ch) then
            add1()
            state = DIGIT
        elseif ch == "." then
            if isDigit(nextChar()) then  -- lookahead
                add1()  -- add dot to lexeme
                state = DIGDOT
            else        -- lexeme is just "-"; do not add dot to lexeme
                state = DONE
                category = lexit.OP
            end
        elseif ch == "-" or ch == "=" then
            add1()
            state = DONE
            category = lexit.OP
        else
            state = DONE
            category = lexit.OP
        end
    end

    -- State STAR: we have seen a star ("*"), slash ("/"), or equal
    -- ("=") and nothing else.
    local function handle_STAR()  -- Handle * or / or =
        if ch == "=" and prevChar() ~= "*" and prevChar() ~= "/" then
            add1()
            state = DONE
            category = lexit.OP
        else
            state = DONE
            category = lexit.OP
        end
    end

    -- State OPERATOR: we have seen a "!", "<", ">", "%", "[", or "]"
    -- and nothing else.
    local function handle_OPERATOR()
        if ch == "=" and (prevChar() ~= "=" and prevChar() ~= "]") then
            add1()
        elseif prevChar() == "!" then
            state = DONE
            category = lexit.PUNCT
        else 
            state = DONE
            category = lexit.OP
        end
    end

    -- State STRING: we have seen a double quote (") indicating this is a STRLIT
    local function handle_STRING()
        if ch == "" or ch == "\n" then
            drop1()
            state = DONE
            category = lexit.MAL
        elseif ch == '"' then
            add1()
            state = DONE
            category = lexit.STRLIT
        else
            add1()
        end
    end

    -- ***** Table of State-Handler Functions *****

    handlers = {
        [DONE]=handle_DONE,
        [START]=handle_START,
        [LETTER]=handle_LETTER,
        [DIGIT]=handle_DIGIT,
        [EXP]=handle_EXP,
        [DIGDOT]=handle_DIGDOT,
        [DOT]=handle_DOT,
        [PLUS]=handle_PLUS,
        [MINUS]=handle_MINUS,
        [STAR]=handle_STAR,
        [STRING]=handle_STRING,
        [OPERATOR]=handle_OPERATOR,
    }

    -- ***** Iterator Function *****

    -- getLexeme
    -- Called each time through the for-in loop.
    -- Returns a pair: lexeme-string (string) and category (int), or
    -- nil, nil if no more lexemes.
    local function getLexeme(dummy1, dummy2)
        if pos > program:len() then
            return nil, nil
        end
        lexstr = ""
        state = START
        while state ~= DONE do
            ch = currChar()
            handlers[state]()
        end

        skipWhitespace()
        return lexstr, category
    end

    -- ***** Body of Function lex *****

    -- Initialize & return the iterator function
    pos = 1
    skipWhitespace()
    return getLexeme, nil, nil
end


-- *********************************************************************
-- Module Table Return
-- *********************************************************************


return lexit