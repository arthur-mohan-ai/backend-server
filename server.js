const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3000;

app.use(cors({
  origin: ["http://localhost:5173"],
  credentials: true
}));

app.get('/api/hello', (req, res) => {
  res.json({ message: "Welcome" });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
