ORBITAL = ORBITAL or {}

---------------------------------------------------------
-- STRIKE CONFIGURATION
---------------------------------------------------------

ORBITAL.Strikes = {
    {
        id = "test_strike",
        name = "TEST STRIKE",
        code = "UUDDLRLR"
    },

    {
        id = "light_strike",
        name = "LIGHT ORBITAL STRIKE",
        code = "UDLRU"
    },

    {
        id = "heavy_strike",
        name = "HEAVY ORBITAL STRIKE",
        code = "RRULLDDRU"
    },

    {
        id = "exterminatus",
        name = "EXTERMINATUS",
        code = "UUURRRDDDLLLURDL"
    }
}

---------------------------------------------------------
-- SETTINGS
---------------------------------------------------------

-- How long the player can wait between code inputs
ORBITAL.InputTimeout = 5

-- Basic anti-spam protection
ORBITAL.MinimumInputDelay = 0.08