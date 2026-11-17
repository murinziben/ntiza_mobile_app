import '../domain/entities/course.dart';
import '../domain/entities/equipment.dart';
import '../domain/entities/expert.dart';

/// Demo catalogue loaded by the admin ("Load demo data").
const sampleEquipment = <Equipment>[
  Equipment(
    id: 'eq1',
    name: 'Tractor 50HP 4WD',
    type: 'Tractor',
    district: 'Huye',
    sector: 'Mbazi',
    price: 25000,
    unit: 'hour',
    ownerId: 'demo-owner',
    ownerName: 'Agasaro Farm Equipment',
    jobs: 38,
    about:
        'Suitable for large farms. Ploughing, harrowing and haulage with a 3-tonne tipping trailer. Fuel and a trained operator are included in the hourly rate.',
    specs: [Spec('Power', '50 HP'), Spec('Drive', '4WD'), Spec('Operator', 'Included')],
  ),
  Equipment(
    id: 'eq2',
    name: 'Combine Harvester',
    type: 'Harvester',
    district: 'Musanze',
    sector: 'Cyuve',
    price: 60000,
    unit: 'hour',
    status: EquipmentStatus.booked,
    ownerId: 'demo-owner',
    ownerName: 'Musanze Agro Services',
    jobs: 52,
    about:
        'High-capacity combine for maize, wheat and rice. Includes grain tank and an experienced operator.',
    specs: [Spec('Capacity', '8 t/h'), Spec('Crops', 'Maize, wheat'), Spec('Operator', 'Included')],
  ),
  Equipment(
    id: 'eq3',
    name: 'Maize Planter 4-Row',
    type: 'Planter',
    district: 'Nyagatare',
    sector: 'Karama',
    price: 35000,
    unit: 'hectare',
    ownerId: 'demo-owner',
    ownerName: 'Karama Cooperative',
    jobs: 27,
    about: 'Precision 4-row seeder with adjustable spacing. Ideal for maize and beans.',
    specs: [Spec('Rows', '4'), Spec('Seed hopper', '40 L'), Spec('Operator', 'Optional')],
  ),
  Equipment(
    id: 'eq4',
    name: 'Water Pump 5HP',
    type: 'Pump',
    district: 'Bugesera',
    sector: 'Nyamata',
    price: 8000,
    unit: 'hour',
    ownerId: 'demo-owner',
    ownerName: 'Irrigate Rwanda Ltd',
    jobs: 61,
    about: 'Petrol-driven irrigation pump with hose kit. Fuel not included.',
    specs: [Spec('Power', '5 HP'), Spec('Flow', '60 m³/h'), Spec('Fuel', 'Not included')],
  ),
];

const sampleExperts = <Expert>[
  Expert(id: 'ex1', name: 'Dr. Uwera Solange', field: 'Crop Production', category: 'Crops', rating: 4.9, years: 12),
  Expert(id: 'ex2', name: 'Prof. Nkusi Damien', field: 'Soil Management', category: 'Soil', rating: 4.8, years: 15),
  Expert(id: 'ex3', name: 'Dr. Mukamana Jeanne', field: 'Pest & Disease Control', category: 'Pests', rating: 4.7, years: 9),
  Expert(id: 'ex4', name: 'Eng. Rutayisire Bob', field: 'Irrigation & Water', category: 'Irrigation', rating: 4.8, years: 11),
];

const sampleCourses = <Course>[
  Course(id: 'c1', title: 'Tractor Operation & Safety', level: 'Beginner', topic: 'Equipment', lessons: 7, image: 'hero_villagers.jpg'),
  Course(id: 'c2', title: 'Irrigation Systems for Small Farms', level: 'Intermediate', topic: 'Irrigation', lessons: 8, image: 'course_irrigation.jpg'),
  Course(id: 'c3', title: 'Agribusiness & Market Access', level: 'Beginner', topic: 'Business', lessons: 5, image: 'course_agribusiness.jpg'),
  Course(id: 'c4', title: 'Livestock Management Basics', level: 'Beginner', topic: 'Livestock', lessons: 6, image: 'course_livestock.jpg'),
];
