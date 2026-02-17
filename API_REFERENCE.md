# API Reference Card

## 🌐 Base URL
```
https://know-your-right-backend.onrender.com
```

## 📡 Endpoints

### 1. Health Check
```http
GET /health
```
**Response:**
```json
{ "status": "ok", "timestamp": "2026-02-17T10:30:00.000Z" }
```

### 2. Classify Issue
```http
POST /api/classify
Content-Type: application/json

{
  "text": "User's legal issue description"
}
```

**Success (200):**
```json
{
  "issue_id": "salary_not_paid",
  "confidence": 0.95,
  "fallback": false
}
```

**Low Confidence (200):**
```json
{
  "issue_id": "unknown",
  "confidence": 0.45,
  "fallback": true
}
```

**Validation Error (400):**
```json
{
  "error": "Text must be at least 15 characters"
}
```

**Rate Limit (429):**
```json
{
  "error": "Too many requests, please try again later."
}
```

---

## 🏷️ Issue IDs

| ID | Description |
|----|-------------|
| `salary_not_paid` | Unpaid wages, salary disputes |
| `landlord_dispute` | Rental, eviction, property issues |
| `online_fraud` | E-commerce scams, online fraud |
| `consumer_complaint` | Product/service complaints |
| `police_issue` | Police harassment, detention |
| `unknown` | Cannot classify (< 60% confidence) |

---

## ⚙️ Constraints

| Property | Value |
|----------|-------|
| **Min Text** | 15 characters |
| **Max Text** | 500 characters |
| **Rate Limit** | 20 requests/minute per IP |
| **Timeout** | 7 seconds |
| **Confidence Threshold** | 0.6 (60%) |

---

## 🔒 HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success (may have `fallback: true`) |
| 400 | Bad Request (validation failed) |
| 429 | Too Many Requests (rate limit) |
| 500 | Internal Server Error |

---

## 📊 Confidence Levels

| Range | Action |
|-------|--------|
| 0.9 - 1.0 | Very certain - proceed |
| 0.7 - 0.89 | High confidence - show result |
| 0.6 - 0.69 | Medium - verify with user |
| < 0.6 | Low - ask for more details (`fallback: true`) |

---

## ⚡ Quick Examples

### cURL
```bash
curl -X POST https://know-your-right-backend.onrender.com/api/classify \
  -H "Content-Type: application/json" \
  -d '{"text": "My employer has not paid my salary for 3 months"}'
```

### JavaScript/Fetch
```javascript
const res = await fetch('https://know-your-right-backend.onrender.com/api/classify', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ text: 'Your issue description here' })
});
const data = await res.json();
```

### React Native
```javascript
const classify = async (text) => {
  const response = await fetch(
    'https://know-your-right-backend.onrender.com/api/classify',
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text })
    }
  );
  return await response.json();
};
```

---

## 🐛 Error Handling

```javascript
try {
  const response = await fetch(API_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ text: userInput })
  });

  if (response.status === 429) {
    throw new Error('Rate limit exceeded. Please wait.');
  }

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Request failed');
  }

  const data = await response.json();
  
  if (data.fallback) {
    console.warn('Low confidence classification');
    // Ask user for more details
  }
  
  return data;
} catch (err) {
  console.error('Classification failed:', err.message);
  throw err;
}
```

---

## 📚 Documentation

- **Quick Start**: [QUICK_START.md](QUICK_START.md)
- **Full Integration Guide**: [CLIENT_INTEGRATION.md](CLIENT_INTEGRATION.md)
- **Backend Documentation**: [README.md](README.md)
- **Groq Setup**: [GROQ_SETUP.md](GROQ_SETUP.md)

---

**Print this card for quick reference during development!**
