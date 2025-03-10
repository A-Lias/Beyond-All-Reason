return {
	corsala = {
		maxacc = 0.05125,
		activatewhenbuilt = true,
		maxdec = 0.1025,
		energycost = 4775,
		metalcost = 350,
		buildpic = "CORSALA.DDS",
		buildtime = 7900,
		canmove = true,
		category = "ALL TANK MOBILE WEAPON NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE CANBEUW EMPABLE",
		collisionvolumeoffsets = "0 -5.5 0",
		collisionvolumescales = "31 34 31", --defined in collisionvolumes.lua
		collisionvolumetype = "BOX",
		corpse = "DEAD",
		explodeas = "smallexplosiongeneric-phib",
		footprintx = 3,
		footprintz = 3,
		idleautoheal = 5,
		idletime = 1800,
		leavetracks = true,
		health = 2100,
		maxslope = 12,
		speed = 72.0,
		maxwaterdepth = 255,
		movementclass = "ATANK3",
		nochasecategory = "VTOL",
		objectname = "Units/CORSALA.s3o",
		script = "Units/scavboss/CORSALA.cob",
		seismicsignature = 0,
		selfdestructas = "smallExplosionGenericSelfd-phib",
		sightdistance = 385,
		sonardistance = 299.25,
		trackoffset = 6,
		trackstrength = 5,
		tracktype = "corwidetracks",
		trackwidth = 30,
		turninplace = true,
		turninplaceanglelimit = 90,
		turninplacespeedlimit = 1.7457,
		turnrate = 487,
		usePieceCollisionVolumes=true,
		customparams = {
			unitgroup = 'weapon',
			basename = "base",
			paralyzemultiplier = 0.1,
			cannon1name = "barrel1",
			cannon2name = "barrel2",
			driftratio = "0.2",
			firingceg = "barrelshot-medium",
			flare1name = "flare1",
			flare2name = "flare2",
			kickback = "-2.4",
			model_author = "Itanthias, Hornet",
			normaltex = "unittextures/cor_normal.dds",
			restoretime = "3000",
			rockstrength = "4.5",
			sleevename = "sleeves",
			subfolder = "corvehicles/t2",
			techlevel = 2,
			turretname = "turret",
			wpn1turretx = "45",
			wpn1turrety = "75",
		},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "-0.710494995117 -1.1132812503e-06 0.9375",
				collisionvolumescales = "31.2236328125 16.1107177734 37.8449707031",
				collisionvolumetype = "Box",
				damage = 2000,
				featuredead = "HEAP",
				footprintx = 2,
				footprintz = 2,
				height = 20,
				hitdensity = 100,
				metal = 236,
				object = "Units/corseal_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				collisionvolumescales = "35.0 4.0 6.0",
				collisionvolumetype = "cylY",
				damage = 1500,
				energy = 0,
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 118,
				object = "Units/cor2X2E.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:barrelshot-medium",
				[2] = "custom:DUST_CLOUD",
				[3] = "custom:pilotlight",
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
				[1] = "tcormove",
			},
			select = {
				[1] = "tcorsel",
			},
		},
		weapondefs = {
			cor_heat_laser = {
				areaofeffect = 42,
				avoidfeature = false,
				beamburst = true,
				burst = 10,
				burstrate = 0.03,
				beamTTL = 6,
				beamdecay = 0.7,
				corethickness = 0.2,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.15,
				explosiongenerator = "custom:laserhit-medium-yellow",
				firestarter = 90,
				impulseboost = 0,
				impulsefactor = 0,
				name = "HeatRay",
				noselfdamage = true,
				range = 360,
				reloadtime = 1.1,
				rgbcolor = "1 0.8 0",
				rgbcolor2 = "0.8 0 0",
				soundhitdry = "",
				soundhitwet = "sizzle",
				soundstart = "heatray1",
				soundtrigger = true,
				targetmoveerror = 0,
				turret = true,
				weapontype = "BeamLaser",
				damage = {
					default = 18,
				},
			},
		},
		weapons = {
			[1] = {
				def = "cor_heat_laser",
				onlytargetcategory = "SURFACE",
			},
		},
	},
}
