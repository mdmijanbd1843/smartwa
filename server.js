/**
 * server.js — minimal Express proxy for OpenAI API
 *
 * Why: Never call OpenAI directly from the browser — your API key would be
 * exposed. This tiny server receives requests from app.js (POST /api/generate)
 * and forwards them to OpenAI using a server-side secret key.
 *
 * Setup:
 *   1. npm init -y
 *   2. npm install express cors dotenv node-fetch
 *   3. Create a .env file with: OPENAI_API_KEY=sk-xxxxxxxx
 *   4. node server.js
 *   5. Serve index.html/app.js from the same origin (or update CORS + API_ENDPOINT)
 */

require("dotenv").config();
const express = require("express");
const cors = require("cors");
const fetch = require("node-fetch");

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(__dirname)); // serves index.html, app.js, etc.

app.post("/api/generate", async (req, res) => {
  try {
    const { messages, model = "gpt-4o-mini", temperature = 0.7 } = req.body;

    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
      },
      body: JSON.stringify({ model, messages, temperature }),
    });

    const data = await response.json();

    if (!response.ok) {
      return res.status(response.status).json(data);
    }

    res.json(data);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`SmartWA server running on http://localhost:${PORT}`));
