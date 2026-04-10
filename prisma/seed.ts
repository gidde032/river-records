import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

const rivers = [
  {
    name: 'Mississippi River',
    state: 'WI',
    description: 'The upper Mississippi along the Wisconsin-Minnesota border, offering world-class fishing for walleye, catfish, and bass.',
    sections: [
      {
        name: 'Mississippi River at Prescott',
        usgs_site_code: '05344500',
        latitude_start: 44.760,
        longitude_start: -92.810,
        latitude_end: 44.735,
        longitude_end: -92.795,
        target_species: ['Walleye', 'Smallmouth Bass', 'Channel Catfish', 'Northern Pike'],
        ideal_gauge_min: 5.0,
        ideal_gauge_max: 10.0,
        ideal_temp_min: null,
        ideal_temp_max: null,
      },
    ],
  },
  {
    name: 'Chippewa River',
    state: 'WI',
    description: 'A major tributary of the Mississippi flowing through west-central Wisconsin, known for walleye and smallmouth bass.',
    sections: [
      {
        name: 'Chippewa River at Durand',
        usgs_site_code: '05369500',
        latitude_start: 44.630,
        longitude_start: -91.980,
        latitude_end: 44.608,
        longitude_end: -91.963,
        target_species: ['Walleye', 'Smallmouth Bass', 'Northern Pike', 'Catfish'],
        ideal_gauge_min: 3.0,
        ideal_gauge_max: 8.0,
        ideal_temp_min: null,
        ideal_temp_max: null,
      },
    ],
  },
  {
    name: 'Kinnickinnic River',
    state: 'WI',
    description: 'A premier coldwater trout stream in St. Croix County, one of Wisconsin\'s finest wild brown trout fisheries.',
    sections: [
      {
        name: 'Kinnickinnic River near River Falls',
        usgs_site_code: '05342000',
        latitude_start: 44.850,
        longitude_start: -92.645,
        latitude_end: 44.825,
        longitude_end: -92.632,
        target_species: ['Brown Trout', 'Brook Trout'],
        ideal_gauge_min: 1.5,
        ideal_gauge_max: 3.5,
        ideal_temp_min: 8.0,
        ideal_temp_max: 18.0,
      },
    ],
  },
  {
    name: 'St. Croix River',
    state: 'WI',
    description: 'A National Scenic Riverway forming the Wisconsin-Minnesota border, offering excellent trout and smallmouth bass fishing.',
    sections: [
      {
        name: 'St. Croix River at St. Croix Falls',
        usgs_site_code: '05340500',
        latitude_start: 45.418,
        longitude_start: -92.645,
        latitude_end: 45.393,
        longitude_end: -92.630,
        target_species: ['Brown Trout', 'Smallmouth Bass', 'Walleye', 'Muskellunge'],
        ideal_gauge_min: 2.0,
        ideal_gauge_max: 6.0,
        ideal_temp_min: 8.0,
        ideal_temp_max: 20.0,
      },
    ],
  },
]

async function main() {
  console.log('Seeding database...')

  for (const riverData of rivers) {
    const { sections, ...riverFields } = riverData

    // Idempotent: find by name+state, create only if absent
    let river = await prisma.river.findFirst({
      where: { name: riverFields.name, state: riverFields.state },
    })

    if (!river) {
      river = await prisma.river.create({ data: riverFields })
      console.log(`Created river: ${river.name}`)
    } else {
      console.log(`Skipped river (exists): ${river.name}`)
    }

    for (const sectionData of sections) {
      const existing = await prisma.riverSection.findFirst({
        where: { usgs_site_code: sectionData.usgs_site_code },
      })

      if (!existing) {
        const section = await prisma.riverSection.create({
          data: { ...sectionData, river_id: river.id },
        })
        console.log(`  Created section: ${section.name} (${section.usgs_site_code})`)
      } else {
        console.log(`  Skipped section (exists): ${sectionData.name} (${sectionData.usgs_site_code})`)
      }
    }
  }

  console.log('Done.')
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(() => prisma.$disconnect())
