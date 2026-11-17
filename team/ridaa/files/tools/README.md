# Test accounts and demo data

1. Firebase console → Project settings → **Service accounts** → *Generate new private key*.
   Save the file as `tools/serviceAccountKey.json` (it is git-ignored; never share it).
2. In a terminal: `cd tools`, `npm install`, `npm run seed`.

All accounts use the password **Ntiza@2026** and are already e-mail verified and approved.

| Role | E-mail |
|------|--------|
| Admin | admin@ntiza.test |
| Farmer | farmer@ntiza.test |
| Equipment owner | owner@ntiza.test |
| Expert | expert@ntiza.test |
| Booking agent | agent@ntiza.test |
| Pending owner (to approve) | pending.owner@ntiza.test |
| Pending expert (to approve) | pending.expert@ntiza.test |

The script adds 6 machines, 4 experts, 4 courses, 7 bookings in different states, notifications,
2 agent clients and 1 open dispute. Run it again at any time to reset the demo data.
