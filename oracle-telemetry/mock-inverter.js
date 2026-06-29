const express = require('express');
const app = express();
app.use(express.json());

app.get('/solar/:id/overview', (req, res) => {
  const fakeKWh = Math.floor(Math.random() * 500) + 100; // realistic daily range
  res.json({ overview: { lastDayEnergy: fakeKWh * 1000 } }); // kWh * 1000 as SolarEdge format
});

app.listen(3000, () => console.log("🚀 Mock inverter live on http://localhost:3000"));
console.log("Test: curl http://localhost:3000/solar/ABC123/overview");
