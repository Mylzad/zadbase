ZADBase = ZADBase or {}

// Maximum of the random function (By default is 10,000 so percentages are the base percentage times 100)
ZADBase.MaxPercent = 100000

// Names of each loot Table (MUST BE THE SAME AS THE TABLE NAME WITHOUT THE "Table" PART!)
ZADBase.RarityNames = {
	"Legendary",
	"Epic Unstable DI",
	"Epic",
	"Epic Regular",
	"Rare",
    "Uncommon",
	"Common"
}

// Names of each loot table for event rolls 
ZADBase.EventRolls = {
    "Legendary",
    "Epic",
    "Rare",
    "Money"
}

// The amount of xp awarded for each tier (MUST USE SAME NAMES AS TABLES WITHOUT "Table")
ZADBase.XPAmounts = {
    ["Common"] = 25,
    ["Rare"] = 250,
    ["Epic"] = 500,
    ["Legendary"] = 1000
}

// Chance for the lootbox to land on the table rarity (Default is percent * 100) (All must add up to ZADBase.MaxPercent)
ZADBase.Rarities = {
    ["Common"] = 69914, // 98.939% (the rest of the percentage)
    ["Uncommon"] = 25000,
    ["Rare"] = 5000, // 1%
    ["Epic Regular"] = 50,
    ["Epic"] = 25,
    ["Epic Unstable DI"] = 10, // 0.05%
    ["Legendary"] = 1, // 0.001%
}

ZADBase.BossRarities = {
    ["Common"] = 98939, // 98.939% (the rest of the percentage)
    ["Uncommon"] = 69,
    ["Rare"] = 1000, // 1%
    ["Epic"] = 50,
    ["Epic Regular"] = 69,
    ["Epic Unstable DI"] = 69, // 0.05%
    ["Legendary"] = 1, // 0.001%
}

ZADBase.EventRarities = {
    ["Money"] = 50000, // 50%
    ["Rare"] = 25000, // 25%
    ["Epic"] = 15000, // 15%
    ["Legendary"] = 10000 //  10%
}

ZADBase.BossXPAmounts = {
    ["Common"] = 250,
    ["Rare"] = 2500,
    ["Epic"] = 5000,
    ["Legendary"] = 10000
}

ZADBase.MoneyTable = {
    5000,
    10000,
    15000,
    20000,
    25000
}

ZADBase.IgnoredItems = {}

// Time it takes for the box to despawn in seconds (set to false for it to only remove after used)
ZADBase.AutoRemove = 30