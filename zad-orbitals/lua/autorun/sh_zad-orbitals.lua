ORBITAL = ORBITAL or {}

---------------------------------------------------------
-- STRIKE CONFIGURATION
---------------------------------------------------------

ORBITAL.Strikes = {
    {
        id = "test_strike",
        name = "TEST STRIKE",
        code = "UUDDLRLR",
        delay = 5
    },
    {
        id = "light_strike",
        name = "LIGHT ORBITAL STRIKE",
        code = "UDLRU",
        delay = 6
    },
    {
        id = "heavy_strike",
        name = "HEAVY ORBITAL STRIKE",
        code = "RRULLDDRU",
        delay = 8
    },
    {
        id = "exterminatus",
        name = "EXTERMINATUS",
        code = "UUURRRDDDLLLURDL",
        delay = 12
    }
}

---------------------------------------------------------
-- SETTINGS
---------------------------------------------------------

-- How long the player can wait between code inputs
ORBITAL.InputTimeout = 5

-- Basic anti-spam protection
ORBITAL.MinimumInputDelay = 0.08

ORBITAL.DefaultDelay = 5

function ORBITAL.GetStrike(id)
    for _, strike in ipairs(ORBITAL.Strikes) do
        if strike.id == id then
            return strike
        end
    end
end