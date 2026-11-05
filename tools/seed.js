/* Loads verified test accounts and realistic demo data into Firebase.
 *
 *   1. Firebase console > Project settings > Service accounts >
 *      "Generate new private key", save it as tools/serviceAccountKey.json
 *   2. cd tools && npm install && npm run seed
 *
 * Safe to run again: accounts are updated, documents are overwritten by id.
 * NEVER commit serviceAccountKey.json (it is listed in .gitignore).
 */
const admin = require('firebase-admin');
const path = require('path');

admin.initializeApp({ credential: admin.credential.cert(require(path.join(__dirname, 'serviceAccountKey.json'))) });
const auth = admin.auth();
const db = admin.firestore();
const now = admin.firestore.FieldValue.serverTimestamp;
const ago = (h) => admin.firestore.Timestamp.fromMillis(Date.now() - h * 3600e3);

const PASSWORD = 'Ntiza@2026';
const accounts = [
  { key: 'admin',  email: 'admin@ntiza.test',  name: 'Admin NTIZA',          role: 'admin',  phone: '0788000001', district: 'Kigali' },
  { key: 'farmer', email: 'farmer@ntiza.test', name: 'Uwase Esperance',      role: 'farmer', phone: '0788000002', district: 'Huye' },
  { key: 'owner',  email: 'owner@ntiza.test',  name: 'Agasaro Farm Equipment', role: 'owner', phone: '0788000003', district: 'Huye' },
  { key: 'expert', email: 'expert@ntiza.test', name: 'Dr. Uwera Solange',    role: 'expert', phone: '0788000004', district: 'Kigali' },
  { key: 'agent',  email: 'agent@ntiza.test',  name: 'Mugisha Patrick',      role: 'agent',  phone: '0788000005', district: 'Musanze' },
];

async function upsertUser(a) {
  let user;
  try {
    user = await auth.getUserByEmail(a.email);
    await auth.updateUser(user.uid, { password: PASSWORD, emailVerified: true, displayName: a.name });
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
    user = await auth.createUser({ email: a.email, password: PASSWORD, emailVerified: true, displayName: a.name });
  }
  await db.collection('users').doc(user.uid).set({
    name: a.name, email: a.email, phone: a.phone, district: a.district,
    role: a.role, status: 'active', createdAt: now(),
  });
  return user.uid;
}

const schedule = {
  Monday: '08:00 – 12:00', Tuesday: '08:00 – 12:00', Wednesday: '09:00 – 16:00',
  Thursday: '09:00 – 16:00', Friday: '08:00 – 12:00',
};

async function main() {
  const uid = {};
  for (const a of accounts) { uid[a.key] = await upsertUser(a); console.log('account', a.email); }

  // Extra partner applications waiting for the admin to approve.
  const pending = [
    { email: 'pending.owner@ntiza.test', name: 'Karama Cooperative', role: 'owner', phone: '0788000006', district: 'Nyagatare' },
    { email: 'pending.expert@ntiza.test', name: 'Eng. Rutayisire Bob', role: 'expert', phone: '0788000007', district: 'Bugesera' },
  ];
  for (const p of pending) {
    let u;
    try { u = await auth.getUserByEmail(p.email); } catch { u = await auth.createUser({ email: p.email, password: PASSWORD, emailVerified: true, displayName: p.name }); }
    await db.collection('users').doc(u.uid).set({ ...p, status: 'pending', createdAt: now() });
  }

  const ownerName = 'Agasaro Farm Equipment';
  const equipment = [
    ['eq1', 'Tractor 50HP 4WD', 'Tractor', 'Huye', 'Mbazi', 25000, 'hour', 'Available', 38, 'Suitable for large farms. Ploughing, harrowing and haulage. Fuel and a trained operator are included in the hourly rate.', [['Power', '50 HP'], ['Drive', '4WD'], ['Operator', 'Included']]],
    ['eq2', 'Combine Harvester', 'Harvester', 'Musanze', 'Cyuve', 60000, 'hour', 'Available', 52, 'High-capacity combine for maize, wheat and rice. Includes grain tank and an experienced operator.', [['Capacity', '8 t/h'], ['Crops', 'Maize, wheat'], ['Operator', 'Included']]],
    ['eq3', 'Maize Planter 4-Row', 'Planter', 'Nyagatare', 'Karama', 35000, 'hectare', 'Available', 27, 'Precision 4-row seeder with adjustable spacing. Ideal for maize and beans.', [['Rows', '4'], ['Seed hopper', '40 L'], ['Operator', 'Optional']]],
    ['eq4', 'Water Pump 5HP', 'Pump', 'Bugesera', 'Nyamata', 8000, 'hour', 'Available', 61, 'Petrol-driven irrigation pump with hose kit. Fuel not included.', [['Power', '5 HP'], ['Flow', '60 m³/h'], ['Fuel', 'Not included']]],
    ['eq5', 'Power Tiller 12HP', 'Tiller', 'Huye', 'Tumba', 15000, 'hour', 'Available', 19, 'Compact tiller for terraces and small plots. Easy to transport.', [['Power', '12 HP'], ['Width', '80 cm'], ['Operator', 'Optional']]],
    ['eq6', 'Maize Sheller', 'Sheller', 'Kayonza', 'Mukarange', 20000, 'day', 'Maintenance', 14, 'Electric maize sheller, about 1 tonne per hour.', [['Capacity', '1 t/h'], ['Power', 'Electric']]],
  ];
  for (const [id, name, type, district, sector, price, unit, status, jobs, about, specs] of equipment) {
    await db.collection('equipment').doc(id).set({
      ownerId: uid.owner, ownerName, name, type, district, sector, price, unit, status, about, jobs,
      specs: specs.map(([k, v]) => ({ k, v })), createdAt: now(),
    });
  }

  await db.collection('experts').doc(uid.expert).set({
    name: 'Dr. Uwera Solange', field: 'Crop Production', category: 'Crops', rating: 4.9, years: 12,
    fee: 15000, sessionMinutes: 30, accepting: true, schedule,
  });
  const experts = [
    ['ex2', 'Prof. Nkusi Damien', 'Soil Management', 'Soil', 4.8, 15, 20000],
    ['ex3', 'Dr. Mukamana Jeanne', 'Pest & Disease Control', 'Pests', 4.7, 9, 15000],
    ['ex4', 'Eng. Rutayisire Bob', 'Irrigation & Water', 'Irrigation', 4.8, 11, 18000],
  ];
  for (const [id, name, field, category, rating, years, fee] of experts) {
    await db.collection('experts').doc(id).set({ name, field, category, rating, years, fee, sessionMinutes: 30, accepting: true, schedule });
  }

  const courses = [
    ['c1', 'Tractor Operation & Safety', 'Beginner', 'Equipment', 7, 'hero_villagers.jpg'],
    ['c2', 'Irrigation Systems for Small Farms', 'Intermediate', 'Irrigation', 8, 'course_irrigation.jpg'],
    ['c3', 'Agribusiness & Market Access', 'Beginner', 'Business', 5, 'course_agribusiness.jpg'],
    ['c4', 'Livestock Management Basics', 'Beginner', 'Livestock', 6, 'course_livestock.jpg'],
  ];
  for (const [id, title, level, topic, lessons, image] of courses) {
    await db.collection('courses').doc(id).set({ title, level, topic, lessons, image });
  }

  // Bookings in every state, so each dashboard has something to show.
  const eqBooking = (n, eq, status, h, date, detail, total, extra = {}) => ({
    ref: `NTZ-${n}`,
    data: {
      kind: 'equipment', title: eq[1], image: { Tractor: 'tractor.jpg', Harvester: 'harvester.jpg', Planter: 'planter.jpg', Pump: 'pump.jpg', Tiller: 'tiller.jpg' }[eq[2]] || 'tractor.jpg',
      status, dateLabel: date, scheduled: `${date} · 08:00`, detail, place: eq[3], location: `${eq[4]} sector, ${eq[3]}`, total,
      itemId: eq[0], farmerId: uid.farmer, farmerName: 'Uwase Esperance', providerId: uid.owner, providerName: ownerName,
      agentId: '', clientName: '', createdAt: ago(h), ...extra,
    },
  });
  const [t, h, p, w, ti] = equipment;
  const bookings = [
    eqBooking(2041, t, 'Completed', 240, '03 Nov', '4 hours', 100000, { paidVia: 'MTN MoMo' }),
    eqBooking(2042, p, 'Completed', 168, '06 Nov', '2 hectares', 70000, { paidVia: 'Airtel Money' }),
    eqBooking(2043, w, 'Confirmed', 48, '14 Nov', '6 hours', 48000, { paidVia: 'MTN MoMo' }),
    eqBooking(2044, ti, 'Pending', 6, '18 Nov', '3 hours', 45000),
    eqBooking(2045, h, 'Cancelled', 120, '10 Nov', '2 hours', 120000),
    eqBooking(2046, t, 'Confirmed', 12, '16 Nov', '8 hours', 200000, { agentId: uid.agent, clientName: 'Nyirahabimana Claudine', farmerId: '', farmerName: '' }),
    {
      ref: 'NTZ-2047',
      data: {
        kind: 'consult', title: 'Crop Production consultation', image: '', status: 'Confirmed', dateLabel: '15 Nov',
        scheduled: 'Saturday, 15 Nov 2026 · 09:00', detail: '30 minutes', place: 'Phone call', location: '', total: 15000,
        itemId: uid.expert, farmerId: uid.farmer, farmerName: 'Uwase Esperance', providerId: uid.expert, providerName: 'Dr. Uwera Solange',
        agentId: '', clientName: '', paidVia: 'MTN MoMo', createdAt: ago(20),
      },
    },
  ];
  for (const b of bookings) await db.collection('bookings').doc(b.ref).set(b.data);
  await db.collection('meta').doc('counters').set({ booking: 2047 }, { merge: true });

  const notes = [
    [uid.farmer, 'Booking confirmed', 'Your Water Pump 5HP booking NTZ-2043 was confirmed.', 'booking', 2],
    [uid.farmer, 'Payment received', 'Payment for NTZ-2042 was recorded.', 'payment', 150],
    [uid.owner, 'New booking request', 'Uwase Esperance requested Power Tiller 12HP for 18 Nov.', 'booking', 6],
    [uid.expert, 'New consultation request', 'Uwase Esperance booked a 30-minute session.', 'booking', 20],
    [uid.agent, 'Booking confirmed', 'NTZ-2046 for Nyirahabimana Claudine was confirmed.', 'booking', 10],
    [uid.admin, 'New partner applications', '2 partner applications are waiting for review.', 'info', 3],
  ];
  for (const [userId, title, body, kind, h] of notes) {
    await db.collection('notifications').add({ userId, title, body, kind, unread: true, createdAt: ago(h) });
  }

  for (const c of [['Nyirahabimana Claudine', '0788111222', 'Musanze'], ['Habimana Eric', '0788333444', 'Musanze']]) {
    await db.collection('agentClients').add({ agentId: uid.agent, name: c[0], phone: c[1], district: c[2], createdAt: now() });
  }

  await db.collection('disputes').doc('d1').set({
    bookingRef: 'NTZ-2045', raisedBy: uid.farmer, raisedByName: 'Uwase Esperance',
    reason: 'The machine did not arrive on the agreed day.', status: 'Open', resolution: '', createdAt: ago(100),
  });

  console.log('\nDone. Log in with password ' + PASSWORD + ' using:');
  for (const a of accounts) console.log(`  ${a.role.padEnd(7)} ${a.email}`);
}
main().then(() => process.exit(0)).catch((e) => { console.error(e); process.exit(1); });
