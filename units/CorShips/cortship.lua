return {
	cortship = {
		maxacc = 0.02766,
		autoheal = 5,
		maxdec = 0.02766,
		buildangle = 16384,
		energycost = 3700,
		metalcost = 350,
		buildpic = "CORTSHIP.DDS",
		buildtime = 6400,
		canattack = false,
		canmove = true,
		category = "ALL NOTLAND MOBILE WEAPON SHIP NOTSUB NOTAIR NOTHOVER SURFACE EMPABLE",
		collisionvolumeoffsets = "0 0 5",
		collisionvolumescales = "40 40 90",
		collisionvolumetype = "CylZ",
		corpse = "DEAD",
		explodeas = "hugeexplosiongeneric",
		floater = true,
		footprintx = 6,
		footprintz = 6,
		loadingradius = 250,
		health = 3350,
		speed = 69.39,
		minwaterdepth = 0,
		movementclass = "BOAT5",
		nochasecategory = "ALL",
		objectname = "Units/CORTSHIP.s3o",
		pushresistant = true,
		releaseheld = false,
		script = "Units/CORTSHIP.cob",
		seismicsignature = 0,
		selfdestructas = "hugeexplosiongenericSelfd",
		sightdistance = 550,
		transportcapacity = 40,
		transportsize = 4,
		transportunloadmethod = 0,
		turninplace = true,
		turninplaceanglelimit = 90,
		turnrate = 262.5,
		unloadspread = 1,
		waterline = 0,
		customparams = {
			model_author = "Beherith",
			normaltex = "unittextures/cor_normal.dds",
			subfolder = "corships",
		},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "0.0 -3.80138675537 -0.0",
				collisionvolumescales = "66.6000061035 64.2990264893 117.277526855",
				collisionvolumetype = "Box",
				damage = 13704,
				energy = 0,
				featuredead = "HEAP",
				footprintx = 5,
				footprintz = 5,
				height = 4,
				hitdensity = 100,
				metal = 175,
				object = "Units/cortship_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 4032,
				energy = 0,
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 87.5,
				object = "Units/cor5X5A.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:shallow_water_dirt",
				[2] = "custom:waterwake-medium",
				[3] = "custom:bowsplash-medium",
			},
			pieceexplosiongenerators = {
				[1] = "deathceg2",
				[2] = "deathceg3",
				[3] = "deathceg4",
			},
		},
		sounds = {
			canceldestruct = "cancel2",
			underattack = "warning1",
			cant = {
				[1] = "cantdo4",
			},
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			ok = {
				[1] = "shcormov",
			},
			select = {
				[1] = "shcorsel",
			},
		},
	},
}
